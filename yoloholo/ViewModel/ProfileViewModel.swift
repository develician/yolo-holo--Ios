//
//  ProfileViewModel.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 23..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation
import UIKit

struct ProfileViewModel {
    let username: String
    let thumbnail: String
    
    init(profile: Profile) {
        self.username = profile.username
        self.thumbnail = profile.thumbnail
    }
}
