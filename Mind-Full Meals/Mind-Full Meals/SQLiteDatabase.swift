//
//  SQLiteDatabase.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 7/12/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

/** The SQLiteDatabase class manages the database connection, by wrapping the database pointer.
 
 Use the static SQLiteDatabase.open(path: String) function, which has the database's file path as a parameter, to return an SQLiteDatabase object.
 This class throws errors, so errors must be catched.
 It also finalizes SQL statements and closes the database.
 */

import Foundation
import SQLite3

/** Classes, structs, and enums which conform to this protocol
 can be created in the database with createStatement */
protocol SQLTable {
    static var createStatement: String { get }
}

/** String to create the meal table */
extension Meal: SQLTable {
    static var createStatement: String {
        return "CREATE TABLE IF NOT EXISTS Meals (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, rating INT, date INT, ingredients TEXT, type TEXT, before TEXT, after TEXT, image TEXT);"
    }
}

/** Wraps different error types the database can return by conforming to Error protocol */
enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

class SQLiteDatabase {
    fileprivate let dbPointer: OpaquePointer?
    
    //fileprivate let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    fileprivate let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    fileprivate init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    /** The errorMessage variable holds the database's latest error message.
     Otherwise it holds the error message in the else statement */
    fileprivate var errorMessage: String {
        
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        }
        else {
            return "No error message provided from sqlite."
        }
    }
    
    /** Get the private errorMessage variable's value */
    func getError() -> String {
        return errorMessage
    }
    
    deinit {
        closeDatabase()
    }
    
    /** Close the database manually since we can't call the deinit ourselves */
    func closeDatabase() {
        if dbPointer != nil {
            sqlite3_close(dbPointer)
            print("Closed the database")
        }
    }
    
    /**
     - returns: an SQLiteDatabase object if opening database is ok
     - throws: SQLite.OpenDatabase error if opening database not ok
     */
    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer? = nil

        if sqlite3_open(path, &db) == SQLITE_OK {
            print("Connected to database at: \(path)")
            return SQLiteDatabase(dbPointer: db)
        }
        else {
            // The defer statement runs after execution leaves the current scope
            // The current scope is the SQLiteDatabase.open() function
            defer {
                if db != nil {
                    sqlite3_close(db)
                    print("Closed the database (from static open)")
                }
            }
            
            // This code is the same as the variable errorMessage's code since a static method
            // can't access instance variables
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String.init(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: "Error opening meal database: \(message)")
            }
            else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
}

extension SQLiteDatabase {
/** Prepares the string provided
 - parameter sql: string (SQL) to be prepared
 - returns: an OpaquePointer to the prepared statement
 - throws: SQLite.Prepare if there was an error preparing the statement
*/
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            // If a throw is run, the function ends and nothing else is run
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        return statement
    }
}

extension SQLiteDatabase {
/** Creates the table by preparing the statement, then running the SQL
 - parameter table: Accepts anything that conforms to the SQLTable protocol, so it has a createStatement
 */
    func createTable(table: SQLTable.Type) throws {
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        
        defer {
            // Free the prepared statement to release its memory
            sqlite3_finalize(createTableStatement)
        }
        
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: "Error creating \(table) table: \(errorMessage)")
        }
        print("\(table) table created or it already exists")
    }
}

extension SQLiteDatabase {
    /** Inserts a meal object into the database. Does not set any userdefaults values
     
     - throws: SQLiteError.Prepare if error with creating table.
     SQLiteError.Bind if binding parameters not ok.
     SQLiteError.Step if inserting meal not ok.
     */
    func insertMeal(meal: Meal) throws {
        
        // String to insert the meal into the database
        let insertSql = "INSERT INTO Meals (name, rating, date, ingredients, type, before, after, image) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
        
        // The prepareStatement's throw is passed up the chain
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            // Delete the prepared statement to release its memory when scope exists insertMeal function
            sqlite3_finalize(insertStatement)
        }
        
        // Bind all the meal object parameters and throw SQLiteError.Bind if not ok
        try bindAllMealParameters(meal: meal, queryStatement: insertStatement!)
        
        /*print("Data before insert:")
        print(meal)
        print("------------\n")*/
        
        // Insert the meal
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: "Error inserting meal: \(errorMessage)")
        }
        
        print("Meal added successfully")
    }
}

extension SQLiteDatabase {
    
/** Gets the meals in a time period from the database, sorted by date.
 Used by both the monthly and weekly calendar since ordering by date doesn't change the monthly calendar
 
 - parameters:
     - numSeconds: Int. The time to start selecting meals, in seconds
     - numEndSeconds: Int. The time to end selecting meals, in seconds
 - returns: an array of tuples of (meal name, meal date, meal type) */
    func selectDateRange(numSeconds: Int, numEndSeconds: Int) throws -> [(String, Int32, String)] {
        
        let queryString = "SELECT Name, Date, Type from Meals WHERE Date BETWEEN ? AND ? ORDER BY Date" // Used in weekly calendar
        //let queryString = "SELECT Name, Date, Type from Meals WHERE Date BETWEEN ? AND ?" // Used in monthly calendar
        
        var mealInfo: [(String, Int32, String)] = []

        // Preparing the query for database search
        guard let queryStatement = try prepareStatement(sql: queryString) else {
            throw SQLiteError.Prepare(message: "Error preparing select: \(errorMessage)")
        }
        
        defer {
            // Release the prepared statement's memory when we leave this function
            sqlite3_finalize(queryStatement)
        }
        
        // Binding the parameters and throwing error if not ok
        guard sqlite3_bind_int(queryStatement, 1, Int32(numSeconds)) == SQLITE_OK else {
            throw SQLiteError.Bind(message: "Error binding start date: \(errorMessage)")
        }
        guard sqlite3_bind_int(queryStatement, 2, Int32(numEndSeconds)) == SQLITE_OK else {
            throw SQLiteError.Bind(message: "Error binding end date: \(errorMessage)")
        }
        
        // Query through meals of day and adding to tuple if hit
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
            let resultscol0 = sqlite3_column_text(queryStatement, 0)
            let mealName = String(cString: resultscol0!)
            let mealDate = sqlite3_column_int(queryStatement, 1)
            let resultscol2 = sqlite3_column_text(queryStatement,2)
            let mealType = String(cString: resultscol2!)
            
            // Append the tuple to the end of the array
            mealInfo.append((mealName, mealDate, mealType))
        }
        
        return mealInfo
    }
    
    func getHungers() throws -> [(Int32, Int32)] {
        
        let queryString = "SELECT Before, After from Meals WHERE Type <> 'Snacks'" // Used on settings page to get levels
        
        var hungerInfo: [(Int32, Int32)] = []
        
        // Preparing the query for database search
        guard let queryStatement = try prepareStatement(sql: queryString) else {
            throw SQLiteError.Prepare(message: "Error preparing select: \(errorMessage)")
        }
        
        defer {
            // Release the prepared statement's memory when we leave this function
            sqlite3_finalize(queryStatement)
        }
        
        // Query through meals of day and adding to tuple if hit
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
            let before = sqlite3_column_int(queryStatement, 0)
            let after = sqlite3_column_int(queryStatement, 1)
            
            // Append to the end of the array
            hungerInfo.append((before, after))
        }
        return hungerInfo
    }
}

extension SQLiteDatabase {
    /** Gets one meal from the database (by id) and returns a meal object */
    func meal(id: Int32) throws -> Meal {
        
        let querySql = "SELECT * FROM Meals WHERE id = ?;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            throw SQLiteError.Prepare(message: "Error preparing select id statement: \(errorMessage)")
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else {
            throw SQLiteError.Bind(message: "Error binding id: \(errorMessage)")
        }
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            throw SQLiteError.Step(message: "Error running statement: \(errorMessage)")
        }
        
        // Uses the prepared statement to get a meal
        return getMealFromRow(queryStatement: queryStatement!)
    }
}


extension SQLiteDatabase {
    /** - returns: the id of a meal given all the other fields */
    func getId(meal: Meal) throws -> Int32 {
        
        // String to select the id
        let querySql = "SELECT id from Meals WHERE name = ? AND rating = ? AND date = ? AND ingredients = ? AND type = ? AND before = ? AND after = ? AND image = ?;" // 8 parameters
        
        let queryStatement = try prepareStatement(sql: querySql)
        defer {
            // Delete the prepared statement to release its memory when scope exists insertMeal function
            sqlite3_finalize(queryStatement)
        }
        
        // Bind all the meal object parameters and throw SQLiteError.Bind if not ok
        try bindAllMealParameters(meal: meal, queryStatement: queryStatement!)
        
        /*print("Data before query:")
         print(meal)
         print("------------\n")*/
        
        // Run the select query
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            throw SQLiteError.Step(message: "Error selecting meal id: \(errorMessage)")
        }
        
        // If there is more than 1 row returned since there are identical meals, the function returns the smaller id
        let int32Id = sqlite3_column_int(queryStatement, 0)
        
        //print("Meal id is \(int32Id)")
        return int32Id
    }
}

/*extension SQLiteDatabase {
    /** Returns the total number of rows (meals) in the database
     - throws: SQLiteError.Step if we couldn't get number of rows */
    func countRows() throws -> Int {
        
        let countSql = "SELECT Count(*) FROM Meals;"
        let countRowsStatement = try prepareStatement(sql: countSql)
        
        defer {
            sqlite3_finalize(countRowsStatement)
        }
        
        // Run the statement
        guard sqlite3_step(countRowsStatement) == SQLITE_ROW else {
            throw SQLiteError.Step(message: "Could not count the rows: \(errorMessage)")
        }
        
        let int32Rows = sqlite3_column_int(countRowsStatement, 0)
        let rows = Int(int32Rows)
        return rows
    }
}*/

extension SQLiteDatabase {
    /** Selects all rows in the Meal database and returns an array of Meal objects */
    func selectAllMeals() throws -> [Meal] {
        
        var allMeals = [Meal]()
        let querySql = "SELECT * FROM Meals"
        
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            throw SQLiteError.Prepare(message: "Error preparing select:  \(errorMessage)")
        }
        defer {
            sqlite3_finalize(queryStatement)
        }

        // Get rows one at a time
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            
            // Parses the row's values to create a meal object
            let newMeal = getMealFromRow(queryStatement: queryStatement!)
            
            // Append the meal to the array
            allMeals.append(newMeal)
        }
        
        return allMeals
    }
}

//MARK: Private methods
extension SQLiteDatabase {
    /** Converts from Date format to Seconds since 1970-01-01 00:00:00 */
    private func convertFromDate(arg1:Date) -> Int {
        let date = arg1
        let seconds = date.timeIntervalSince1970
        return Int(seconds)
    }
    
    /** Converts from seconds since 1970-01-01 00:00:00 to Date format */
    private func convertToDate(arg1:Int) -> Date {
        let seconds = Double(arg1)
        let date = Date(timeIntervalSince1970: seconds)
        return date
    }
    
    /** Converts an array (of ingredients) to a comma separated string */
    private func convertIngredients(arg1:Array<String>) -> String {
        let array = arg1
        let str = array.joined(separator: ",")
        return str
    }
    
    /** Splits comma separated string to an array */
    private func splitFoodAtCommas(foodText: String) -> Array<String> {
        let splitFood: Array<String>
        splitFood = foodText.components(separatedBy: ",")
        return splitFood
    }
    
    /** When given a prepared select statement, parses the row's values to return a meal object */
    private func getMealFromRow(queryStatement: OpaquePointer) -> Meal {
        var temp: [String] = []
        var mealField: String
        
        // Loop through all columns except id (id is column 0) in one row
        for index in 1...8 {
            // Integer format columns are rating (2) and date (3)
            if index == 2 || index == 3 {
                let mealInt = sqlite3_column_int(queryStatement, Int32(index))
                mealField = String(mealInt)
            }
                // Text format columns are everything else
            else {
                let resultscol = sqlite3_column_text(queryStatement, Int32(index))
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
        let image = temp[7]
        
        // Creates the object
        let newMeal = Meal(Meal_Name: name, Rating: rating, Ingredients: food, Date: date, Meal_Type: type, Before: beforeHunger, After: afterHunger, Image: image)
        return newMeal
    }
    
    /** This function binds all the parameters except for id. Used in the insertMeal() and getId() functions.
     It doesn't prepare or finalize the queryStatement. */
    private func bindAllMealParameters(meal: Meal, queryStatement: OpaquePointer) throws {
        // Setting the parameters to insert into the database
        let name = meal.GetMealName() // 1
        
        let rating = meal.GetRating()
        let int32Rating: Int32 = Int32(rating) // 2
        
        let unixDate = convertFromDate(arg1: meal.GetDate())
        let int32UnixDate = Int32(unixDate) // 3
        
        let ingredients = meal.GetIngredients()
        let commaSeparatedIngredients = convertIngredients(arg1: ingredients) // 4
        
        let type = meal.GetMeal_Type() // 5
        let beforeHunger = meal.GetBefore() // 6
        let afterHunger = meal.GetAfter() // 7
        let image =  meal.GetImage() // 8
        
        
        // Use separate booleans to check if bind succeeded
        let bindName = sqlite3_bind_text(queryStatement, 1, name, -1, SQLITE_TRANSIENT) == SQLITE_OK
        let bindRating = sqlite3_bind_int(queryStatement, 2, int32Rating) == SQLITE_OK
        let bindDate = sqlite3_bind_int(queryStatement, 3, int32UnixDate) == SQLITE_OK
        let bindIngredients = sqlite3_bind_text(queryStatement, 4, commaSeparatedIngredients, -1, SQLITE_TRANSIENT) == SQLITE_OK
        let bindType = sqlite3_bind_text(queryStatement, 5, type, -1, SQLITE_TRANSIENT) == SQLITE_OK
        let bindBeforeHunger = sqlite3_bind_text(queryStatement, 6, beforeHunger, -1, SQLITE_TRANSIENT) == SQLITE_OK
        let bindAfterHunger = sqlite3_bind_text(queryStatement, 7, afterHunger, -1, SQLITE_TRANSIENT) == SQLITE_OK
        let bindImage = sqlite3_bind_text(queryStatement, 8, image, -1, SQLITE_TRANSIENT) == SQLITE_OK
        
        // Binding the parameters and throwing error if not ok
        guard bindName && bindRating && bindDate && bindIngredients && bindType && bindBeforeHunger && bindAfterHunger && bindImage else {
            throw SQLiteError.Bind(message: "Error binding a parameter: \(errorMessage)")
        }
    }
}

extension SQLiteDatabase {
    /** Deletes a meal from the database given the meal's id (starting from 1) */
    func deleteMeal(id: Int32) throws {
        
        let querySql = "Delete FROM Meals WHERE id = ?;"
        
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            throw SQLiteError.Prepare(message: "Error preparing delete statement: \(errorMessage)")
        }
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else {
            throw SQLiteError.Bind(message: "Error binding id: \(errorMessage)")
        }
        
        // Uses the prepared statement to delete a meal
        guard sqlite3_step(queryStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: "Error running delete meal statement: \(errorMessage)")
        }
        
        //print("Successfully deleted meal with id \(id) if it existed")
    }
}
