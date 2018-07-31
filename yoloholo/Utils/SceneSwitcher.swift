//
//  SceneSwitcher.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 29..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit

protocol SceneSwitcherType {
    func presentAuth()
    func presentMain()
}

final class SceneSwitcher: SceneSwitcherType {
    
    let window: UIWindow?
    var loginView: LoginView?
    var mainView: MainView?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func presentAuth() {
        self.window?.rootViewController = self.loginView?.initiateViewController()
    }
    
    func presentMain() {
        self.window?.rootViewController = self.mainView?.initiateViewController()
    }
    
    
}

