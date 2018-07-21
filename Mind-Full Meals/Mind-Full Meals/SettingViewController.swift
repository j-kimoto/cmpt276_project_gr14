//
//  SettingViewController.swift
//  Mind-Full Meals
//
//  Created by Jason Kimoto on 7/17/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit
var saved = false
class SettingViewController: UIViewController {

    //all the info that can be saved
    @IBOutlet weak var breakfast: UIDatePicker!
    @IBOutlet weak var lunch: UIDatePicker!
    @IBOutlet weak var dinner: UIDatePicker!
    @IBOutlet weak var age: UISegmentedControl!
    @IBOutlet weak var gender: UISegmentedControl!
    
    //Save and data the user has enterend to be loaded later
    @IBAction func Saved(_ sender: Any) {
        UserDefaults.standard.set(breakfast.date, forKey: "DBT")
        UserDefaults.standard.set(lunch.date, forKey: "DLT")
        UserDefaults.standard.set(dinner.date, forKey: "DDT")
        UserDefaults.standard.set(age.selectedSegmentIndex, forKey: "AGE")
        UserDefaults.standard.set(gender.selectedSegmentIndex, forKey: "GENDER")
        print("saved")
        saved = true
        
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
        print("loaded")
    }
    
    
    
}
