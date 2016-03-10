//
//  SplitViewController.swift
//  IssuesListApp
//
//  Created by Johns, Andy (GE Corporate) on 3/1/16.
//  Copyright © 2016 GE. All rights reserved.
//

import UIKit
import PredixMobileSDK

class splitViewController : UISplitViewController, UISplitViewControllerDelegate
{
    
    override func awakeFromNib() {
        self.delegate = self
        
        self.navigationController?.topViewController?.navigationItem.leftBarButtonItem = self.displayModeButtonItem()
        
        super.awakeFromNib()
    }
    
    @objc func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
    
        if self.traitCollection.horizontalSizeClass == .Compact
        {
            if let navController = secondaryViewController as? UINavigationController, topVC = navController.topViewController as? DetailViewController
            {
                return (topVC.detailItem == nil)
            }
        }
        return false
    }

}