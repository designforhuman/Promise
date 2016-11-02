//
//  Supporter.swift
//  Promise
//
//  Created by LeeDavid on 10/26/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import Foundation


class Supporter: NSObject, NSCoding {
    
    var num = 0
    var name = ""
    var photoUrl = ""
    var reaction = ""
    
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    
    override init() {
        super.init()
    }
    
    init(name: String, photoUrl: String, reaction: String) {
        self.name = name
        self.photoUrl = photoUrl
        self.reaction = reaction
        super.init()
    }
    
}
