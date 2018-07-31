//
//  DetailPlan.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 25..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation
import SwiftyJSON
import GoogleMaps

struct DetailPlan {
    let _id: String
    let planId: String
    let createdAt: Date
    let day: Int
    let destName: String
    let username: String
    
    var latitude: Double?
    var longitude: Double?
    var placeId: String?
    let todoList: [JSON]
    
    init(json: JSON) {
        guard let _idJSON = json["_id"].string else {fatalError("parsing Error")}
        guard let planIdJSON = json["planId"].string else {fatalError("parsing Error")}
        guard let createdAtJSON = json["createdAt"].date else {fatalError("parsing Error")}
        guard let dayJSON = json["day"].int else {fatalError("parsing Error")}
        guard let destNameJSON = json["destName"].string else {fatalError("parsing Error")}
        guard let usernameJSON = json["username"].string else {fatalError("parsing Error")}
        
//        guard let latitudeJSON = json["latitude"].double ?? nil else {fatalError("parsing Error")}
        if let latitudeJSON = json["latitude"].double, let longitudeJSON = json["longitude"].double, let placeIdJSON = json["placeId"].string {
            self.latitude = latitudeJSON
            self.longitude = longitudeJSON
            self.placeId = placeIdJSON
        } else {
            self.latitude = nil
            self.longitude = nil
            self.placeId = nil
        }
//        guard let longitudeJSON = json["longitude"].double ?? nil else {fatalError("parsing Error")}
//        guard let placeIdJSON = json["placeId"].string ?? nil else {fatalError("parsing Error")}
        guard let todoListJSON = json["todoList"].array else {fatalError("parsing Error")}

        self._id = _idJSON
        self.planId = planIdJSON
        self.createdAt = createdAtJSON
        self.day = dayJSON
        self.destName = destNameJSON
        self.username = usernameJSON
        
        
        self.todoList = todoListJSON
    }
}
