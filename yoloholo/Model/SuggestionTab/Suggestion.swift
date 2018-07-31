//
//  Suggestion.swift
//  yoloholo
//
//  Created by killi8n on 2018. 8. 1..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation
import RxDataSources

struct Suggestion {
    let id: String
    let name: String
    
}

extension Suggestion: IdentifiableType, Equatable {
    static func ==(lhs: Suggestion, rhs: Suggestion) -> Bool {
        return lhs.id == rhs.id
    }
    
    var identity: String {
        return id
    }
}
