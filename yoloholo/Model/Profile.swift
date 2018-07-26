//
//  User.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 23..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Profile {
    let username: String
    let thumbnail: String
    
    init?(json: JSON) {
        guard let usernameJSON = json["username"].string else {fatalError("parsing error")}
        guard let thumbnailJSON = json["thumbnail"].string else {fatalError("parsing error")}
        
        self.username = usernameJSON
        self.thumbnail = thumbnailJSON
    }
}

