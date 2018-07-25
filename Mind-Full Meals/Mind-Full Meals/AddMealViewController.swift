//
//  AddMealViewController.swift
//  Mind-Full Meals
//
//  Created by jbengco on 7/20/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

class AddMealViewController: UIViewController {
    
    @IBAction func breakfastButton(_ sender: Any) {
        UserDefaults.standard.set(0, forKey:"udtype") // Int
        let bTime = UserDefaults.standard.object(forKey: "DBT") as? Date ?? Date()
        if saved {
            print("BREAKFAST TIME:", bTime)
            UserDefaults.standard.set(bTime, forKey:"uddate") // Date is stored as Any object
        }
        else {
            print("UNSAVED TIME")
            UserDefaults.standard.set(setDateTime(hour: 7, min: 0), forKey:"uddate") // Date is stored as Any object
        }
        
    }
    
    @IBAction func lunchButton(_ sender: Any) {
        UserDefaults.standard.set(1, forKey:"udtype") // Int
        let lTime = UserDefaults.standard.object(forKey: "DBT") as? Date ?? Date()
        if saved {
            print("LUNCH TIME:", lTime)
            UserDefaults.standard.set(lTime, forKey:"uddate") // Date is stored as Any object
        }
        else {
            print("UNSAVED TIME")
            UserDefaults.standard.set(setDateTime(hour: 13, min: 0), forKey:"uddate") // Date is stored as Any object
        }
    }
    
    @IBAction func dinnerButton(_ sender: Any) {
        UserDefaults.standard.set(2, forKey:"udtype") // Int
        let dTime = UserDefaults.standard.object(forKey: "DBT") as? Date ?? Date()
        if saved {
            print("DINNER TIME:", dTime)
            UserDefaults.standard.set(dTime, forKey:"uddate") // Date is stored as Any object
        }
        else {
            print("UNSAVED TIME")
            UserDefaults.standard.set(setDateTime(hour: 18, min: 0), forKey:"uddate") // Date is stored as Any object
        }
    }
    
    @IBAction func snackButton(_ sender: Any) {
        UserDefaults.standard.set(3, forKey:"udtype") // Int
    }

    private func setDateTime(hour: Int, min: Int) -> Date {
        let date = Calendar.current.date(bySettingHour: hour, minute: min, second: 0, of: Date())!
        return date
    }
}
