//
//  PlanViewModel.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 24..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct PlanViewModel {
    let _id: String
    let createdAt: Date
    let arriveDate: Date
    let departDate: Date
    let title: String
    let selectedDateArray: [JSON]
    let numberOfDays: Int
    let username: String
    
    init(plan: Plan) {
        self._id = plan._id
        self.createdAt = plan.createdAt
        self.arriveDate = plan.arriveDate
        self.departDate = plan.departDate
        self.title = plan.title
        self.selectedDateArray = plan.selectedDateArray
        self.numberOfDays = plan.numberOfDays
        self.username = plan.username
    }
    
}
