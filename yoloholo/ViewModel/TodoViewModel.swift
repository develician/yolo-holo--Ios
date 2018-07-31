//
//  TodoViewModel.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 31..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct TodoViewModel {
    let todo: String
    
    init(todo: Todo) {
        self.todo = todo.todo
    }
}
