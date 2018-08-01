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
    @IBOutlet weak var notifications: UISwitch!
    @IBOutlet weak var whenToNotify: UIDatePicker!
    
    @IBOutlet weak var beforeProgress: UIProgressView!
    @IBOutlet weak var afterProgress: UIProgressView!
    @IBOutlet weak var beforeText: UILabel!
    @IBOutlet weak var afterText: UILabel!
    @IBOutlet weak var recLabel: UILabel!
    
    var db: SQLiteDatabase?
    var averageBefore = Float(0)
    var averageAfter = Float(0)
    var count = Float(0)
    
    //Save and data the user has enterend to be loaded later
    @IBAction func Saved(_ sender: Any) {
        UserDefaults.standard.set(breakfast.date, forKey: "DBT")
        UserDefaults.standard.set(lunch.date, forKey: "DLT")
        UserDefaults.standard.set(dinner.date, forKey: "DDT")
        
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Close the database when switching views
        db?.closeDatabase()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if saved {
            loadProfile()
        }
        
        //connecting to database
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Meal Database")
        do {
            db = try SQLiteDatabase.open(path: fileURL.path)
            print("Connected to database")
        }
        catch SQLiteError.OpenDatabase(let message) {
            print("Unable to open database: \(message)")
            return
        }
        catch {
            print("Another type of error happened: \(error)")
            return
        }
        
        // Creating the meal table
        do {
            try db?.createTable(table: Meal.self)
        }
        catch {
            print(db?.getError() ?? "db is nil")
        }
        
        // Use empty array of tuples to hold the meals. Tuple is (before, after)
        var hungerLevels: [(Int32, Int32)] = []
        do {
            hungerLevels = (try db?.getHungers())!
        }
        catch {
            print(db?.getError() ?? "db is nil")
        }
        // Loop through all meals in database getting total before and after values
        for meal in hungerLevels {
            averageBefore += Float(meal.0)
            averageAfter += Float(meal.1)
            count += 1
        }
        
        // Get average from total div count
        averageBefore /= count
        averageAfter /= count
        
        // Update the progress bars
        beforeProgress.setProgress((averageBefore/10), animated: true)
        afterProgress.setProgress((averageAfter/10), animated: true)
        // Widen the progress bars
        beforeProgress.transform = beforeProgress.transform.scaledBy(x: 1, y: 5)
        afterProgress.transform = afterProgress.transform.scaledBy(x: 1, y: 5)
        // Round the numbers to 1 decimal and set label
        let roundBefore = (10*averageBefore).rounded() / 10
        let roundAfter = (10*averageAfter).rounded() / 10
        beforeText.text = String(roundBefore)
        afterText.text = String(roundAfter)
        
        // Recommends the user based on hunger levels
        recUsers(before: averageBefore, after: averageAfter)
    }

    func loadProfile(){
        breakfast.date = UserDefaults.standard.object(forKey: "DBT") as! Date
        lunch.date = UserDefaults.standard.object(forKey: "DLT") as! Date
        dinner.date = UserDefaults.standard.object(forKey: "DDT") as! Date
        
        let notify = UserDefaults.standard.bool(forKey: "NOTIFY")
        notifications.setOn(notify, animated: false)
        whenToNotify.countDownDuration = UserDefaults.standard.double(forKey: "SECONDS_BEFORE")
        print("loaded")
    }
    
    // Gives the user a suggestion for portion control or food timings based on hunger levels
    func recUsers(before: Float, after: Float) {
        if before < 3 {
            recLabel.text = "Eating Sooner"
        }
        else if after > 7 {
            recLabel.text = "Smaller Portions"
        }
        else if after < 5 {
            recLabel.text = "Larger Portions"
        }
        else if before > 6 {
            recLabel.text = "Eating Later"
        }
        else {
            recLabel.text = "Nothing to recommend"
        }
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
