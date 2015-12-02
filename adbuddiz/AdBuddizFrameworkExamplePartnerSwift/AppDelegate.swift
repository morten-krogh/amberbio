//
//  AppDelegate.swift
//  Copyright (c) 2014 Purple Brain. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        AdBuddiz.setLogLevel(ABLogLevelInfo)           // log level
        AdBuddiz.setPublisherKey("TEST_PUBLISHER_KEY") // replace with your app publisher key
        AdBuddiz.setTestModeActive()                   // to delete before submitting to store
        
        AdBuddiz.cacheAds()                            // start caching ads
    }
    
    func applicationWillResignActive(application: UIApplication) {}
    func applicationDidEnterBackground(application: UIApplication) {}
    func applicationWillEnterForeground(application: UIApplication) {}
    func applicationWillTerminate(application: UIApplication) {}
}

