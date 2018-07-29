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
    
    //Save and data the user has enterend to be loaded later
    @IBAction func Saved(_ sender: Any) {
        UserDefaults.standard.set(breakfast.date, forKey: "DBT")
        UserDefaults.standard.set(lunch.date, forKey: "DLT")
        UserDefaults.standard.set(dinner.date, forKey: "DDT")
        UserDefaults.standard.set(age.selectedSegmentIndex, forKey: "AGE")
        UserDefaults.standard.set(gender.selectedSegmentIndex, forKey: "GENDER")
        UserDefaults.standard.set(notifications.isOn, forKey: "NOTIFY")
        print("saved")
        saved = true
        
        // Check if the switch is on
        if notifications.isOn {
            // Turn on notifications
            enableNotifications()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if saved {
            loadProfile()
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadProfile(){
        breakfast.date = UserDefaults.standard.object(forKey: "DBT") as! Date
        lunch.date = UserDefaults.standard.object(forKey: "DLT") as! Date
        dinner.date = UserDefaults.standard.object(forKey: "DDT") as! Date
        age.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "AGE")
        gender.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "GENDER")
        
        let notify = UserDefaults.standard.bool(forKey: "NOTIFY")
        notifications.setOn(notify, animated: false)
        print("loaded")
    }
    
    func enableNotifications(){
        // Sources: https://developer.apple.com/documentation/usernotifications/scheduling_a_notification_locally_from_your_app and https://medium.com/@dkw5877/local-notifications-in-ios-156a03b81ceb
        
        // Get the notification center
        let center =  UNUserNotificationCenter.current()
        
        // Request permission to display alerts, play sounds, and change app badge
        center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            // Enable or disable features based on authorization
            if error != nil {
                print("Notifications not enabled")
            }
            else {
                print("Enabling notifications")
            }
        })

        
        // Don't schedule notifications if not authorized
        center.getNotificationSettings(completionHandler: { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            
            if settings.alertSetting == .enabled {
                // Schedule an alert-only notification
            }
            else {
                // Schedule a notification with a badge and sound
            }
        })
        
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = " Test title"
        content.subtitle = "Lunch"
        content.body = "It's time to cook lunch"
        //content.categoryIdentifier = "message"
        content.sound = UNNotificationSound.default()
        
        /*// Trigger notification to show every Friday at 9:30pm
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        
        dateComponents.weekday = 5 // Friday
        dateComponents.hour = 21
        dateComponents.minute = 30 */
        
        // Create the trigger as a repeating event
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Should show notification in 2 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
        
        // Create the request
        let identifier = "LunchNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Add request to notification center
        center.add(request) { (error) in
            if error != nil {
                // Handle any errors
            }
        }
    }
    
    func scheduleNotifications() {
        
    }
    
}
