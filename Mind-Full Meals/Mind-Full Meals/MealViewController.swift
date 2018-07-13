//
//  MealViewController.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 6/29/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

//let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
//let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

import UIKit
import SQLite3

class MealViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mealRating: RatingControl!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var addMealButton: UIButton!
    @IBOutlet weak var editFoods: UIButton!
    @IBOutlet weak var typePicker: UIPickerView!
    
    @IBOutlet weak var currentFullness: UILabel!
    @IBOutlet weak var fullnessSlider: UISlider!
    let mealTypes = [MealType.Breakfast.rawValue, MealType.Lunch.rawValue, MealType.Dinner.rawValue, MealType.Snacks.rawValue]
    
    var meal: Meal?
    var db: OpaquePointer?
    var ingredients = [String]() // Passed from FoodTableViewController in backToAddMeal segue
    
    // MARK: Actions
    @IBAction func datePickerChanged(_ sender: Any) {
        setDateLabel()
    }
    
    @IBAction func editFoods(_ sender: Any) {
        storeUserDefault()
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
        
        // Want to create a Meal object, then save the object to the database
        let name = nameTextField.text ?? ""
        let rating = mealRating.rating // 0 if not changed
        let date = datePicker.date
        let type = mealTypes[typePicker.selectedRow(inComponent: 0)] // Index -> String
        
        /* meal = Meal(Meal_Name: name, Date: date)
         meal?.SetRating(arg1: rating)
         meal?.SetIngredients(arg1: ingredients)
         meal?.SetMeal_Type(arg1: type) */
        meal = Meal(Meal_Name: name, Rating: rating, Ingredients: ingredients, Date: date, Meal_Type: type)
        
        print("\nMeal object data:")
        print(meal ?? "Meal is nil")
        print("------------\n")
        
        var stmt: OpaquePointer?
        // String to insert the meal into the database
        let queryString = "Insert into Meals (name, rating, date, ingredients, type) VALUES (?, ?, ?, ?, ?)"
        var need = Int32(convertFromDate(arg1:date))
        var tempneed = need%86400
        need = need - tempneed
        UserDefaults.standard.set(name, forKey: String(need))
        
        // Preparing the query
        prepareStatement(db, queryString, &stmt)

        UserDefaults.standard.set(name, forKey: String(Int32(convertFromDate(arg1:date))))
        // Binding the parameters and throwing error if not ok
        bindText(db, stmt, 1, name, "name")
        bindInt(db, stmt, 2, Int32(rating), "rating")
        bindInt(db, stmt, 3, Int32(convertFromDate(arg1:date)), "date")
        bindText(db, stmt, 4, convertIngredients(arg1: ingredients), "ingredients")
        bindText(db, stmt, 5, type, "type")
        
        print("Data before insert: \(name)\n\(Int32(rating))\n\(convertIngredients(arg1: ingredients))\n\(Int32(convertFromDate(arg1:date)))\n\(type)")
        print("------------\n")
        
        // Insert the meal
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Error inserting meal: \(errmsg)")
            return
        }
        print("Meal added successfully")
        clearUserDefault()
        
        // Delete the prepared statement to release its memory (it can't be used anymore)
        sqlite3_finalize(stmt)
    }
    
    // Sets the fullness label whenever the slider's value changes
    @IBAction func fullnessChanged(_ sender: UISlider) {
        // Sliders are floats so round it, then cast to integer
        let fullnessInt = Int(round(sender.value))
        currentFullness.text = String(fullnessInt)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Opening the database
        db = openDatabase()
        
        // Creating the meal table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Meals (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, rating INT, date INT, ingredients TEXT, type TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error creating meal table: \(errmsg)")
        }
        
        // Do any additional setup after loading the view.
        nameTextField.delegate = self // Handle the text field's input through delegate callbacks
        updateAddMealButtonState() // Enable the add meal button only if the meal text field is not empty
        
        // Handle the meal type picker's input through delegate callbacks
        typePicker.delegate = self
        typePicker.dataSource = self
    }
    
    // Called after view is added to view hierarchy since UIPickerView's titleForRow is called after viewDidLoad()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        retrieveUserDefaults()
        setDateLabel() // Set the date label after loading the stored date
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Close the database when switching views
        sqlite3_close(db)
        print("Closed the database")
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
    
    // Save all values in fields
    func storeUserDefault() {
        UserDefaults.standard.set(nameTextField.text, forKey:"udname") // String
        UserDefaults.standard.set(mealRating.rating, forKey:"udrating") // Int
        UserDefaults.standard.set(datePicker.date, forKey:"uddate") // Date is stored as Any object
        UserDefaults.standard.set(typePicker.selectedRow(inComponent: 0), forKey:"udtype") // Int
        UserDefaults.standard.set(currentFullness.text, forKey:"udFullness") // String
    }
    
    // On first run, the values may be nil
    func retrieveUserDefaults() {
        nameTextField.text = UserDefaults.standard.string(forKey:"udname") ?? ""
        mealRating.rating = UserDefaults.standard.integer(forKey:"udrating")
        // as? casts the Any? object to optionally cast to Date object. ?? uses new object if key is nil. setDateLabel() is called later
        datePicker.date = UserDefaults.standard.object(forKey: "uddate") as? Date ?? Date()
        typePicker.selectRow(UserDefaults.standard.integer(forKey:"udtype"), inComponent: 0, animated: true)
        setFullness(UserDefaults.standard.string(forKey:"udFullness") ?? "", fullnessSlider)
    }
    
    func clearUserDefault() {
        UserDefaults.standard.removeObject(forKey: "udname")
        UserDefaults.standard.removeObject(forKey: "udrating")
        UserDefaults.standard.removeObject(forKey: "uddate")
        UserDefaults.standard.removeObject(forKey: "udtype")
        UserDefaults.standard.removeObject(forKey: "udFullness")
    }
    
    // MARK: Private methods
    
    // Sets the fullness label and slider
    private func setFullness(_ fullness: String, _ sender: UISlider!) {
        currentFullness.text = fullness
        sender.setValue(Float(fullness) ?? 1.0, animated: true)
    }
    
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
    
    // Enable the Add Meal button if the text field isn't empty
    private func updateAddMealButtonState() {
        let text = nameTextField.text ?? ""
        addMealButton.isEnabled = !text.isEmpty
    }
}

//MARK: UITextFieldDelegate
extension MealViewController: UITextFieldDelegate {
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
}

//MARK: UIPickerViewDataSource
extension MealViewController: UIPickerViewDataSource {
    // The number of columns (components) in the picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // The number of rows in the picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mealTypes.count
    }
}

//MARK: UIPickerViewDelegate
extension MealViewController: UIPickerViewDelegate {
    // The content of each row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mealTypes[row]
    }
}
