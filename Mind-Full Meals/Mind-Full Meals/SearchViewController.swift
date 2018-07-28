//
//  SearchMealViewController.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 7/12/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var searchBar: UISearchBar!
    @IBOutlet fileprivate weak var exportButton: UIBarButtonItem!

    private var db: SQLiteDatabase?
    fileprivate var dataSource: MealsTableDataSource!
    
    private var bigMealArray: [Meal] = []
    private var filteredBigMealArray: [Meal] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Try to export your meals to a file and then email that file to someone
    @IBAction func exportMeals(_ sender: Any) {
        let emailText = writeMealsToFile()
        
        // Now email your meals to someone
        sendEmail(file: emailText)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Open database and catch errors
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Meal Database")
        
        do {
            db = try SQLiteDatabase.open(path: fileURL.path)
            print("Successfully opened connection to meal database!")
        }
        catch SQLiteError.OpenDatabase(let message) {
            print("Unable to open database: \(message)")
            return
        }
        catch {
            print("Another type of error happened: \(error)")
            return
        }
        
        // Creating the meal table if it doesn't exist already
        do {
            try db?.createTable(table: Meal.self)
        }
        catch {
            print(db?.getError() ?? "db is nil")
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
        
        // Display an edit button on the navigation bar (used to delete meals)
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Resize the cell heights automatically: called every time the view appears
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Close the database when switching views
        db?.closeDatabase()
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
            //print(mealViewController.meal ?? "meal is nil")
        }
    }
    
    // Selects all rows in the Meal database and returns an array of Meal objects
    private func loadData() -> [Meal] {
        var listOfMeals: [Meal] = []
        do {
            listOfMeals = (try db?.selectAllMeals())!
        }
        catch {
            print("Error getting all meals from database")
        }
        return listOfMeals
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
        // Uses lowercase to search
        // range finds the first occurence of searchText in its calle. Returns nil if not found/empty
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
    
    /** Writes your meals to a file using the meal object's description property
     and also returns the string that was written */
    private func writeMealsToFile() -> String {
        var text: String = ""
        
        do {
            let exportURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("myMeals.txt")
            do {
                // Iterate over all meals from the database and append them to a string
                for (index, meal) in bigMealArray.enumerated() {
                    text += "Meal id: \(index + 1)\n" // Index starts at 0 but database index starts at 1
                    text += meal.description
                    text += "\n\n" // Newline after each meal
                }
                
                try text.write(to: exportURL, atomically: false, encoding: .utf8)
                print("Wrote your meals to a file: \(exportURL.path)")
            }
            catch {
                print("Could not write meals to text file")
            }
        }
        catch {
            print("Could not open file")
        }
        return text
    }
    
    // Sends an email while attaching the file parameter as an attachment
    private func sendEmail(file: String) {
        let mail = newMailComposeViewController(file: file)
        presentMailComposeView(mailComposeViewController: mail)
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
