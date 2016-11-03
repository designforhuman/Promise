//
//  Competitor.swift
//  Promise
//
//  Created by LeeDavid on 11/3/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import Foundation


class Competitor: NSObject, NSCoding {
    
    var name = ""
    var photoUrl = ""
    
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        photoUrl = aDecoder.decodeObject(forKey: "PhotoUrl") as! String
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(photoUrl, forKey: "PhotoUrl")
    }
    
    
    //    override init() {
    //        super.init()
    //    }
    
    
    init(name: String, photoUrl: String) {
        self.name = name
        self.photoUrl = photoUrl
        super.init()
    }
    
}
