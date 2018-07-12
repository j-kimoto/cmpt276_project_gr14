//
//  SQLiteDatabase.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 7/12/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import Foundation
import SQLite3

let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    .appendingPathComponent("Meal Database")


// Returns a db pointer to the database if successful
func openDatabase() -> OpaquePointer? {
    var db: OpaquePointer? = nil
    if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
        print("Error opening meal database");
    } else {
        print("Opened the database located at \(fileURL.path)")
    }
    return db
}

// The inout parameter modifies the memory of the variable (by reference)
// Using v2 because it is the preferred version
func prepareStatement(_ db: OpaquePointer!, _ queryString: UnsafePointer<Int8>!, _ stmt: inout OpaquePointer?) {
    if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("Error preparing insert: \(errmsg)")
        //return
    }
}

// Binds the "string" argument to "position". "parameter" is part of the error message
func bindText(_ db: OpaquePointer!, _ stmt: OpaquePointer!, _ position: Int32, _ string: UnsafePointer<Int8>!, _ destructor: ((UnsafeMutableRawPointer?) -> Void)!, _ parameter: String) {
    if sqlite3_bind_text(stmt, 1, string, -1, SQLITE_TRANSIENT) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("Error binding \(parameter): \(errmsg)")
        return
    }
}

// Binds the "int" argument to "position". "parameter" is part of the error message
func bindInt(_ db: OpaquePointer!, _ stmt: OpaquePointer!, _ position: Int32, _ int: Int32, _ parameter: String) {
    if sqlite3_bind_int(stmt, position, Int32(int)) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("Error binding \(parameter): \(errmsg)")
        return
    }
}
