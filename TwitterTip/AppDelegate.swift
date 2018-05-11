//
//  AppDelegate.swift
//  TwitterTip
//
//  Created by 辻林 大揮 on 2018/05/10.
//  Copyright © 2018年 chocovayashi. All rights reserved.
//

import UIKit
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: "fgfMRSHKYnRZ2Ow2U8QLzpC4r", consumerSecret: "puj0qD6G6lo4llF6mUeWpFDhMvnrvfixvpPiwxGSOcvW5hEGLU")
        
        let sb = UIStoryboard(name: "Main",bundle:nil)
        if UserDefaults.standard.string(forKey: "userName") != nil {
            window?.rootViewController = sb.instantiateInitialViewController()!
        } else {
            window?.rootViewController = sb.instantiateViewController(withIdentifier: "Login")
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if TWTRTwitter.sharedInstance().application(app, open: url, options: options) {
            return true
        }
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}
