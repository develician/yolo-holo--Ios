//
//  DetailPlanViewModel.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 25..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct DetailPlanViewModel {
    let _id: String
    let planId: String
    let createdAt: Date
    let day: Int
    let destName: String
    let username: String
    
    let latitude: Double
    let longitude: Double
    let placeId: String
    let todoList: [JSON]
    
    init(detailPlan: DetailPlan) {
        self._id = detailPlan._id
        self.planId = detailPlan.planId
        self.createdAt = detailPlan.createdAt
        self.day = detailPlan.day
        self.destName = detailPlan.destName
        self.username = detailPlan.username
        
        self.latitude = detailPlan.latitude
        self.longitude = detailPlan.longitude
        self.placeId = detailPlan.placeId
        self.todoList = detailPlan.todoList

    }
}
