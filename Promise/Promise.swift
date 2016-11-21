
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
    
    var isMade = false
    var goal = ""
    var interval = [true, true, true, true, true, true, true]
    var intervalToDisplay = "Everyday"
    var duration: Int = 4
    var rewardPrefix = ""
    var reward = ""
    var startDate = Date()
    var endDate = Date()
    var shouldRemind = false
    var remindDate = Date()
    var supporters = [Supporter]()
    var competitors = [Competitor]()
    var itemID: Int = 0
    var datesToCheckIn = [DateToCheckIn]()
    
    
    required init?(coder aDecoder: NSCoder) {
        isMade = aDecoder.decodeBool(forKey: "IsMade")
//        currentDateCount = aDecoder.decodeInteger(forKey: "CurrentDateCount")
        goal = aDecoder.decodeObject(forKey: "Goal") as! String
        interval = aDecoder.decodeObject(forKey: "Interval") as! [Bool]
        intervalToDisplay = aDecoder.decodeObject(forKey: "IntervalToDisplay") as! String
        duration = aDecoder.decodeInteger(forKey: "Duration")
        rewardPrefix = aDecoder.decodeObject(forKey: "RewardPrefix") as! String
        reward = aDecoder.decodeObject(forKey: "Reward") as! String
        startDate = aDecoder.decodeObject(forKey: "StartDate") as! Date
        endDate = aDecoder.decodeObject(forKey: "EndDate") as! Date
        shouldRemind = aDecoder.decodeBool(forKey: "ShouldRemind")
        remindDate = aDecoder.decodeObject(forKey: "RemindDate") as! Date
        supporters = aDecoder.decodeObject(forKey: "Supporters") as! [Supporter]
        competitors = aDecoder.decodeObject(forKey: "Competitors") as! [Competitor]
        itemID = aDecoder.decodeInteger(forKey: "ItemID")
        datesToCheckIn = aDecoder.decodeObject(forKey: "DatesToCheckIn") as! [DateToCheckIn]
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(isMade, forKey: "IsMade")
//        aCoder.encode(currentDateCount, forKey: "CurrentDateCount")
        aCoder.encode(goal, forKey: "Goal")
        aCoder.encode(interval, forKey: "Interval")
        aCoder.encode(intervalToDisplay, forKey: "IntervalToDisplay")
        aCoder.encode(duration, forKey: "Duration")
        aCoder.encode(rewardPrefix, forKey: "RewardPrefix")
        aCoder.encode(reward, forKey: "Reward")
        aCoder.encode(startDate, forKey: "StartDate")
        aCoder.encode(endDate, forKey: "EndDate")
        aCoder.encode(shouldRemind, forKey: "ShouldRemind")
        aCoder.encode(remindDate, forKey: "RemindDate")
        aCoder.encode(supporters, forKey: "Supporters")
        aCoder.encode(competitors, forKey: "Competitors")
        aCoder.encode(itemID, forKey: "ItemID")
        aCoder.encode(datesToCheckIn, forKey: "DatesToCheckIn")
    }
    
    
    override init() {
        itemID = DataModel.nextReminderID()
        print("ITEMID: \(itemID)")
        super.init()
    }
    
 
    
    deinit {
        removeNotification()
    }
    

    
    
    func getIntervalToDisplay() -> String {
        let daysShort = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        var intervalCount = 0
        var index = 0
        var intervalToDisplayTemp = ""
        for bool in interval {
            if bool {
                intervalToDisplayTemp += "\(daysShort[index]) "
                intervalCount += 1
            }
            index += 1
        }
        if intervalCount == 7 {
            self.intervalToDisplay = "Everyday"
            return "Everyday"
        } else {
            self.intervalToDisplay = intervalToDisplayTemp
            return intervalToDisplayTemp
        }
    }
    
    
//    func durationToDisplay() -> String {
//        let durationSuffix = (duration == 1) ? "" : "s"
//        let durationToDisplay = "\(self.duration) Week\(durationSuffix)"
//        return durationToDisplay
//    }
    
    
    func scheduleNotification() {
        removeNotification()
        
        let content = UNMutableNotificationContent()
        content.title = "Are you ready to do \(goal)?"
        content.body = "Let's do it!"
        content.sound = UNNotificationSound.default()
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.hour, .minute], from: remindDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request)
        
        print("Scheduled notification \(request) for itemID \(itemID)")
    }
    
    
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["\(itemID)"])
    }
    
    
    
    
    
}













