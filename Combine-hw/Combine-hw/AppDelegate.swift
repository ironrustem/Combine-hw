//
//  AppDelegate.swift
//  Combine-hw
//
//  Created by wrustem on 09.11.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let navigationController = UINavigationController(rootViewController: ViewController())
        navigationController.navigationBar.prefersLargeTitles = true
        UINavigationBar.appearance().backgroundColor = UIColor(named: "Colors/NavigationBar")
        window?.rootViewController = navigationController
        return true
    }
}

