//
//  NotificationDelegate.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 2018-07-27.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

/* The purpose of this class is to show notifications (not in the notification center) when the app is in the foreground */

//import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    // Required to show notification when in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}
