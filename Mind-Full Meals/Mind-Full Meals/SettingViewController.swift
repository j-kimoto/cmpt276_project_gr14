//
//  SettingViewController.swift
//  Mind-Full Meals
//
//  Created by Jason Kimoto on 7/17/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit
import UserNotifications
var saved = false

class SettingViewController: UIViewController {

    //all the info that can be saved
    @IBOutlet weak var breakfast: UIDatePicker!
    @IBOutlet weak var lunch: UIDatePicker!
    @IBOutlet weak var dinner: UIDatePicker!
    @IBOutlet weak var age: UISegmentedControl!
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var notifications: UISwitch!
    @IBOutlet weak var whenToNotify: UIDatePicker!
    
    //Save and data the user has enterend to be loaded later
    @IBAction func Saved(_ sender: Any) {
        UserDefaults.standard.set(breakfast.date, forKey: "DBT")
        UserDefaults.standard.set(lunch.date, forKey: "DLT")
        UserDefaults.standard.set(dinner.date, forKey: "DDT")
        UserDefaults.standard.set(age.selectedSegmentIndex, forKey: "AGE")
        UserDefaults.standard.set(gender.selectedSegmentIndex, forKey: "GENDER")
        
        UserDefaults.standard.set(notifications.isOn, forKey: "NOTIFY")
        UserDefaults.standard.set(whenToNotify.countDownDuration, forKey: "SECONDS_BEFORE")
        print("saved")
        saved = true
        
        if notifications.isOn {
            // Turn on notifications
            enableNotifications()
        }
        else {
            // Turn off notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if saved {
            loadProfile()
        }
    }

    func loadProfile(){
        breakfast.date = UserDefaults.standard.object(forKey: "DBT") as! Date
        lunch.date = UserDefaults.standard.object(forKey: "DLT") as! Date
        dinner.date = UserDefaults.standard.object(forKey: "DDT") as! Date
        age.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "AGE")
        gender.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "GENDER")
        
        let notify = UserDefaults.standard.bool(forKey: "NOTIFY")
        notifications.setOn(notify, animated: false)
        whenToNotify.countDownDuration = UserDefaults.standard.double(forKey: "SECONDS_BEFORE")
        print("loaded")
    }
    
    func enableNotifications(){
        // Sources: https://developer.apple.com/documentation/usernotifications/scheduling_a_notification_locally_from_your_app and https://www.appcoda.com/ios10-user-notifications-guide/
        
        // Get the notification center
        let center =  UNUserNotificationCenter.current()
        
        // Request permission to display alerts, play sounds, and change app badge
        center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            // Enable or disable features based on authorization
            if !granted {
                print("Notifications not enabled")
            }
            else {
                print("Enabling notifications")
            }
        })
        
        // Schedule breakfast, lunch, dinner, and snacks
        // saved is true so dates shouldn't be nil
        let bTime = UserDefaults.standard.object(forKey: "DBT") as! Date // breakfast
        let lTime = UserDefaults.standard.object(forKey: "DLT") as! Date // lunch
        let dTime = UserDefaults.standard.object(forKey: "DDT") as! Date // dinner
        let timeBefore = whenToNotify.countDownDuration        // time before meal to notify you
        
        print("Time before: \(timeBefore), Breakfast time: \(bTime), lunch time: \(lTime), dinner time: \(dTime), notify lunch at \(lTime.addingTimeInterval(-timeBefore))")
        
        // The negative of the time interval subtracts that time from the date
        scheduleNotifications(at: bTime.addingTimeInterval(-timeBefore), title: "Breakfast", body: "It's time to cook/eat/buy breakfast")
        scheduleNotifications(at: lTime.addingTimeInterval(-timeBefore), title: "Lunch", body: "It's time to cook/eat/buy lunch")
        scheduleNotifications(at: dTime.addingTimeInterval(-timeBefore), title: "Dinner", body: "It's time to cook/eat/buy dinner")
    }
    
    func scheduleNotifications(at date: Date, title: String, body: String) {
        let center =  UNUserNotificationCenter.current()

        // Saves components of date to trigger it daily at that hour and minute
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        
        // Triggers the notification at the given hour and minute every day
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        
        // Create the request
        let request = UNNotificationRequest(identifier: title, content: content, trigger: trigger)
        
        // Add request to notification center
        center.add(request) { (error) in
            if let error = error {
                // Handle any errors
                print("We have an error: \(error)")
            }
        }
    }
    
}
