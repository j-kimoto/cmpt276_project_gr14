//
//  MealViewController.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 6/29/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var afterFullness: UILabel!
    @IBOutlet weak var fullnessSlider: UISlider!
    @IBOutlet weak var afterfullSlider: UISlider!
    let mealTypes = [MealType.Breakfast.rawValue, MealType.Lunch.rawValue, MealType.Dinner.rawValue, MealType.Snacks.rawValue]
    
    var meal: Meal?
    var db: SQLiteDatabase?

    var foods = [Food]() // Passed from FoodTableViewController in backToAddMeal segue
    var editMeal = false // Are we currently editing a meal?
    
    // MARK: Actions
    @IBAction func datePickerChanged(_ sender: Any) {
        setDateLabel()
    }
    
    @IBAction func editFoods(_ sender: Any) {
        storeUserDefault()
    }
    
    @IBAction func fullnessInfo(_ sender: Any) {
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
        meal = createMeal()
        
        var need = Int32(convertFromDate(arg1:(meal?.GetDate())!))
        let tempneed = need%86400
        need = need - tempneed
        UserDefaults.standard.set(meal?.GetMealName(), forKey: String(need))
        
        UserDefaults.standard.set(meal?.GetMealName(), forKey: String(Int32(convertFromDate(arg1:(meal?.GetDate())!))))
        
        // Try to insert a meal into the database and print the error if unsuccessful
        do {
            try db?.insertMeal(meal: meal!)
        }
        catch {
            print(db?.getError() ?? "db is nil")
        }
        
        // Get the first meal in the db
        do {
            let first = try db?.meal(id: 1)
            print("====== Printing first meal in database:")
            print(first ?? "no meal with id=1")
        }
        catch {
            print(error)
        }

        clearUserDefault()
    }
    
    // Sets the fullness label whenever the slider's value changes
    @IBAction func fullnessChanged(_ sender: UISlider) {
        // Sliders are floats so round it, then cast to integer
        let fullnessInt = Int(round(sender.value))
        currentFullness.text = String(fullnessInt)
    }
    
    @IBAction func afterFullnessChanged(_ sender: UISlider) {
        let fullnessInt = Int(round(sender.value))
        afterFullness.text = String(fullnessInt)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Meal Database")
        
        // Open database and catch errors
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

        // Creating the meal table if it doesn't exist already
        do {
            try db?.createTable(table: Meal.self)
        }
        catch {
            print(db?.getError() ?? "db is nil")
        }
        
        // Do any additional setup after loading the view.
        nameTextField.delegate = self // Handle the text field's input through delegate callbacks
        //updateAddMealButtonState() // Enable the add meal button only if the meal text field is not empty
        
        // Handle the meal type picker's input through delegate callbacks
        typePicker.delegate = self
        typePicker.dataSource = self
    }
    
    // Called after view is added to view hierarchy since UIPickerView's titleForRow is called after viewDidLoad()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        retrieveUserDefaults()
        updateAddMealButtonState() // Enable the add meal button only if the meal text field is not empty
        setDateLabel() // Set the date label after loading the stored date
        
        // Set the labels so you can edit the meal info
        if (editMeal) {
            setLabels(oldMeal: meal!)
            editMeal = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /*// Close the database when switching views
        sqlite3_close(db)
        print("Closed the database")*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // MARK: - Navigation
     // This segue passes the meal's food back and forth, so food can be seen the second time
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier ?? "" == "goToFoodTable" {
            let navVC = segue.destination as! UINavigationController // The segue goes to the navigation controller
            let foodTVC = navVC.viewControllers.first as! FoodTableViewController
            foodTVC.foods = foods
        }
     }
    
    // Save all values in fields
    func storeUserDefault() {
        UserDefaults.standard.set(nameTextField.text, forKey:"udname") // String
        UserDefaults.standard.set(mealRating.rating, forKey:"udrating") // Int
        UserDefaults.standard.set(datePicker.date, forKey:"uddate") // Date is stored as Any object
        UserDefaults.standard.set(typePicker.selectedRow(inComponent: 0), forKey:"udtype") // Int
        print("Store: Selected row is \(typePicker.selectedRow(inComponent: 0)) which is \(mealTypes[typePicker.selectedRow(inComponent: 0)] )")
        UserDefaults.standard.set(currentFullness.text, forKey:"udbeforefull") // String
        UserDefaults.standard.set(afterFullness.text, forKey:"udafterfull") // String
    }
    
    // On first run, the values may be nil
    func retrieveUserDefaults() {
        nameTextField.text = UserDefaults.standard.string(forKey:"udname") ?? ""
        mealRating.rating = UserDefaults.standard.integer(forKey:"udrating")
        // as? casts the Any? object to optionally cast to Date object. ?? uses new object if key is nil. setDateLabel() is called later
        datePicker.date = UserDefaults.standard.object(forKey: "uddate") as? Date ?? Date()
        print("Retrieve: Selected row is \(UserDefaults.standard.integer(forKey:"udtype")) which is \(mealTypes[UserDefaults.standard.integer(forKey:"udtype")])" )      
        typePicker.selectRow(UserDefaults.standard.integer(forKey:"udtype"), inComponent: 0, animated: true)
        setFullness(UserDefaults.standard.string(forKey:"udbeforefull") ?? "", fullnessSlider, currentFullness)
        setFullness(UserDefaults.standard.string(forKey:"udafterfull") ?? "", afterfullSlider, afterFullness)
        
    }
    
    func clearUserDefault() {
        UserDefaults.standard.removeObject(forKey: "udname")
        UserDefaults.standard.removeObject(forKey: "udrating")
        UserDefaults.standard.removeObject(forKey: "uddate")
        UserDefaults.standard.removeObject(forKey: "udtype")
        UserDefaults.standard.removeObject(forKey: "udbeforefull")
        UserDefaults.standard.removeObject(forKey: "udafterfull")
    }
    
    // MARK: Private methods
    
    // Uses input fields to return a meal
    private func createMeal() -> Meal {
        let name = nameTextField.text ?? ""
        let rating = mealRating.rating // 0 if not changed
        let ingredients = convertToStringArray(array: foods)
        let date = datePicker.date
        let type = mealTypes[typePicker.selectedRow(inComponent: 0)] // Index -> String
        let beforefull = currentFullness.text ?? ""
        let afterfull = afterFullness.text ?? ""
        
        return Meal(Meal_Name: name, Rating: rating, Ingredients: ingredients, Date: date, Meal_Type: type, Before: beforefull, After: afterfull)
    }
    
    // Setting labels to edit the meal. Meal type and food are not restored
    private func setLabels(oldMeal: Meal) {
        nameTextField.text = meal?.GetMealName()
        mealRating.rating = (meal?.GetRating())!
        //foods = meal?.GetIngredients()
        datePicker.date = (meal?.GetDate())!
        setDateLabel()
        //typePicker.selectRow(<#T##row: Int##Int#>, inComponent: <#T##Int#>, animated: <#T##Bool#>)
        setFullness((meal?.GetBefore())!, fullnessSlider, currentFullness)
        setFullness((meal?.GetAfter())!, afterfullSlider, afterFullness)
    }
    
    // Sets the fullness label and slider
    private func setFullness(_ fullness: String, _ sender: UISlider!, _ tlabel: UILabel) {
        tlabel.text = fullness
        sender.setValue(Float(fullness) ?? 1.0, animated: true)
    }
    
    private func setDateLabel() {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.medium // Time format like 3:30:32 PM
        
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
    /*
    // Combines the date into format YYYYMMDD
    private func combineDate(arg1: Date) -> Int {
        let cDay = Calendar.current.component(.day, from: arg1)
        let cMonth = Calendar.current.component(.month, from: arg1)
        let cYear = Calendar.current.component(.year, from: arg1)
        let ret = (cYear * 10000) + (cMonth * 100) + cDay
        return ret
    }
    
    // Combines the time into format HHMM in 24 hour clock format
    private func combineTime(arg1: Date) -> Int {
        let cHour = Calendar.current.component(.hour, from: arg1)
        let cMin = Calendar.current.component(.minute, from: arg1)
        let ret = (cHour*100) + cMin
        return ret
    }
    */
    
    // Converts an array (of ingredients) to a comma separated string
    private func convertIngredients(arg1:Array<String>) -> String {
        let array = arg1
        //let str =  array.description
        let str = array.joined(separator: ",")
        return str
    }
    
    // Converts from Food array to String array
    private func convertToStringArray(array: [Food]) -> [String] {
        var strArray = [String]()
        for item in array {
            strArray.append(item.description)
        }
        return strArray
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
