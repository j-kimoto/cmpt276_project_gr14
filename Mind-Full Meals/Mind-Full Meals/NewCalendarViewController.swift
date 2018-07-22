//
//  NewCalendarViewController.swift
//  Mind-Full Meals
//
//  Created by Jason Kimoto on 2018-07-03.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

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
        dayOfWeek = ((dayOfWeek - (CurrentDay % 7))+14)%7
        CurrentDay = numOfDays[CurrentMonth]
        n = 0
        print("New month Loaded")
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
        dayOfWeek = ((dayOfWeek - (CurrentDay % 7))+numOfDays[(CurrentMonth+11)%12] + 1)%7
        CurrentDay = 1
        n = 0
        print("New month Loaded")
        MyCollectionView.reloadData()
    }
    
    @IBOutlet weak var MyCollectionView: UICollectionView!
    var db: SQLiteDatabase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //connecting to database
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Meal Database")
        
        do {
            db = try SQLiteDatabase.open(path: fileURL.path)
            print("Connected to database")
        }
        catch SQLiteError.OpenDatabase(let message) {
            print("Error opening meal database: \(message)")
            return
        }
        catch {
            print("Another type of error happened: \(error)")
            return
        }
        
        // Creating the meal table
        do {
            try db?.createTable(table: Meal.self)
        }
        catch {
            print(db?.getError() ?? "db is nil")
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
        return 51
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyCollectionViewCell
        
        // database variables
        //var stmt: OpaquePointer?
        //let queryString = "SELECT Name, Date, Type from Meals WHERE Date BETWEEN ? AND ?"

        
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
            cell.hideBreakfast()
            cell.hideLunch()
            cell.hideDinner()
            if n == 3 // label the month
            {
                cell.date.text = month[CurrentMonth]
            }
            else
            {
                cell.date.text = "  "
            }
        }
        else if n < 14 && n > 6 //label the days of the week cells 7 to 13
        {
            cell.hideBreakfast()
            cell.hideLunch()
            cell.hideDinner()
            cell.date.text = day[n-7]
            cell.date.textAlignment = .center
        }
        else if n >= 14 + skip && n < 14 + skip + numOfDays[CurrentMonth] //the days of the month
        {
            cell.hideBreakfast()
            cell.hideLunch()
            cell.hideDinner()
            let numYear = CurrentYear - 1970
            var leapYearsDays = Int(round(Double(numYear/4)))
            for index in 0...CurrentMonth
            {
                leapYearsDays += numOfDays[index]
            }
            let numDays = numYear * 365 + leapYearsDays + n - skip - 45
            let numHours = numDays * 24
            let numSeconds = numHours * 3600
            let numEndSeconds = numSeconds + 86399
            cell.date.text = String(n-13-skip)
            //check for meals
            //if there are meals for this day
            //makemeals()
            
            // Empty array of tuples to hold the meals. Tuple is (mealName, mealDate, mealType)
            var mealsInDateRange: [(String, Int32, String)] = []
            do {
                mealsInDateRange = (try db?.selectDateRange(numSeconds: numSeconds, numEndSeconds: numEndSeconds))!
            }
            catch {
                print(db?.getError() ?? "db is nil")
            }
            
            // Query through meals of day and printing on calendar if hit
            for meal in mealsInDateRange {
                let mealName = meal.0
                let mealDate = meal.1
                let mealType = meal.2
                print(mealName, mealDate, mealType)
                
                if mealType == "Breakfast" {
                    cell.makeBreakfast()
                    print(mealDate)
                    print(mealName)
                }
                if mealType == "Lunch" {
                    cell.makeLunch()
                    print(mealDate)
                    print(mealName)
                }
                if mealType == "Dinner" {
                    cell.makeDinner()
                    print(mealDate)
                    print(mealName)
                }
                if mealType == "Snacks" {
                    //cell.makeSnack()
                    cell.makeBreakfast()
                }
            }
            cell.layer.borderWidth = 0.8
           
        }
        else //beyond the days of the month
        {
            cell.hideBreakfast()
            cell.hideLunch()
            cell.hideDinner()
            cell.date.text = "  "
        }
        n += 1
        return cell
    }
    
    // Converts from Date format to Seconds since 1970-01-01 00:00:00
    private func convertFromDate(arg1:Date) -> Int {
        let date = arg1
        let seconds = date.timeIntervalSince1970
        return Int(seconds)
        
    }
    /*
    // Converts from seconds since 1970-01-01 00:00:00 to Date format
    private func convertToDate(arg1:Int) -> Date {
        let seconds = Double(arg1)
        let date = Date(timeIntervalSince1970: seconds)
        return date
    }*/
}

