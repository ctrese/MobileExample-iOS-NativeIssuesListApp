//
//  AppDelegate.swift
//  IssuesListApp
//
//  Created by Johns, Andy (GE Corporate) on 1/22/16.
//  Copyright © 2016 GE. All rights reserved.
//

import UIKit
import PredixMobileSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var navController : UINavigationController
    {
        get { return self.window?.rootViewController as! UINavigationController }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        #if DEBUG
            if NSProcessInfo.processInfo().environment["XCInjectBundle"] != nil {
                // Exit if we're running unit tests...
                PGSDKLogger.debug("Detected running functional unit tests, not starting normal services or running normal UI processes")
                return true
            }
        #endif
  
        // Pre-load configuration. This will load any Settings bundles into NSUserDefaults and set default logging levels
        PredixMobilityConfiguration.loadConfiguration()

        //Create a view to load issues by severity. Include body, status and title fields in the view's result data
        PredixMobilityConfiguration.appendDataViewDefinition("views/issues", version: "1") { (properties: [String : AnyObject], emit: (AnyObject, AnyObject?) -> ()) -> () in
            
            if let severity = properties["severity"] as? String, body = properties["body"], status = properties["status"] ,title = properties["title"]
            {
                emit(severity, [body, status, title])
            }
            
        }
        
        // create the PredixMobilityManager object. This object coordinates the application state, interacts with the various services, and holds closures called during authentication.

        self.navController.setNavigationBarHidden(true, animated: false)

        let pw = PredixAppWindow()
        unowned let unownedSelf = self
        let pmm = PredixMobilityManager(packageWindow: pw, presentAuthentication: { (packageWindow) -> (PredixAppWindowProtocol) in
            
            let authVC = unownedSelf.navController.storyboard!.instantiateViewControllerWithIdentifier("authenticationVC") as! AuthenticationVC
            _ = authVC.view
            unownedSelf.navController.pushViewController(authVC, animated: true)
            return authVC as PredixAppWindowProtocol
            
            }, dismissAuthentication: { (authenticationWindow) -> () in
                
                unownedSelf.navController.popViewControllerAnimated(true)
                
            })
        
        // logging our current running environment
        PGSDKLogger.debug("Started app with launchOptions: \(launchOptions)")
        
        let processInfo = NSProcessInfo.processInfo()
        let device = UIDevice.currentDevice()
        let bundle = NSBundle.mainBundle()
        let id : String = bundle.bundleIdentifier ?? ""
        
        PGSDKLogger.info("Running Environment:\n     locale: \(NSLocale.currentLocale().localeIdentifier)\n     device model:\(device.model)\n     device system name:\(device.systemName)\n     device system version:\(device.systemVersion)\n     device vendor identifier:\(device.identifierForVendor!.UUIDString)\n     iOS Version: \(processInfo.operatingSystemVersionString)\n     app bundle id: \(id)\n     app build version: \(bundle.objectForInfoDictionaryKey("CFBundleShortVersionString") ?? "")\n     app version: \(bundle.objectForInfoDictionaryKey(kCFBundleVersionKey as String) ?? "")")
        
        if TARGET_IPHONE_SIMULATOR == 1
        {
            //This will help you find where the build lives when running in the simulator
            PGSDKLogger.info("Simulator build running from:\n \(NSBundle.mainBundle().bundlePath)")
            let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory,.UserDomainMask,true).first!
            PGSDKLogger.info("Simulator Application Support dir is here:\n \(applicationSupportDirectory))")
        }

        // start the application. This will spin up the PredixMobile environment and call the Boot service to start the application.
        pmm.startApp()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        PredixMobilityManager.sharedInstance.applicationWillResignActive(application)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        PredixMobilityManager.sharedInstance.applicationDidEnterBackground(application)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        PredixMobilityManager.sharedInstance.applicationWillEnterForeground(application)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: UIReadyNotification, object: nil))
        PredixMobilityManager.sharedInstance.applicationDidBecomeActive(application)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        PredixMobilityManager.sharedInstance.applicationWillTerminate(application)
    }


}


