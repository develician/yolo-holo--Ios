//
//  AppDelegateUtil.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 29..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit

final class AppDelegateUtil {
    static let shared = AppDelegateUtil()
    
    let window = (UIApplication.shared.delegate as! AppDelegate).window
    
    func showAuthView() {
        guard let window = AppDelegateUtil.shared.window else {return}
        let sceneSwitcher = SceneSwitcher(window: window)
        sceneSwitcher.loginView = LoginView(sceneSwitcher: sceneSwitcher)
        sceneSwitcher.presentAuth()
    }
    
    func showMainView() {
        guard let window = AppDelegateUtil.shared.window else {return}
        let sceneSwitcher = SceneSwitcher(window: window)
        sceneSwitcher.mainView = MainView(sceneSwitcher: sceneSwitcher)
        sceneSwitcher.presentMain()
    }
}
