//
//  AuthenticationVC.swift
//  IssuesListApp
//
//  Created by Johns, Andy (GE Corporate) on 1/22/16.
//  Copyright © 2016 GE. All rights reserved.
//

import UIKit
import PredixMobileSDK

// This view controller will handle displaying the web-based authentication page.
class AuthenticationVC: UIViewController, PredixAppWindowProtocol {

    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func loadURL(URL: NSURL, parameters: [NSObject : AnyObject]?, onComplete: (()->())?)
    {
        self.webView.scrollView.scrollEnabled = true
        if let params = parameters, scrollStateString = params["nativeScroll"] as? String where scrollStateString == "false"
        {
            self.webView.scrollView.scrollEnabled = false
        }
        
        self.webView.loadRequest(NSURLRequest(URL:URL))
    }
    
    // For this quick example we're not supporting the wait spinner
    func updateWaitState(state: PredixMobileSDK.WaitState, message: String?)
    {
        PGSDKLogger.info("__FUNCTION__")
    }
    func waitState() -> (PredixMobileSDK.WaitStateReturn)
    {
        PGSDKLogger.info("__FUNCTION__")
        return WaitStateReturn(.NotWaiting)
    }
    
}
