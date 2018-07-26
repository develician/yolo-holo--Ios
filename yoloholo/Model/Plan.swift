//
//  Plan.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 24..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Plan {
    let _id: String
    let createdAt: Date
    let arriveDate: Date
    let departDate: Date
    let title: String
    let selectedDateArray: [JSON]
    let numberOfDays: Int
    let username: String
    
    init(json: JSON) {
        guard let _idJSON = json["_id"].string else {fatalError("parsing error")}
        guard let createdAtJSON = json["createdAt"].date else {fatalError("parsing error")}
        guard let arriveDateJSON = json["arriveDate"].date else {fatalError("parsing error")}
        guard let departDateJSON = json["departDate"].date else {fatalError("parsing error")}
        guard let titleJSON = json["title"].string else {fatalError("parsing error")}
        guard let selectedDateArrayJSON = json["selectedDateArray"].array else {fatalError("parsing error")}

        
        guard let numberOfDaysJSON = json["numberOfDays"].int else {fatalError("parsing error")}
        guard let usernameJSON = json["username"].string else {fatalError("parsing error")}

        self._id = _idJSON
        self.createdAt = createdAtJSON
        self.arriveDate = arriveDateJSON
        self.departDate = departDateJSON
        self.title = titleJSON
        self.selectedDateArray = selectedDateArrayJSON
        self.numberOfDays = numberOfDaysJSON
        self.username = usernameJSON


    }
}

extension JSON {
    public var date: Date? {
        get {
            if let str = self.string {
                let date = JSON.jsonDateFormatter.date(from: str)
                return date
            }
            return nil
        }
    }
    
    private static let jsonDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        fmt.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone!
        return fmt
    }()
}
