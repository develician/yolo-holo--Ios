//
//  ProfileAPI.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 29..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation

enum ProfileAPI {
    case getProfileImage(thumbnailPath: String)
    case pickedImage(filename: String)
}

extension ProfileAPI {
    var baseURL: String {
        return "http://192.168.0.23:4000"
    }
    
    var path: String {
        switch self {
        case let .getProfileImage(thumbnailPath):
            return "\(thumbnailPath)"
        case let .pickedImage(filename):
            return "/static/images/\(filename)"
        }
    }
    
    var url: URL? {
        return URL(string: "\(self.baseURL)\(self.path)")
    }
}
