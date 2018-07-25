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
        //let bTime = UserDefaults.standard.object(forKey: "DBT") as? Date ?? Date()
        //UserDefaults.standard.set(setDatePicker(arg1: bTime), forKey:"uddate") // Date is stored as Any object
        UserDefaults.standard.set(setDatePicker(arg1: "2018-07-20 07:00"), forKey:"uddate") // Date is stored as Any object
        
    }
    
    @IBAction func lunchButton(_ sender: Any) {
        UserDefaults.standard.set(1, forKey:"udtype") // Int
        //let lTime = UserDefaults.standard.object(forKey: "DLT") as? Date ?? Date()
        UserDefaults.standard.set(setDatePicker(arg1: "2018-07-20 13:00"), forKey:"uddate") // Date is stored as Any object
    }
    
    @IBAction func dinnerButton(_ sender: Any) {
        UserDefaults.standard.set(2, forKey:"udtype") // Int
        //let dTime = UserDefaults.standard.object(forKey: "DDT") as? Date ?? Date()
        UserDefaults.standard.set(setDatePicker(arg1: "2018-07-20 18:00"), forKey:"uddate") // Date is stored as Any object
    }
    
    @IBAction func snackButton(_ sender: Any) {
        UserDefaults.standard.set(3, forKey:"udtype") // Int
    }
    
    private func setDatePicker(arg1: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        //dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.date(from:arg1)
        return time!
    }
}
