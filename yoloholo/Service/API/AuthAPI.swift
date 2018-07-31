//
//  API.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 29..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation

enum AuthAPI {
    case login
    case register
    case logout
    case profile(username: String)
    case changePassword
    case facebook
}

extension AuthAPI {
    var baseURL: String {
        return "http://192.168.0.23:4000"
    }
    
    var path: String {
        switch self {
        case .login:
            return "/api/auth/login"
        case .register:
            return "/api/auth/register"
        case .logout:
            return "/api/auth/logout"
        case let .profile(username):
            return "/api/auth/profile/\(username)"
        case .changePassword:
            return "/api/auth"
        case .facebook:
            return "/api/auth/facebook"
        }
    }
    
    var url: URL? {
        return URL(string: "\(self.baseURL)\(self.path)")
    }
}

