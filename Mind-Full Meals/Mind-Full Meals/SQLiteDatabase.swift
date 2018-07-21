//
//  SQLiteDatabase.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 7/12/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

/** The SQLiteDatabase class manages the database connection, by wrapping the database pointer.
 
 Use the static SQLiteDatabase.open(path: String) function, which has the file path as a parameter, to return an SQLiteDatabase object.
 
 The class should throw errors and print error statements for you. It also should finalize SQL statements and close the database for you.
 */

import Foundation
import SQLite3

/** Classes, structs, and enums which conform to this protocol
 can be created in the database with createStatement */
protocol SQLTable {
    static var createStatement: String { get }
}

extension Meal: SQLTable {
    static var createStatement: String {
        return "CREATE TABLE IF NOT EXISTS Meals (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, rating INT, date INT, ingredients TEXT, type TEXT, before TEXT, after TEXT);"
    }
}

/** Wraps different error types the database can return.
 The error protocol means this can be used for error handling */
enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

class SQLiteDatabase {
    fileprivate let dbPointer: OpaquePointer?
    
    fileprivate let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    fileprivate let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    fileprivate let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Meal Database")
    
    /** Fileprivate initializer and database pointer so you can't access it directly */
    fileprivate init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    /** The errorMessage variable holds the database's latest error message.
     Otherwise it holds the error message in the else statement
     */
    fileprivate var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    /** The errorMessage variable is private so we need a public getter */
    func getError() -> String {
        return errorMessage
    }
    
    deinit {
        sqlite3_close(dbPointer)
        print("Closed the database (from deinit)")
    }
    
    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer? = nil

        // Returns an SQLiteDatabase object if opening database is OK
        if sqlite3_open(path, &db) == SQLITE_OK {
            print("Connected to database")
            return SQLiteDatabase(dbPointer: db)
        } else {
            // The defer statement is guaranteed to run after execution leaves the current scope
            // The current scope is the SQLiteDatabase.open() function
            defer {
                if db != nil {
                    sqlite3_close(db)
                    print("Closed the database (from static open)")
                }
            }
            
            // This code is the same as the variable errorMessage's code since a static method
            // can't access instance variables. We can call open() without an instance of the class.
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String.init(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: "Error opening meal database: \(message)")
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
}

/** Prepares the string provided
 - parameter sql: string (SQL) to be prepared
 - returns: an OpaquePointer to the prepared statement */
extension SQLiteDatabase {
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            // If a throw is run, the function ends and nothing else is run
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        return statement
    }
}

/** Creates the table by first preparing the statement, then running the SQL
 - parameter table: Accepts anything that conforms to the SQLTable protocol, meaning it has a createStatement variable
 */
extension SQLiteDatabase {
    func createTable(table: SQLTable.Type) throws {
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        defer {
            // Delete the prepared statement to release its memory (it can't be used anymore)
            sqlite3_finalize(createTableStatement)
        }
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: "Error creating \(table) table: \(errorMessage)")
        }
        print("\(table) table created.")
    }
}

/** Inserts a meal object into the database. Does not set any userdefaults values (can do it yourself) */
extension SQLiteDatabase {
    func insertMeal(meal: Meal) throws {
        
        let insertSql = "Insert into Meals (name, rating, date, ingredients, type, before, after) VALUES (?, ?, ?, ?, ?, ?, ?);"
        let insertStatement = try prepareStatement(sql: insertSql) // The prepareStatement's throw is passed up the chain
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        // Setting the parameters to insert into the database
        let name = meal.GetMealName()
        
        let rating = meal.GetRating()
        let int32Rating: Int32 = Int32(rating)
        
        let unixDate = convertFromDate(arg1: meal.GetDate())
        let int32UnixDate = Int32(unixDate)

        let ingredients = meal.GetIngredients()
        let commaSeparatedIngredients = convertIngredients(arg1: ingredients)
        
        let type = meal.GetMeal_Type()
        let beforeHunger = meal.GetBefore()
        let afterHunger = meal.GetAfter()
        
        
        // Use separate booleans to check if bind succeeded
        let bindName = sqlite3_bind_text(insertStatement, 1, name, -1, SQLITE_TRANSIENT) == SQLITE_OK
        let bindRating = sqlite3_bind_int(insertStatement, 2, int32Rating) == SQLITE_OK
        let bindDate = sqlite3_bind_int(insertStatement, 3, int32UnixDate) == SQLITE_OK
        let bindIngredients = sqlite3_bind_text(insertStatement, 4, commaSeparatedIngredients, -1, SQLITE_TRANSIENT) == SQLITE_OK
        let bindType = sqlite3_bind_text(insertStatement, 5, meal.GetMeal_Type(), -1, SQLITE_TRANSIENT) == SQLITE_OK
        let bindBeforeHunger = sqlite3_bind_text(insertStatement, 6, meal.GetBefore(), -1, SQLITE_TRANSIENT) == SQLITE_OK
        let bindAfterHunger = sqlite3_bind_text(insertStatement, 7, meal.GetAfter(), -1, SQLITE_TRANSIENT) == SQLITE_OK
        
        // Binding the parameters and throwing error if not ok
        guard bindName && bindRating && bindDate && bindIngredients && bindType && bindBeforeHunger && bindAfterHunger else {
            throw SQLiteError.Bind(message: "Error binding a parameter: \(errorMessage)")
        }
        
        print("Data before insert:")
        print(meal)
        print("------------\n")
        
        // Insert the meal
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: "Error inserting meal: \(errorMessage)")
        }
        
        print("Meal added successfully")
    }
}

extension SQLiteDatabase {
    /** Converts from Date format to Seconds since 1970-01-01 00:00:00 */
    private func convertFromDate(arg1:Date) -> Int {
        let date = arg1
        let seconds = date.timeIntervalSince1970
        return Int(seconds)
    }
    
    /** Converts an array (of ingredients) to a comma separated string */
    private func convertIngredients(arg1:Array<String>) -> String {
        let array = arg1
        //let str =  array.description
        let str = array.joined(separator: ",")
        return str
    }
}

/*
extension SQLiteDatabase {
    func meal(id: Int32) -> Meal? {
        let querySql = "SELECT * FROM Meals WHERE Id = ?;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else {
            return nil
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            return nil
        }
        
        let id = sqlite3_column_int(queryStatement, 0)
        
        let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
        let name = String(cString: queryResultCol1!) as NSString
        
        return Meal(id: id, name: name)
    }
}
*/
