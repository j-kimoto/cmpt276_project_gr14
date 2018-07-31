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
    
    var index: Int?
    var foods: [String]!
    var editedFoodName: String?
    var addMode = false // true means we are currently adding food
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Edit food
        if (!addMode) {
            editFoodNameTextField.text = foods[index!]
        }
        // Add food
        else {
            foods.append("") // Add empty food
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 { // The first row is the meal name text field
            editFoodNameTextField.becomeFirstResponder() // Select the text field
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        // Pass the selected food to the food table controller
        case "saveFood":
            editedFoodName = editFoodNameTextField.text
            
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }
}
