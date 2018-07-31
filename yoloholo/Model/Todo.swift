//
//  Todo.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 31..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Todo {
    let todo: String
    
    init(json: JSON) {
//        print(json)
//        guard let todo = json.string else {fatalError("Todo Model todo parsing error")}
//
        self.todo = "\(json)"
    }
}
