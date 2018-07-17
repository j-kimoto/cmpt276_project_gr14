//
//  MealTableViewCell.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 7/12/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

/* Shows a meal object's fields in the table view */

import UIKit

class MealTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var beforeHunger: UILabel!
    @IBOutlet weak var afterHunger: UILabel!

    // Sets the table cell text to the meal object's properties
    func setMeal(meal: Meal) {
        nameLabel.text = meal.GetMealName()
        ratingLabel.text = String(meal.GetRating())
        ingredientsLabel.text = convertIngredients(arg1: meal.GetIngredients())
        dateLabel.text = dateToString(mealDate: meal.GetDate())
        typeLabel.text = meal.GetMeal_Type()
        beforeHunger.text = meal.GetBefore()
        afterHunger.text = meal.GetAfter()
    }

    // Returns a text representation of the date parameter
    private func dateToString(mealDate: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.medium
        
        return dateFormatter.string(from: mealDate)
    }
    
    // Converts the array of ingredients to a string
    private func convertIngredients(arg1:Array<String>) -> String {
        let array = arg1
        let str = array.joined(separator: ",")
        return str
    }
}
