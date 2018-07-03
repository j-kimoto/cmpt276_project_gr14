//
//  MealViewController.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 6/29/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

class MealViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mealRating: RatingControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addMealButton: UIButton!
    
    var meal: Meal?
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    private func updateAddMealButtonState() {
        // Enable the Add Meal button if the text field isn't empty
        let text = nameTextField.text ?? ""
        addMealButton.isEnabled = !text.isEmpty
    }
}
