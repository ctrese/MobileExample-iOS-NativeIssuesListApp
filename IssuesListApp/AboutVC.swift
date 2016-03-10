//
//  AboutVC.swift
//  IssuesListApp
//
//  Created by Johns, Andy (GE Corporate) on 3/3/16.
//  Copyright © 2016 GE. All rights reserved.
//

import UIKit
import PredixMobileSDK

//View controller for the About view.
class AboutVC: UIViewController {

    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var userImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // if we had a user image in the user data we could populate the image from that, however in this simple example we'll just user a static image.
        
        self.userImage.image = UIImage(named: "owen")
        
        var username : String?
        
        ServiceRouter.sharedInstance.processRequest(ServiceId.User, extraPath: "username", responseBlock: { (_ : NSURLResponse?) -> Void in
            
            }, dataBlock: { (data : NSData?) -> Void in
                if let data = data
                {
                    username = String(data: data, encoding: NSUTF8StringEncoding)
                    
                }
            }) { () -> Void in
                
                if let username = username
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.welcomeLabel.text = "Welcome \(username)"
                    })
                }
                
        }
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

}
