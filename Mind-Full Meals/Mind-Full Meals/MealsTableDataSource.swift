//
//  MealsTableDataSource.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 7/12/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

/* Represents an array of meals */

import UIKit

class MealsTableDataSource: NSObject {
    var meals: [Meal]
    
    init(meals: [Meal]) {
        self.meals = meals
    }
}

extension MealsTableDataSource: UITableViewDataSource {
    // The number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    // Returns the meal cell and sets the labels using using setMeal() in MealTableViewCell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MealTableViewCell", for: indexPath) as? MealTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        let index = indexPath.row
        let item = meals[index]
        cell.setMeal(meal: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /** Delete a meal from the database. Bug: the delete button doesn't show minus icons on each row */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("test!!!")
            meals.remove(at: indexPath.row) // Just remove from the bigMealArray for now
            // Also should delete meal from database
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
