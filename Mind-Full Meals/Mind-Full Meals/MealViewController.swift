//
//  MealViewController.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 6/29/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit
import SQLite3

class MealViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mealRating: RatingControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addMealButton: UIButton!
    
    var meal: Meal?
    var db: OpaquePointer?
    
    //MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Add Meal button while editing
        addMealButton.isEnabled = false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateAddMealButtonState()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Hides the keyboard
        return true
    }
    
    // MARK: Actions
    @IBAction func datePickerChanged(_ sender: Any) {
        setDateLabel()
    }
    
    @IBAction func AddMeal(_ sender: Any)
    {
        //only go back if valid data is entered
        if !(nameTextField.text?.isEmpty ?? true)
        {
            // add conditin for the date
            print("button should work!!!")
            performSegue(withIdentifier: "BackToCalendar", sender: "AddMeal")
        }
                
        // Want to create a MealClass object, then save the object to the database
        let name = nameTextField.text ?? ""
        let date = datePicker.date
        let rating = mealRating.rating
        let ingredients = ["apple", "orange", "banana"]
        // Missing the meal type
        
        meal = Meal(Meal_Name: name, Date: date)
        meal?.SetRating(arg1: rating)
        meal?.SetIngredients(arg1: ingredients)        
        var stmt: OpaquePointer?
        // String to insert the meal into the database
        let queryString = "Insert into Meals (name, rating, date, ingredients) VALUES (?, ?, ?, ?)"
        
        // Preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing insert: \(errmsg)")
            return
        }
        
        // Binding the parameters and throwing error if not ok
        if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_int(stmt, 2, Int32(rating)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error binding rating: \(errmsg)")
            return
        }
        if sqlite3_bind_int(stmt, 3, Int32(convertFromDate(arg1:date))) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error binding date: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 4, convertIngredients(arg1: ingredients), -1, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error binding ingredients: \(errmsg)")
            return
        }
        print("Meal added successfully")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Meal Database")
        // Opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening meal database");
        }
        
        // Creating the meal table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Meals (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, rating INT, date INT, ingredients TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error creating meal table: \(errmsg)")
        }
        
        // Do any additional setup after loading the view.
        setDateLabel() // Shows today's date when starting
        nameTextField.delegate = self // Handle the text field's input through delegate callbacks
        updateAddMealButtonState() // Enable the add meal button only if the meal text field is not empty
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

    // MARK: Private methods
    private func setDateLabel() {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none // No time is shown
        
        let strDate = dateFormatter.string(from: datePicker.date)
        dateLabel.text = strDate // Change the date label
    }
    
    // Converts from Date format to Seconds since 1970-01-01 00:00:00
    private func convertFromDate(arg1:Date) -> Int {
        let date = arg1
        let seconds = date.timeIntervalSince1970
        return Int(seconds)
        
    }
    
    // Converts from seconds since 1970-01-01 00:00:00 to Date format
    private func convertToDate(arg1:Int) -> Date {
        let seconds = Double(arg1)
        let date = Date(timeIntervalSince1970: seconds)
        return date
    }
    
    private func convertIngredients(arg1:Array<String>) -> String {
        let array = arg1
        let str =  array.description
        return str
    }
    
    private func updateAddMealButtonState() {
        // Enable the Add Meal button if the text field isn't empty
        let text = nameTextField.text ?? ""
        addMealButton.isEnabled = !text.isEmpty
    }
}
