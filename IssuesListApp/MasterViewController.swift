//
//  MasterViewController.swift
//  split
//
//  Created by Johns, Andy (GE Corporate) on 2/26/16.
//  Copyright © 2016 GE. All rights reserved.
//

import UIKit
import PredixMobileSDK

class summaryCell : UITableViewCell
{
    @IBOutlet var severityImage: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var status: UILabel!
}

// View controller for the Issue Summary list master view.
class MasterViewController: UITableViewController {

    @IBOutlet var criticalButtonItem: UIBarButtonItem!
    @IBOutlet var normalButtonItem: UIBarButtonItem!
    @IBOutlet var warningButtonItme: UIBarButtonItem!

    enum IssueSeverities : String
    {
        case all, critical, normal, urgent
    }

    var detailViewController: DetailViewController? = nil
    var objects = [IssueSummary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.loadIssues(.all)
        
        var button = UIButton(frame: CGRectMake(0, 0, 18, 18))
        button.setBackgroundImage(UIImage(named: "issue-critical"), forState: .Normal)
        button.addTarget(self, action: Selector("criticalButtonItemTapped:"), forControlEvents: .TouchUpInside)
        let criticalBarButton = UIBarButtonItem(customView: button)
        
        button = UIButton(frame: CGRectMake(0, 0, 18, 18))
        button.setBackgroundImage(UIImage(named: "issue-normal"), forState: .Normal)
        button.addTarget(self, action: Selector("normalButtonItemTapped:"), forControlEvents: .TouchUpInside)
        let normalBarButton = UIBarButtonItem(customView: button)

        button = UIButton(frame: CGRectMake(0, 0, 18, 18))
        button.setBackgroundImage(UIImage(named: "issue-urgent"), forState: .Normal)
        button.addTarget(self, action: Selector("urgentButtonItemTapped:"), forControlEvents: .TouchUpInside)
        let urgentBarButton = UIBarButtonItem(customView: button)
        
        let allBarButton = UIBarButtonItem(title: "All", style: UIBarButtonItemStyle.Plain , target: self, action: Selector("allButtonItemTapped:"))
        
        self.navigationItem.rightBarButtonItems = [normalBarButton, urgentBarButton, criticalBarButton, allBarButton]

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        //objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.summaryItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! summaryCell

        let object = objects[indexPath.row]

        cell.severityImage.image = object.getSeverityImage()
        cell.title.text = object.title
        cell.status.text = object.status
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    // MARK: - IBActions
    
    @IBAction func allButtonItemTapped(sender: AnyObject)
    {
        self.loadIssues(.all)
    }

    @IBAction func criticalButtonItemTapped(sender: AnyObject)
    {
        self.loadIssues(.critical)
    }

    @IBAction func normalButtonItemTapped(sender: AnyObject)
    {
        self.loadIssues(.normal)
    }
    
    @IBAction func urgentButtonItemTapped(sender: AnyObject)
    {
        self.loadIssues(.urgent)
    }
    
    // MARK: - Class Methods
    
    func loadIssues(severity : IssueSeverities)
    {
        self.loadIssues(severity) { (issues: [IssueSummary]) -> () in
            self.objects = issues
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    func loadIssues(severity : IssueSeverities, onComplete: ([IssueSummary])->())
    {
        var path = "~/_design/views/_view/issues"
        
        if severity != .all
        {
            path += "?key=%22\(severity.rawValue)%22"
        }

        
        var issues = [IssueSummary]()
        
        ServiceRouter.sharedInstance.processRequest(ServiceId.CDB, extraPath: path, responseBlock: { (response: NSURLResponse?) -> Void in
            
            if let httpResponse = response as? NSHTTPURLResponse
            {
                if httpResponse.statusCode != HTTPStatusCode.OK.rawValue
                {
                    PGSDKLogger.error("\(__FUNCTION__): error status returned getting all docs: \(httpResponse.statusCode)")
                }
            }
            
            
            }, dataBlock: { (data : NSData?) -> Void in
                
                if let data = data
                {
                    do
                    {
                        let dataObj = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
                        
                        if let returnDict = dataObj as? [String : AnyObject], rows = returnDict["rows"] as? [[String : AnyObject]]
                        {
                            for row in rows
                            {
                                if let issueSummary = IssueSummary(viewRow: row)
                                {
                                    issues.append(issueSummary)
                                }
                                else
                                {
                                    PGSDKLogger.error("Unexpected row data in view: \(row)")
                                }
                            }
                        }
                        
                    }
                    catch let error
                    {
                        PGSDKLogger.error("\(__FUNCTION__): error deserializing JSON from CDB call: \(error)")
                    }
                }
                
            }) { () -> Void in
                
                if issues.count == 0 { PGSDKLogger.error("No documents found") }
                
                // the data is not well suited to sorting via the view, so we sort here.
                issues.sortInPlace({ (a : IssueSummary, b : IssueSummary) -> Bool in
                    
                    return a.ordinal < b.ordinal
                
                })
                onComplete(issues)
                
        }
    }
    

}

