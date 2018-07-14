//
//  EditFoodTableViewController.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 2018-07-03.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

class EditFoodTableViewController: UITableViewController {

    // MARK: Properties
    @IBOutlet weak var editFoodNameTextField: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var amountLabel: UILabel!
    
    var index: Int?
    var foods: [Food]!
    var editedFoodName: String?
    var editedFoodAmount: Int?
    var addMode = false // true means we are currently adding food
    
    // MARK: Actions
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        amountLabel.text = Int(sender.value).description // Double -> Int -> String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Edit food
        if (!addMode) {
            stepper.value = Double(foods[index!].getAmount()) // Int -> Double

            editFoodNameTextField.text = foods[index!].getName() // Get the food's name
            amountLabel.text = String(foods[index!].getAmount()) // Get the food's amount
        }
        // Add food
        else {
            foods.append(Food(name: "", amount: 0, type: FoodType.dairy))
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 { // The first row is the meal name text field
            editFoodNameTextField.becomeFirstResponder() // Select the text field
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        // Pass the selected food to the food table controller
        case "saveFood":
            editedFoodName = editFoodNameTextField.text
            editedFoodAmount = Int(amountLabel.text!) // The amount label always has a value
            
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }

}
