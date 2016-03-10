//
//  DetailViewController.swift
//  split
//
//  Created by Johns, Andy (GE Corporate) on 2/26/16.
//  Copyright © 2016 GE. All rights reserved.
//

import UIKit

// View controller for the IssueDetail view
class DetailViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var severityImage: UIImageView!
    @IBOutlet var severityLabel: UILabel!
    @IBOutlet var issueNumberLabel: UILabel!
    @IBOutlet var customerLabel: UILabel!
    @IBOutlet var updateDateLabel: UILabel!
    @IBOutlet var issueTypeLabel: UILabel!
    @IBOutlet var assigneeLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var bodyView: UILabel!
    
    var summaryItem: IssueSummary? {
        didSet {
            // Update the view.
            summaryItem?.getDetail({ (detail:IssueDetail?) -> () in
                self.detailItem = detail
                self.configureView()
            })
        }
    }
    
    var detailItem : IssueDetail?

    func configureView() {
        // Update the user interface for the detail item.

        if let detail = self.detailItem
        {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                self.splitViewController?.preferredDisplayMode = .Automatic
                self.titleLabel.text = detail.title
                self.severityImage.image = self.summaryItem?.getSeverityImage()
                self.severityLabel.text = detail.severity
                self.issueNumberLabel.text = detail.id
                self.customerLabel.text = detail.customer
                self.updateDateLabel.text = formatter.stringFromDate(detail.updateDate)
                self.issueTypeLabel.text = detail.type
                self.assigneeLabel.text = detail.assignee
                self.statusLabel.text = detail.status
                self.bodyView.text = detail.body
                self.view.setNeedsDisplay()
                
            }
        }
        else
        {
            self.splitViewController?.preferredDisplayMode = .PrimaryOverlay
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

