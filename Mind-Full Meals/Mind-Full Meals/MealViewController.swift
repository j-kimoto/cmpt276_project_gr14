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
    
    // MARK: Actions
    @IBAction func addMeal(_ sender: UIButton) {
        mealNameLabel.text = "Test add meal button"
        
        // Want to create a MealClass object, then save the object to the database
        let newMeal = Meal()
        newMeal.SetMealName(arg1: nameTextField.text!)
        newMeal.SetRating(arg1: mealRating.rating)
        newMeal.SetIngredients(arg1: ["apple", "orange", "banana"])
        newMeal.SetDate(arg1: [1, 2, 3])
        
        print("Meal name is \(newMeal.GetMealName()), rating is \(newMeal.GetRating()), ingredients are \(newMeal.GetIngredients()), date is \(newMeal.GetDate()).")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

}
