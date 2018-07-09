//
//  SQLiteDatabase.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 7/9/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import Foundation
import SQLite3

// Returns the database pointer if opening DB was successful
//  db is nil if opening was unsuccessful
func openDatabase() -> OpaquePointer? {
    var db: OpaquePointer? = nil

    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("Meal Database")
    
    // Opening the database
    if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
        print("Error opening meal database");
    } else {
        print("Opened the database located at \(fileURL.path)")
    }
    return db
}

// Creating the meal table
// Pass in pointer to db
func createMealTable(_ db: OpaquePointer?) {
    if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Meals (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, rating INT, date INT, ingredients TEXT, type TEXT)", nil, nil, nil) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("Error creating meal table: \(errmsg)")
    }
}
