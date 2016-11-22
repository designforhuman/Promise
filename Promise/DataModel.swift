//
//  DataModel.swift
//  Promise
//
//  Created by LeeDavid on 11/1/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import Foundation



class DataModel {
    
    var lists = [Promise]()
    var promiseNum = 0
    
    init() {
        loadLists()
        registerDefaults()
//        handleFirstTime()
//        print("DIRECTORYYYY: \(documentsDirectory())")
    }
    
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Promise.plist")
    }
    
    func saveLists() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(lists, forKey: "Promise")
        archiver.finishEncoding()
        data.write(to: dataFilePath(), atomically: true)
    }
    
    func loadLists() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            lists = unarchiver.decodeObject(forKey: "Promise") as! [Promise]
            unarchiver.finishDecoding()
//            sortChecklists()
        }
    }
    
//    func sortChecklists() {
//        lists.sort(by: { checklist1, checklist2 in return checklist1.name.localizedStandardCompare(checklist2.name) == .orderedAscending })
//    }
    
    
    func registerDefaults() {
        let dictionary: [String: Any] = ["FirstTime": true, "reminderID": 0]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    func handleFirstTime() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        
        if firstTime {
            let promise = Promise()
            lists.append(promise)
            
//            indexOfSelectedChecklist = 0
            userDefaults.set(false, forKey: "FirstTime")
            userDefaults.synchronize()
        }
    }
    
    
    class func nextReminderID() -> Int {
        let userDefaults = UserDefaults.standard
        let itemID = userDefaults.integer(forKey: "reminderID")
        userDefaults.set(itemID + 1, forKey: "reminderID")
        userDefaults.synchronize()
        print("NEXTITEMID: \(itemID)")
        return itemID
    }
    
}







