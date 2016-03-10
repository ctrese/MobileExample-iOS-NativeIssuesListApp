//
//  Models.swift
//  IssuesListApp
//
//  Created by Johns, Andy (GE Corporate) on 2/26/16.
//  Copyright © 2016 GE. All rights reserved.
//

import Foundation
import PredixMobileSDK

// Summary and Detail models

// MARK: - Constants
// Keys for extracting detail data from the detail data document
private struct DetailKeys
{
    static let Assignee = "assignee"
    static let Body = "body"
    static let Customer = "customer"
    static let Severity = "severity"
    static let Status = "status"
    static let Title = "title"
    static let CreatedDate = "created_at"
    static let UpdateDate = "updated_at"
    static let DataType = "dataType"
    static let Id = "_id"
}

// Keys for extracting summary data from the issues view
private struct SummaryKeys
{
    static let Id = "id"
    static let Severity = "key"
    static let Rows = "value"
    static let Body = 0
    static let Status = 1
    static let Title = 2
}

// MARK: - Summary model structure
struct IssueSummary
{
    // cache of the Severity images for Critical, Urgent, and Normal severities.
    static private var imageCache = [String : UIImage]()
    
    // MARK: - Summary Model properties
    let id : String
    let severity : String
    let body : String
    let status : String
    let title : String
    let ordinal : Int
   
    // MARK: - Initialization
    init(_ id : String, _ severity : String, _ body : String, _ status : String, _ title : String)
    {
        self.id = id
        self.severity = severity
        self.body = body
        self.status = status
        self.title = title
        
        // the data is not well suited to sorting in the view, so we add a value here to make sorting easier.
        var high : Int
        switch severity
        {
            case "critical" : high = 1
            case "urgent" : high = 2
            case "normal" : high = 3
            default : high = 4
        }
        
        var low : Int

        switch status
        {
            case "open" : low = 1
            case "accepted" : low = 2
            case "pending" : low = 3
            case "closed" : low = 4
            default : low = 5
        }
        
        self.ordinal = high * 10 + low
        
    }

    init(id : String, severity : String, body : String, status : String, title : String)
    {
        self.init(id, severity, body, status, title)
    }
    
    init?(viewRow : [String : AnyObject])
    {
        //Ensure all data is as expected before creating the structure
        if let id = viewRow[SummaryKeys.Id] as? String, severity = viewRow[SummaryKeys.Severity] as? String, values = viewRow[SummaryKeys.Rows] as? [String] where values.count > 2
        {
            let body = values[SummaryKeys.Body]
            let status = values[SummaryKeys.Status]
            let title = values[SummaryKeys.Title]
            self.init(id, severity, body, status, title)
        }
        else
        {
            return nil
        }
    }

    // MARK: - Methods
    
    //returns the image for this severity, populating the cache if needed
    func getSeverityImage()->(UIImage)
    {
        let imageName = "issue-\(self.severity)"
        if let image = IssueSummary.imageCache[imageName]
        {
            return image
        }
        else
        {
            if let image = UIImage(named: imageName)
            {
                let cgImage = image.CGImage
                let scaledImage = UIImage(CGImage: cgImage!, scale: image.scale * 0.2, orientation: image.imageOrientation)
                IssueSummary.imageCache[imageName] = scaledImage
                return scaledImage
            }
        }
        return UIImage()
    }
    
    // Calls the database to retrieve the Detail data for this Summary
    func getDetail(onComplete: (IssueDetail?)->())
    {

        var success = false
        var doc : [String : AnyObject]?
        
        ServiceRouter.sharedInstance.processRequest(ServiceId.CDB, extraPath: "~/\(self.id)", responseBlock: { (response: NSURLResponse?) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200
            {
                success = true
            }
            }, dataBlock: { (data: NSData?) -> Void in
                
                if let data = data where success
                {
                    let dataObj = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
                    
                    if let returnDict = dataObj as? [String : AnyObject]
                    {
                        doc = returnDict
                    }
                }
                
            }) { () -> Void in
                
                onComplete(IssueDetail(doc))
                
        }
    }
}

// MARK: - Detail model structure
struct IssueDetail
{
    // cache the date formatter used to convert the raw string dates stored in the database to NSDate objects
    static var dateFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    // MARK: - Detail Model properties
    let assignee : String
    let body : String
    let customer : String
    let severity : String
    let status : String
    let title : String
    let createdDate : NSDate
    let updateDate : NSDate
    let type : String
    let id : String
    
    // MARK: - Initialization
    init(_ id: String, _ assignee : String, _ body : String, _ customer : String, _ severity : String, _ status : String, _ title : String, _ type : String, _ createdDate : NSDate, _ updateDate : NSDate)
    {
        self.assignee = assignee
        self.body = body
        self.customer = customer
        self.severity = severity
        self.status = status
        self.title = title
        self.type = type
        self.createdDate = createdDate
        self.updateDate = updateDate
        self.id = id.substringFromIndex(id.endIndex.advancedBy(-6))
    }
    
    init(id: String, assignee : String, body : String, customer : String, severity : String, status : String, title : String, type : String,createdDate : NSDate, updateDate : NSDate)
    {
        self.init(id, assignee, body, customer, severity, status, title, type, createdDate, updateDate)
    }
    
    init?(_ dataDoc : [String : AnyObject]?)
    {
        //Ensure all data is as expected before creating the structure
        if let dataDoc = dataDoc, id = dataDoc[DetailKeys.Id] as? String, assignee = dataDoc[DetailKeys.Assignee] as? String, body = dataDoc[DetailKeys.Body] as? String, customer = dataDoc[DetailKeys.Customer] as? String, severity = dataDoc[DetailKeys.Severity] as? String, status = dataDoc[DetailKeys.Status] as? String, title = dataDoc[DetailKeys.Title] as? String, type = dataDoc[DetailKeys.DataType] as? String, createdDateString = dataDoc[DetailKeys.CreatedDate] as? String, updateDateString = dataDoc[DetailKeys.UpdateDate] as? String, createdDate = IssueDetail.dateFormatter.dateFromString(createdDateString), updateDate = IssueDetail.dateFormatter.dateFromString(updateDateString)
        {
            self.init(id, assignee, body, customer, severity, status, title, type, createdDate, updateDate)
        }
        else
        {
            return nil
        }
    }
    
    //returns the image for this severity, populating the cache if needed
    func getSeverityImage()->(UIImage)
    {
        let imageName = "issue-\(self.severity)"
        if let image = IssueSummary.imageCache[imageName]
        {
            return image
        }
        else
        {
            if let image = UIImage(named: imageName)
            {
                let cgImage = image.CGImage
                let scaledImage = UIImage(CGImage: cgImage!, scale: image.scale * 0.2, orientation: image.imageOrientation)
                IssueSummary.imageCache[imageName] = scaledImage
                return scaledImage
            }
        }
        return UIImage()
    }
    
}