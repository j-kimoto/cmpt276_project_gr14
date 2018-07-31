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
    private var meals: [Meal]
    private var database: SQLiteDatabase
    private var table: UITableView
    
    init(meals: [Meal], database: SQLiteDatabase, table: UITableView) {
        self.meals = meals
        self.database = database
        self.table = table
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
    
    // Deletes a meal when swiping left
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let mealIndex = indexPath.row
        
        if editingStyle == .delete {
            // Remove the meal from the array
            let poppedMeal = meals.remove(at: mealIndex)
            
            // Update the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Get the row id of the meal to delete from the database
            var poppedRowId: Int32
            do {
                poppedRowId = try database.getId(meal: poppedMeal)
            }
            catch {
                print("Error getting id of the meal to delete")
                // Must return here since poppedRowId would not be initialized
                return
            }
            
            // Delete the meal from the database
            do {
                try database.deleteMeal(id: poppedRowId)
            }
            catch {
                print("Error deleting meal with id \(poppedRowId)")
            }
            
            print("DELETED meal at array index \(mealIndex), database id \(poppedRowId)")
        }
    }
}
