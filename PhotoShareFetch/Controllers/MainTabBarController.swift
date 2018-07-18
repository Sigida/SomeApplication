//
//  MainTabBarController.swift
//  PhotoShareFetch
//
//  Created by Admin on 18.07.2018.
//  Copyright © 2018 roshy. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        tabBar.unselectedItemTintColor = .black
    }
}
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == 1 {
            // present photo taking action sheet
            print("take photo")
            
            return false
        } else {
            return true
        }
    }    
}
