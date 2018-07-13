//
//  SettingsViewController.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 6/29/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

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
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfile()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func loadProfile(){
        breakfast.date = UserDefaults.standard.object(forKey: "DBT") as! Date
        lunch.date = UserDefaults.standard.object(forKey: "DLT") as! Date
        dinner.date = UserDefaults.standard.object(forKey: "DDT") as! Date
        age.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "AGE")
        gender.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "GENDER")
        print("loaded")
    }

}
