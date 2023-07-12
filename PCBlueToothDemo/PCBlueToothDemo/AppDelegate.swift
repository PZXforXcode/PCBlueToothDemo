//
//  AppDelegate.swift
//  PCBlueToothDemo
//
//  Created by 彭祖鑫 on 2023/7/7.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
               // 处理通知权限授权结果
            
           }
        
        UNUserNotificationCenter.current().delegate = self

        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let trigger = notification.request.trigger else { return; }
        if trigger.isKind(of: UNTimeIntervalNotificationTrigger.classForCoder()) {
            print("Notification did receive, Is class UNTimeIntervalNotificationTrigger")
        } else if trigger.isKind(of: UNCalendarNotificationTrigger.classForCoder()) {
            print("Notification did receive, Is class UNCalendarNotificationTrigger")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("后台点击通知回来了")
        
        guard let trigger = response.notification.request.trigger else { return; }
        if trigger.isKind(of: UNTimeIntervalNotificationTrigger.classForCoder()) {
            print("Notification did receive, Is class UNTimeIntervalNotificationTrigger")
        } else if trigger.isKind(of: UNCalendarNotificationTrigger.classForCoder()) {
            print("Notification did receive, Is class UNCalendarNotificationTrigger")
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

