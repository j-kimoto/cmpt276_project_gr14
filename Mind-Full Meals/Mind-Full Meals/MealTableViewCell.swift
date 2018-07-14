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

    func setMeal(meal: Meal) {
        nameLabel.text = meal.GetMealName()
        ratingLabel.text = String(meal.GetRating())
        ingredientsLabel.text = meal.GetIngredients().description
        dateLabel.text = dateToString(mealDate: meal.GetDate())
        typeLabel.text = meal.GetMeal_Type()
        beforeHunger.text = meal.GetBefore()
        afterHunger.text = meal.GetAfter()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func dateToString(mealDate: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none // No time is shown
        
        return dateFormatter.string(from: mealDate)
    }
}
