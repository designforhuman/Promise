//
//  DateToCheckIn.swift
//  Promise
//
//  Created by LeeDavid on 11/13/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import Foundation



class DateToCheckIn: NSObject, NSCoding {
    
//    var isActive = false
    var active = false // all true if the user sets to everyday
    var count = 0
    var formattedDate = ""
    var day: Int!
//    var month: Int!
//    var year: Int!
    var weekday: Int!
//    var weekOfMonth: Int!
    var weekOfYear: Int!
    var isCheckedIn = false
//    var photoUrl
    
    
    required init?(coder aDecoder: NSCoder) {
        active = aDecoder.decodeBool(forKey: "Active")
        count = aDecoder.decodeInteger(forKey: "Count")
        formattedDate = aDecoder.decodeObject(forKey: "FormattedDate") as! String
        day = aDecoder.decodeObject(forKey: "Day") as! Int
        weekday = aDecoder.decodeObject(forKey: "Weekday") as! Int
        weekOfYear = aDecoder.decodeObject(forKey: "WeekOfYear") as! Int
        isCheckedIn = aDecoder.decodeBool(forKey: "IsCheckedIn")
        super.init()
    }
    
//    override init() {
//        super.init()
//    }
    
    init(active: Bool, count: Int, formattedDate: String, day: Int, weekday: Int, weekOfYear: Int) {
        self.active = active
        self.count = count
        self.formattedDate = formattedDate
        self.day = day
        self.weekday = weekday
        self.weekOfYear = weekOfYear
        super.init()
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(active, forKey: "Active")
        aCoder.encode(count, forKey: "Count")
        aCoder.encode(formattedDate, forKey: "FormattedDate")
        aCoder.encode(day, forKey: "Day")
        aCoder.encode(weekday, forKey: "Weekday")
        aCoder.encode(weekOfYear, forKey: "WeekOfYear")
        aCoder.encode(isCheckedIn, forKey: "IsCheckedIn")
    }
    
}








