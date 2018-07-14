//
//  SearchMealViewController.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 7/12/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let dataSource: MealsTableDataSource
    
    required init?(coder aDecoder: NSCoder) {
        let sampleMeals = [
            Meal(Meal_Name: "Meal 1", Rating: 1, Ingredients: ["abc", "def"], Date: Date(), Meal_Type: "Breakfast", Before: "5", After: "7"),
            Meal(Meal_Name: "Meal 2", Rating: 2, Ingredients: ["ghi", "jkl"], Date: Date(), Meal_Type: "Lunch", Before: "4", After: "6")
        ]
        // Create an instance of the data source so the table loads our meals
        self.dataSource = MealsTableDataSource(meals: sampleMeals)
        
        super.init(coder: aDecoder) // Must be called after data source is set
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.estimatedRowHeight = 200 // Preset height from interface builder
        tableView.rowHeight = UITableViewAutomaticDimension // Set the row height automatically
        tableView.dataSource = dataSource // Set the data source of the table view to this class's property
        tableView.reloadData()
    }
    
    // Resize the cell heights automatically
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
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
