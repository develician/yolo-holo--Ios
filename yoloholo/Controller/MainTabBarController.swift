//
//  MainTabBarController.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 23..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let planListController = PlanListController()
        planListController.tabBarItem = UITabBarItem(title: "일정", image: UIImage(named: "plan"), selectedImage: UIImage(named: "plan_filled"))
        
        let settingViewController = SettingViewController()
        settingViewController.tabBarItem = UITabBarItem(title: "설정", image: UIImage(named: "setting"), selectedImage: UIImage(named: "setting_filled"))
        let viewControllers = [planListController, settingViewController]
        self.viewControllers = viewControllers.map {
            viewController in
            let naviController = MainNaviController(rootViewController: viewController)
            return naviController
//            UINavigationController(rootViewController: $0)
        }
    }


}
