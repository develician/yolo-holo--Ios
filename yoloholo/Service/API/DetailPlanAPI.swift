//
//  DetailPlanAPI.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 29..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation

enum DetailPlanAPI {
    case read(planId: String, day: Int)
    case create
    case remove(id: String)
    case update(id: String)
}

extension DetailPlanAPI {
    var baseURL: String {
        return "http://192.168.0.23:4000"
    }
    
    var path: String {
        switch self {
        case let .read(planId, day):
            return "/api/detailPlan/\(planId)/\(day)"
        case .create:
            return "/api/detailPlan"
        case let .remove(id):
            return "/api/detailPlan/\(id)"
        case let.update(id):
            return "/api/detailPlan/\(id)"
        }
    }

    var url: URL? {
        return URL(string: "\(self.baseURL)\(self.path)")
    }
}
