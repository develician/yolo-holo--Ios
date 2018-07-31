//
//  PlanAPI.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 29..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation

enum PlanAPI {
    case createPlan
    case planList(username: String)
    case removePlan(id: String)
    case updatePlan(id: String)
}

extension PlanAPI {
    var baseURL: String {
        return "http://192.168.0.23:4000"
    }
    
    var path: String {
        switch self {
        case .createPlan:
            return "/api/plan"
        case let .planList(username):
            return "/api/plan/\(username)"
        case let .removePlan(id):
            return "/api/plan/\(id)"
        case let .updatePlan(id):
            return "/api/plan/\(id)"
            
        }
        
    }

    var url: URL? {
        return URL(string: "\(self.baseURL)\(self.path)")
    }
}
