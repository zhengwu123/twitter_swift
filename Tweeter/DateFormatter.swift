//
//  DateFormatter.swift
//  Tweeter
//
//  Created by zheng wu on 2/11/16.
//  Copyright © 2016 zheng wu. All rights reserved.
//

import UIKit

class DateFormatter: NSObject {
    class var sharedInstance: NSDateFormatter {
        struct Static {
            static let instance = NSDateFormatter()
        }
        return Static.instance
    }
    
    class func dateFromString(dateString: String?) -> NSDate? {
        
        sharedInstance.dateFormat = "EEE MMM d HH:mm:ss Z y"
        let calendar = NSCalendar.autoupdatingCurrentCalendar()
        calendar.timeZone = NSTimeZone.systemTimeZone()
        sharedInstance.timeZone = calendar.timeZone
        return sharedInstance.dateFromString(dateString!)
    }
    
    class func sinceNowFormat(startDate: NSDate?) -> String? {
        if startDate == nil {
            return nil
        }
        
        var outputTime = ""
        let calendar = NSCalendar.autoupdatingCurrentCalendar()
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: startDate!, toDate: NSDate(), options: [])
        
        if components.year > 1 {
            outputTime = "\(components.year) years ago"
        } else if components.month > 1 {
            outputTime = "\(components.month) months ago"
        } else if components.day > 1 {
            outputTime = "\(components.day) days ago"
        } else if components.hour > 1 {
            outputTime = "\(components.hour)h"
        } else if components.minute > 1 {
            outputTime = "\(components.minute)m"
        } else {
            outputTime = "\(components.second)s"
        }
        return outputTime
    }

}

