//
//  WeekViewController.swift
//  Mind-Full Meals
//
//  Created by Jason Kimoto on 7/17/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//
/*
 TO DO:
 DONE:determine start and end of the week in seconds since 1970
 
 get all meals planned for the week from the database
 
 determine how many inputs there are for this week(set number of rows)
 
 go through each row of database results to input on calendar
 */

import UIKit
import SQLite3

class WeekViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    @IBAction func leftButton(_ sender: Any) {/*
        CurrentDay -= 7
        if CurrentDay < 0
        {
            CurrentMonth -= 1
            if CurrentMonth < 0{
                CurrentYear -= 1
                CurrentMonth = 11
            }
            CurrentDay = numOfDays[CurrentMonth]-CurrentDay
        }
        //i hate leap years
        if CurrentMonth == 1 && CurrentYear % 4 == 0
        {
            numOfDays[1] = 29
        }
        else
        {
            numOfDays[1] = 28
        }
        dayOfWeek = ((dayOfWeek - (CurrentDay % 7))+14)%7
        CurrentDay = numOfDays[CurrentMonth]
        n = 0
        print("New month Loaded")
        MyCollectionView.reloadData()*/
    }
    @IBAction func rightButton(_ sender: Any) {/*
        CurrentMonth += 1
        if CurrentMonth > 11
        {
            CurrentMonth += 1
            if CurrentMonth > 11{
                CurrentYear += 1
                CurrentMonth = 0
            }
            CurrentDay = CurrentDay-numOfDays[CurrentMonth]
        }
        //i hate leap years
        if CurrentMonth == 1 && CurrentYear % 4 == 0
        {
            numOfDays[1] = 29
        }
        else
        {
            numOfDays[1] = 28
        }
        dayOfWeek = ((dayOfWeek - (CurrentDay % 7))+numOfDays[(CurrentMonth+11)%12] + 1)%7
        CurrentDay = 1
        n = 0
        print("New week Loaded")
        MyCollectionView.reloadData()*/
    }
    
    @IBOutlet weak var MyCollectionView: UICollectionView!
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //connecting to database
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Meal Database")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening meal database")
        }
        else {
            print("Connected to database")
        }
        
        // Creating the meal table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Meals (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, rating INT, date INT, ingredients TEXT, type TEXT, before TEXT, after TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error creating meal table: \(errmsg)")
        }
        
        n = 0 // Resets n before loading the calendar
        print("view is loading")
        self.MyCollectionView.delegate = self
        self.MyCollectionView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 7
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCell", for: indexPath) as! WeekCollectionViewCell
        // database variables
        var stmt: OpaquePointer?
        let queryString = "SELECT Name, Date, Type from Meals WHERE Date BETWEEN ? AND ? ORDER BY Date"
        
        
        // empty days at the start of the month
        
        
            let numYear = CurrentYear - 1970
            var leapYearsDays = Int(round(Double(numYear/4)))
            for index in 0...CurrentMonth
            {
                leapYearsDays += numOfDays[index]
            }
            let numDays = numYear * 365 + leapYearsDays + CurrentDay + n - 32
            let numHours = numDays * 24
            let numSeconds = numHours * 3600
            let numEndSeconds = numSeconds + 86399
            // var tempdate = date(era: 0, year: CurrentYear, month: CurrentMonth, day: CurrentDay, hour: 0, minute: 0, second: 0, nanosecond:0)

            //check for meals
            //if there are meals for this day
            //makemeals()
             cell.Date.text = month[CurrentMonth] + " " + String(CurrentDay+n)
            // Preparing the query for database search
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error preparing insert: \(errmsg)")
            }
            
            // Binding the parameters and throwing error if not ok
            if sqlite3_bind_int(stmt, 1, Int32(numSeconds)) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error binding start date: \(errmsg)")
            }
            if sqlite3_bind_int(stmt, 2, Int32(numEndSeconds)) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error binding end date: \(errmsg)")
            }
            print(CurrentDay + n , CurrentMonth, CurrentYear)
            // Query through meals of day and printing on calendar if hit
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                let resultscol0 = sqlite3_column_text(stmt, 0)
                let mealName = String(cString: resultscol0!)
                let mealDate = sqlite3_column_int(stmt, 1)
                let resultscol2 = sqlite3_column_text(stmt,2)
                let mealType = String(cString: resultscol2!)
                print("loaded")
                print(mealName, mealDate, mealType)
                let tempDate = convertToDate(arg1: Int(mealDate))
                cell.Date.text = month[Calendar.current.component(.month, from: tempDate)-1] + " " + String(Calendar.current.component(.day, from: tempDate))
                cell.MealName.text = mealName
                cell.MealType.text = mealType
              }
        cell.layer.borderWidth = 0.8
        n += 1
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Close the database when switching views
        sqlite3_close(db)
        print("Closed the database")
    }
    
    // Converts from Date format to Seconds since 1970-01-01 00:00:00
    private func convertFromDate(arg1:Date) -> Int {
        let date = arg1
        let seconds = date.timeIntervalSince1970
        return Int(seconds)
        
    }
    
    // Converts from seconds since 1970-01-01 00:00:00 to Date format
    private func convertToDate(arg1:Int) -> Date {
        let seconds = Double(arg1)
        let date = Date(timeIntervalSince1970: seconds)
        return date
    }
}
