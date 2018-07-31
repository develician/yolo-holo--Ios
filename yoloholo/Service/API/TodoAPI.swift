//
//  TodoAPI.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 30..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation

enum TodoAPI {
    case listTodo(id: String)
    case addTodo(id: String)
    case editTodo(id: String, index: Int)
    case removeTodo(id: String, index: Int)
}


extension TodoAPI {
    var baseURL: String {
        return "http://192.168.0.23:4000"
    }
    
    var path: String {
        switch self {
        case let .listTodo(id):
            return "/api/detailPlan/todo/list/\(id)"
        case let .addTodo(id):
            return "/api/detailPlan/todo/\(id)"
        case let .editTodo(id, index):
            return "/api/detailPlan/todo/edit/\(id)/\(index)"
        case let .removeTodo(id, index):
            return "/api/detailPlan/todo/\(id)/\(index)"
        }
        
    }
    
    var url: URL? {
        return URL(string: "\(self.baseURL)\(self.path)")
    }
}
