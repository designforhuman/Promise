//
//  Supporter.swift
//  Promise
//
//  Created by LeeDavid on 10/26/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import Foundation


class Supporter {
    
    var num = 0
    var name = ""
    var photoUrl = ""
    var reaction = ""
    
    
    init() {}
    
    
    init(name: String, photoUrl: String, reaction: String) {
        self.name = name
        self.photoUrl = photoUrl
        self.reaction = reaction
    }
    
}
