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

    private var db: OpaquePointer?
    fileprivate var dataSource: MealsTableDataSource!
    
    private var bigMealArray: [Meal] = []
    private var filteredBigMealArray: [Meal] = []
    
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
        
        // Handle typing in search bar
        searchBar.delegate = self
        
        // Loads data to bigMealArray
        bigMealArray = loadData()
        
        // Create an instance of the data source so the table loads our meals
        dataSource = MealsTableDataSource(meals: bigMealArray)
        
        tableView.estimatedRowHeight = 185                      // Preset height from interface builder
        tableView.rowHeight = UITableViewAutomaticDimension     // Set the row height automatically
        tableView.dataSource = dataSource                       // Set the data source of the table view to this class's property
        filteredBigMealArray = bigMealArray                     // filteredBigMealArray used for searching
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

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    private func loadData() -> [Meal] {
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
            var temp: [String] = []
            var mealField: String
            
            // Loop through all columns (no id) in one row
            for index in 0...6 {
                if index == 1 || index == 2 { // Integer columns are rating (1) and date (2)
                    let mealInt = sqlite3_column_int(stmt, Int32(index))
                    mealField = String(mealInt)
                }
                else {
                    let resultscol = sqlite3_column_text(stmt, Int32(index))
                    mealField = String(cString: resultscol!)
                }
                temp.append(mealField)
            } // Done reading the row
            
            // Convert the array of strings to a meal object
            let name = temp[0]
            let rating = Int(temp[1])!
            let unixDate: Int = Int(temp[2])!
            let date: Date = convertToDate(arg1: unixDate)
            let food: Array<String> = splitFoodAtCommas(foodText: temp[3])
            let type = temp[4]
            let beforeHunger = temp[5]
            let afterHunger = temp[6]
            
            let newMeal = Meal(Meal_Name: name, Rating: rating, Ingredients: food, Date: date, Meal_Type: type, Before: beforeHunger, After: afterHunger)

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
    
    // Returns a text representation of the date parameter
    private func dateToString(mealDate: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.medium
        
        return dateFormatter.string(from: mealDate)
    }
    
    // Splits comma separated string to an array
    private func splitFoodAtCommas(foodText: String) -> Array<String> {
        let splitFood: Array<String>
        splitFood = foodText.components(separatedBy: ",")
        return splitFood
    }
    
    // Converts the array of ingredients to a string
    private func convertIngredients(arg1:Array<String>) -> String {
        let array = arg1
        let str = array.joined(separator: ",")
        return str
    }
    
    // Searches bigMealArray for searchText, returning the filtered array
    private func filterMealsForSearchText(searchText: String, scope: Int) -> [Meal] {
        // Searches meal name only for now. Use lowercase to search
        // range finds the first occurence of searchText in its calle. Returns {NSNotFound, 0} if not found/empty
        if searchText.isEmpty {
            return bigMealArray
        }
        else {
            return bigMealArray.filter {(aMeal: Meal) -> Bool in
                var fieldToSearch: String?

                switch scope {
                    case 0: // Name
                        fieldToSearch = aMeal.GetMealName()
                    case 1: // Rating
                        fieldToSearch = "\(aMeal.GetRating())"
                    case 2: // Ingredients
                        fieldToSearch = convertIngredients(arg1: aMeal.GetIngredients())
                    case 3: // Date
                        fieldToSearch = dateToString(mealDate: aMeal.GetDate())
                    case 4: // Type
                        fieldToSearch = aMeal.GetMeal_Type()
                    case 5: // Before hunger
                        fieldToSearch = aMeal.GetBefore()
                    case 6: // After hunger
                        fieldToSearch = aMeal.GetAfter()
                    default:
                        fieldToSearch = aMeal.GetMealName()
                }
                
                return fieldToSearch!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let selectedIndex = searchBar.selectedScopeButtonIndex
        filteredBigMealArray = filterMealsForSearchText(searchText: searchText, scope: selectedIndex)
        
        // Set the table view's data source to the filtered list of meals
        dataSource = MealsTableDataSource(meals: filteredBigMealArray)
        tableView.dataSource = dataSource
        tableView.reloadData()
    }
}

