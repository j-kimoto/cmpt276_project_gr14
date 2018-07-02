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
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mealRating: RatingControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: Actions
    @IBAction func SaveMeal(_ sender: UIButton) {
        mealNameLabel.text = "Test add meal button"
        
        // Want to create a MealClass object, then save the object to the database
        let newMeal = Meal(Meal_Name: nameTextField.text!, Date: datePicker.date)
        newMeal.SetRating(arg1: mealRating.rating)
        newMeal.SetIngredients(arg1: ["apple", "orange", "banana"])
        
        print("Meal name is \(newMeal.GetMealName()), rating is \(newMeal.GetRating()), ingredients are \(newMeal.GetIngredients()), date is \(newMeal.GetDate()).")
    }
    private func setDateLabel() {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none // No time is shown
        
        let strDate = dateFormatter.string(from: datePicker.date)
        dateLabel.text = strDate // Change the date label
    }
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setDateLabel() // Shows today's date when starting
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

}
