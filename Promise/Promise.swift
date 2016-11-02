
//
//  Goal.swift
//  Promise
//
//  Created by LeeDavid on 10/11/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import Foundation
import UserNotifications


class Promise: NSObject, NSCoding {
    
    var goal = ""
    var interval = [true, true, true, true, true, true, true]
    var duration: Int = 4
    var rewardPrefix = ""
    var reward = ""
    var shouldRemind = false
    var date = Date()
    var days = [Day]()
    var supporters = [Supporter]()
    var itemID: Int = 0
    
    
    required init?(coder aDecoder: NSCoder) {
        goal = aDecoder.decodeObject(forKey: "Goal") as! String
        interval = aDecoder.decodeObject(forKey: "Interval") as! [Bool]
        duration = aDecoder.decodeInteger(forKey: "Duration")
        rewardPrefix = aDecoder.decodeObject(forKey: "RewardPrefix") as! String
        reward = aDecoder.decodeObject(forKey: "Reward") as! String
        shouldRemind = aDecoder.decodeBool(forKey: "ShouldRemind")
        date = aDecoder.decodeObject(forKey: "Date") as! Date
        days = aDecoder.decodeObject(forKey: "Days") as! [Day]
        supporters = aDecoder.decodeObject(forKey: "Supporters") as! [Supporter]
        itemID = aDecoder.decodeInteger(forKey: "ItemID")
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(goal, forKey: "Goal")
        aCoder.encode(interval, forKey: "Interval")
        aCoder.encode(duration, forKey: "Duration")
        aCoder.encode(rewardPrefix, forKey: "RewardPrefix")
        aCoder.encode(reward, forKey: "Reward")
        aCoder.encode(shouldRemind, forKey: "ShouldRemind")
        aCoder.encode(date, forKey: "Date")
        aCoder.encode(days, forKey: "Days")
        aCoder.encode(supporters, forKey: "Supporters")
        aCoder.encode(itemID, forKey: "ItemID")
    }
    
    override init() {
        itemID = DataModel.nextItemID()
        print("ITEMID: \(itemID)")
        super.init()
    }
    
 
    
    deinit {
        removeNotification()
    }
    
    
    
    func makeInitialDays() {
        for _ in 0...(self.duration * 7) {
            days.append(Day())
        }
    }
    
    
    
    func scheduleNotification() {
        removeNotification()
        
        if shouldRemind {
            if #available(iOS 10.0, *) {
                let content = UNMutableNotificationContent()
                content.title = "Are you ready to do \(goal)?"
                content.body = "Let's do it!"
                content.sound = UNNotificationSound.default()
                
                let calendar = Calendar(identifier: .gregorian)
                let components = calendar.dateComponents([.hour, .minute], from: date)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
                
                let center = UNUserNotificationCenter.current()
                center.add(request)
                
                print("Scheduled notification \(request) for itemID \(itemID)")
            } else {
                // Fallback on earlier versions
                print("OLD VERSION")
            }
            
        }
    }
    
    
    func removeNotification() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ["\(itemID)"])
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    
    
    
}













