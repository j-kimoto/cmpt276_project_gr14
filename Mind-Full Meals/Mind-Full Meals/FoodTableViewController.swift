//
//  FoodTableViewController.swift
//  Mind-Full Meals
//
//  Created by Mary Wang on 2018-07-02.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

class FoodTableViewController: UITableViewController {

    //MARK: Properties
    var foods = [Food]()
    
    // Called after the edit screen's save button was pressed
    @IBAction func saveToFoodTableViewController(segue: UIStoryboardSegue) {
        let editFoodController = segue.source as! EditFoodTableViewController
        let index = editFoodController.index
        let foodString = editFoodController.editedFoodName
        let amount = editFoodController.editedFoodAmount
        let foodType = editFoodController.foodTypes[editFoodController.editedFoodTypeIndex!]
        
        // If an item was added in EditFoodTableViewController, reload the food array. For editing items it doesn't do anything
        foods = editFoodController.foods
        foods[index!].setName(name: foodString!)
        foods[index!].setAmount(amount: amount!)
        foods[index!].setType(type: foodType)
        
        // Add food
        if (editFoodController.addMode) {
            let indexPath:IndexPath = IndexPath(row:(index)!, section:0)
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            editFoodController.addMode = false
        }
        // Edit food
        else {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Adding food to one meal needs 1 section
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "FoodTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FoodTableViewCell else {
            fatalError("The dequeued cell is not an instance of FoodTableViewCell.")
        }
        
        // Fetches the appropriate food for the data source layout
        let food = foods[indexPath.row]
        
        cell.foodNameLabel.text = food.getName()
        cell.foodAmountLabel.text = String(food.getAmount()) // Converts the Int to a String

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the food from the array
            foods.remove(at: indexPath.row)
            
            // Update the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
            
            // Pass the selected food to the edit controller
            case "editFood":
                var path = tableView.indexPathForSelectedRow
                let editFoodController = segue.destination as! EditFoodTableViewController
            
                editFoodController.index = path?.row // Index of the row we want to edit
                editFoodController.foods = foods
            
            case "backToAddMeal":
                let mealViewController = segue.destination as! MealViewController
                mealViewController.ingredients = convertToStringArray(array: foods)
            
            case "addFood":
                let editFoodController = segue.destination as! EditFoodTableViewController
                editFoodController.addMode = true
                
                // If the array has n items, the array has indices from 0 to n-1. So index n should be the index of the new item
                editFoodController.index = foods.count
                editFoodController.foods = foods
            
            default:
                fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }

    // MARK: Private Methods
    private func convertToStringArray(array: [Food]) -> [String] {
        var strArray = [String]()
        for item in array {
            strArray.append(item.description)
        }
        return strArray
    }

}
