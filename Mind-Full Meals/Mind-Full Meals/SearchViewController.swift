//
//  SearchMealViewController.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 7/12/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit
import SQLite3

class SearchViewController: UIViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var db: OpaquePointer?
    fileprivate var dataSource: MealsTableDataSource!
    
    var bigMealArray = [Meal]() // Array of meals
    var filteredBigMealArray = [Meal]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Open database
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Meal Database")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening meal database")
        }
        else {
            print("Connected to database at \(fileURL.path)")
        }
        
        // Creating the meal table if it doesn't exist already
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Meals (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, rating INT, date INT, ingredients TEXT, type TEXT, before TEXT, after TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error creating meal table: \(errmsg)")
        }
        
        searchBar.delegate = self // Handle typing in search bar
        
        bigMealArray = loadData() // Loads data to bigMealArray
        filteredBigMealArray = bigMealArray
        
        // Create an instance of the data source so the table loads our meals
        dataSource = MealsTableDataSource(meals: filteredBigMealArray)
        
        // Do any additional setup after loading the view.
        tableView.estimatedRowHeight = 284 // Preset height from interface builder
        tableView.rowHeight = UITableViewAutomaticDimension // Set the row height automatically
        tableView.dataSource = dataSource // Set the data source of the table view to this class's property
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Resize the cell heights automatically: called every time the view appears
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sqlite3_close(db) // Close the database when switching views
        print("Closed the database")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // editMealInfo
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "editMealInfo" {
            // Want to edit the selected meal
            var path = tableView.indexPathForSelectedRow
            let mealViewController = segue.destination as! MealViewController
            
            mealViewController.meal = filteredBigMealArray[(path?.row)!] // Gets meal from the filtered array
            mealViewController.editMeal = true // Currently editing meal
            print(mealViewController.meal ?? "meal is nil")
        }
    }
    
    // Selects all rows in the Meal database and returns an array of Meal objects
    func loadData() -> [Meal] {
        var tmp = [Meal]()
        let queryString = "SELECT name, rating, date, ingredients, type, before, after FROM Meals"
        var stmt: OpaquePointer?
        
        // Prepare select statement
        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing select: \(errmsg)")
        }
        
        // Get rows one at a time
        while sqlite3_step(stmt) == SQLITE_ROW {
            var temp = [String]()
            
            // Loop through all columns (no id) in one row
            for index in 0...6 {
                if index == 1 || index == 2 { // Integer columns are rating (1) and date (2)
                    let mealInt = sqlite3_column_int(stmt, Int32(index))
                    let mealField = String(mealInt)
                    temp.append(mealField)
                }
                else {
                    let resultscol = sqlite3_column_text(stmt, Int32(index))
                    let mealField = String(cString: resultscol!)
                    temp.append(mealField)
                }
            } // Done reading the row
            
            // Make the array of strings -> a meal object
            // Bug: Ingredients is a string (of an array)
            /*print("Meal name \(temp[0])")
            print("Meal rating \(temp[1])")
            print("Meal ingredients \(temp[3])") // Array of strings
            print("Meal date \(convertToDate(arg1: Int(temp[1])!) )")
            print("Meal type \(temp[4])")
            print("Before \(temp[5])")
            print("After \(temp[6])\n---------")*/

            // Append one meal (one row in DB) to array of meals
            let newMeal = Meal(Meal_Name: temp[0], Rating: Int(temp[1])!, Ingredients: [temp[3]], Date: convertToDate(arg1: Int(temp[2])!), Meal_Type: temp[4], Before: temp[5], After: temp[6])
            tmp.append(newMeal)
        }

        sqlite3_finalize(stmt)
        return tmp
    }

    // Converts from seconds since 1970-01-01 00:00:00 to Date format
    private func convertToDate(arg1:Int) -> Date {
        let seconds = Double(arg1)
        let date = Date(timeIntervalSince1970: seconds)
        return date
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Searches meal name only for now. Use lowercase to search
        // range finds the first occurence of searchText in its calle. Returns {NSNotFound, 0} if not found/empty
        filteredBigMealArray = searchText.isEmpty ? bigMealArray : bigMealArray.filter {(aMeal: Meal) -> Bool in
            return aMeal.GetMealName().range(of: searchText.lowercased(), options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        // Set the table view's data source to the filtered list of meals
        dataSource = MealsTableDataSource(meals: filteredBigMealArray)
        tableView.dataSource = dataSource
        tableView.reloadData()
    }
}
