//
//  PredixAppWindow.swift
//  IssuesListApp
//
//  Created by Johns, Andy (GE Corporate) on 1/22/16.
//  Copyright © 2016 GE. All rights reserved.
//

import Foundation
import PredixMobileSDK

// This class manages the main UI for the app.
@objc class PredixAppWindow : NSObject, PredixAppWindowProtocol
{
    // Requests to update the UI from the Window service start here. Obviously this is a web-centric
    // design, but we can implement this however we wish. In this case we largely ignore the provided
    // "URL" parameter, but instead interact with the "parameters" parameter. This dictionary is the contents
    // of the webapp document loaded with the "pm publish" cli command. In this case we've added
    // an additional element to the dictionary, "storyboardId" which instructs our native UI to load
    // a specific storyboard.
    func loadURL(URL: NSURL, parameters: [NSObject : AnyObject]?, onComplete: (() -> ())?)
    {
        PGSDKLogger.info(__FUNCTION__)
        
        // if we find the "storyboardId" element in the dictionary
        if let parameters = parameters, storyboardId = parameters["storyboardId"] as? String
        {
            // ensure this storyboard exists in the app
            if self.isValidStoryboardName(storyboardId)
            {
                self.displayStoryboard(storyboardId)
            }
            else
            {
                self.callSeriousErrorPage("Storyboard \(storyboardId) not in bundle")
            }
        }
        else
        {
            // ignore "about:blank" load
            if URL.scheme != "about"
            {
                self.callSeriousErrorPage("Unable to load webapp: \(URL.lastPathComponent)")
            }
            

        }
    
        if let onComplete = onComplete
        {
            onComplete()
        }
        
    }
    
    // If we encounter an error we load the "SeriousErrorPage". Since this HTML page is not in our bundle, the PredixMobileSDK for iOS 
    // will default to using a UIAlertController to display this error.
    // If the HTML page was in our bundle, we'd have to handle loading that web page, or a native replacement of it, in our LoadURL method above.
    func callSeriousErrorPage(message: String)
    {
        var path = "showseriouserrorpage"
        if let urlMessage = message.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        {
            path += "?e=\(urlMessage)"
        }
        
        ServiceRouter.sharedInstance.processRequest(ServiceId.Window, extraPath: path, method: "POST", data: nil, responseBlock: { (_:NSURLResponse?) -> Void in
            }, dataBlock: { (_ : NSData?) -> Void in
            }) { () -> Void in
        }
    }
    
    // Validate that the storyboard actually exists
    func isValidStoryboardName(storyboardName: String)->(Bool)
    {
        return (NSBundle.mainBundle().URLForResource(storyboardName, withExtension: "storyboardc") != nil)
    }
    
    // load the storyboard and present it's initial view controller
    func displayStoryboard(storyboardName: String)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let sb = UIStoryboard(name: storyboardName, bundle: NSBundle.mainBundle())
        let vc = sb.instantiateInitialViewController()
        
        appDelegate.window?.rootViewController?.presentViewController(vc!, animated: true, completion: nil)
    }

    // For this quick example we're not supporting the wait spinner
    func updateWaitState(state: PredixMobileSDK.WaitState, message: String?)
    {
        PGSDKLogger.info(__FUNCTION__)
    }
    func waitState() -> (PredixMobileSDK.WaitStateReturn)
    {
        PGSDKLogger.info(__FUNCTION__)
        return WaitStateReturn(.NotWaiting)
    }
}