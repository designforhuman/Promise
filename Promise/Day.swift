//
//  Day.swift
//  Promise
//
//  Created by LeeDavid on 10/25/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import Foundation



class Day: NSObject, NSCoding {
    
    var emojiName = ""
    
    
    required init?(coder aDecoder: NSCoder) {
        emojiName = aDecoder.decodeObject(forKey: "EmojiName") as! String
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(emojiName, forKey: "EmojiName")
    }
    
    
}






