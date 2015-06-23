//
//  AppDelegate.swift
//  SlidingTabBar
//
//  Created by Mike on 6/19/15.
//  Copyright © 2015 Mike Perry. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        
        let vc1 = UIViewController()
        vc1.view.backgroundColor = UIColor.yellowColor()
        vc1.title = "First"
        let vc2 = UIViewController()
        vc2.view.backgroundColor = UIColor.orangeColor()
        vc2.title = "Second"
        let vc3 = UIViewController()
        vc3.view.backgroundColor = UIColor.purpleColor()
        vc3.title = "Third"
        let vc4 = UIViewController()
        vc4.view.backgroundColor = UIColor.blueColor()
        vc4.title = "Fourth"
        let vc5 = UIViewController()
        vc5.view.backgroundColor = UIColor.magentaColor()
        vc5.title = "Fifth"
        let vc6 = UIViewController()
        vc6.view.backgroundColor = UIColor.greenColor()
        vc6.title = "Sixth"
        let vc7 = UIViewController()
        vc7.view.backgroundColor = UIColor.redColor()
        vc7.title = "Seventh"
        
        let tabBarController = SlidingTabBarController()
        tabBarController.setViewControllers([vc1, vc2, vc3, vc4, vc5, vc6, vc7], animated: false)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

