//
//  NewCalendarViewController.swift
//  Mind-Full Meals
//
//  Created by Jason Kimoto on 2018-07-03.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit
import SQLite3

var n = 0


let day = ["Sun","Mon", "Tues", "Wed", "Thur", "Fri",  "Sat"]
let month = ["Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]
var numOfDays = [31,28,31,30,31,30,31,31,30,31,30,31]
var CurrentDay = Calendar.current.component(.day, from: Date())
var CurrentMonth = Calendar.current.component(.month, from: Date())-1
var CurrentYear = Calendar.current.component(.year, from: Date())
var dayOfWeek =  Calendar.current.component(.weekday, from: Date())-1

class NewCalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    @IBAction func leftButton(_ sender: Any) {
        CurrentMonth -= 1
        if CurrentMonth < 0
        {
            CurrentMonth = 11
            CurrentYear -= 1
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
        print(day[dayOfWeek])
        print(dayOfWeek)
        dayOfWeek = ((dayOfWeek - (CurrentDay % 7))+14)%7
        CurrentDay = numOfDays[CurrentMonth]
        print(CurrentDay)
        print(day[dayOfWeek])
        print(month[CurrentMonth])
        n = 0
        MyCollectionView.reloadData()
    }
    @IBAction func rightButton(_ sender: Any) {
        CurrentMonth += 1
        if CurrentMonth > 11
        {
            CurrentMonth = 0
            CurrentYear += 1
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
        print(month[CurrentMonth])
        dayOfWeek = ((dayOfWeek - (CurrentDay % 7))+numOfDays[(CurrentMonth+11)%12] + 1)%7
        CurrentDay = 1
        print(CurrentDay)
        print(day[dayOfWeek])
        print(month[CurrentMonth])
        n = 0
        MyCollectionView.reloadData()
    }
    
    @IBOutlet weak var MyCollectionView: UICollectionView!
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        return 57
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyCollectionViewCell
        
        
        // empty days at the start of the month
        var skip = dayOfWeek + 1 - (CurrentDay % 7)
        if skip < 0
        {
            skip = (skip+14)%7
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
        
        if n <= 6 //0 to 6
        {
            if n == 3 // label the month
            {
                cell.date.text = month[CurrentMonth]
                print(skip)
            }
            else
            {
                cell.date.text = "  "
            }
        }
        else if n < 14 && n > 6 //label the days of the week cells 7 to 13
        {
            cell.date.text = day[n-7]
        }
        else if n >= 14 + skip && n < 14 + skip + numOfDays[CurrentMonth] //the days of the month
        {
            let numYear = CurrentYear - 1970
            var leapYears = Int(round(Double(numYear/4)))
            for index in 0...CurrentMonth
            {
                leapYears += numOfDays[index]
            }
            let numDays = numYear * 365 + leapYears + n - 14 - skip
            let numHours = numDays * 24
            let numSeconds = numHours * 3600
            let numEndSeconds = numSeconds + 86399
            cell.date.text = String(n-13-skip)
            //check for meals
            //if there are meals for this day
            //makemeals()
            
            var stmt: OpaquePointer?
            let queryString = "SELECT Name, Date, Type from Meals WHERE Date BETWEEN ? AND ?"
            //connecting to database
            db = openDatabase()
            
            // Preparing the query
            prepareStatement(db, queryString, &stmt)
            
            // Binding the parameters and throwing error if not ok
            bindInt(db, stmt, 1, Int32(numSeconds), "start date")
            bindInt(db, stmt, 2, Int32(numEndSeconds), "end date")
            
            // Query through meals of day and printing on calendar if hit
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                let resultscol0 = sqlite3_column_text(stmt, 0)
                let mealName = String(cString: resultscol0!)
                let mealDate = sqlite3_column_int(stmt, 1)
                let resultscol2 = sqlite3_column_text(stmt,2)
                let mealType = String(cString: resultscol2!)
                print(mealName, mealDate, mealType)
                
                if mealType == "Breakfast" {
                    cell.makeBreakfast()
                }
                if mealType == "Lunch" {
                    cell.makeLunch()
                }
                if mealType == "Dinner" {
                    cell.makeDinner()
                }
                if mealType == "Snacks" {
                    //cell.makeSnack()
                    cell.makeBreakfast()
                }
            }
           
        }
        else //beyond the days of the month
        {
            cell.date.text = "  "
        }
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

