
//
//  Goal.swift
//  Promise
//
//  Created by LeeDavid on 10/11/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import Foundation



class Promise {
    
    var goal = ""
    var interval = [true, true, true, true, true, true, true]
    var duration: Int = 4
    var reward = ""
    var reminder = false
    var days = [Day]()
    
    
    init() {
        
    }
    
    
//    required init?(coder aDecoder: NSCoder) {
//        
//        super.init()
//    }
    
    init(goal: String) {
        self.goal = goal
    }
    
    
    func makeInitialDays() {
        for _ in 0...(self.duration * 7) {
            days.append(Day())
        }
    }
    
    
    
}













