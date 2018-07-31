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

class WeekViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    
    var mealsInDateRangeQueue: [(String, Int32, String)] = []
    @IBAction func leftButton(_ sender: Any) {
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
        
         CurrentDay = numOfDays[CurrentMonth]
         n = 0
         print("New week Loaded")
         MyCollectionView.reloadData()
    }
    @IBAction func rightButton(_ sender: Any) {
         CurrentDay += 7
         if CurrentDay > numOfDays[CurrentMonth]
         {
             CurrentMonth += 1
             if CurrentMonth > 11{
                 CurrentYear -= 1
                 CurrentMonth = 11
             }
             CurrentDay = numOfDays[CurrentMonth]+CurrentDay%(numOfDays[CurrentMonth-1])
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
         print("New week Loaded")
         MyCollectionView.reloadData()
    }
    
    @IBOutlet weak var MyCollectionView: UICollectionView!
    var db: SQLiteDatabase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        n = 0
        // Do any additional setup after loading the view, typically from a nib.
        //connecting to database
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Meal Database")
        do {
            db = try SQLiteDatabase.open(path: fileURL.path)
            print("Connected to database")
        }
        catch SQLiteError.OpenDatabase(let message) {
            print("Unable to open database: \(message)")
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Close the database when switching views
        db?.closeDatabase()
        n = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 25
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCell", for: indexPath) as! WeekCollectionViewCell
        
        // empty days at the start of the month
        print("Checking if queue is empty")
        while mealsInDateRangeQueue.isEmpty {
            print("queue is empty")
            let numYear = CurrentYear - 1970
            var leapYearsDays = Int(round(Double(numYear/4)))
            for index in 0...CurrentMonth{
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
            
            // Use empty array of tuples to hold the meals. Tuple is (mealName, mealDate, mealType)
            var mealsInDateRange: [(String, Int32, String)] = []
            do {
                mealsInDateRange = (try db?.selectDateRange(numSeconds: numSeconds, numEndSeconds: numEndSeconds))!
            }
            catch {
                print(db?.getError() ?? "db is nil")
            }
            print("MealsInDateRange",mealsInDateRange)
            
            print(CurrentDay + n , CurrentMonth, CurrentYear)
            print("\n")
            mealsInDateRangeQueue.append(contentsOf: mealsInDateRange)
            n += 1
            if n > 7{
                cell.layer.borderWidth = 0
                cell.Date.text = " "
                cell.MealName.text = " "
                cell.MealType.text = " "
                return cell
            }
        }
        /*
         // Query through meals of day and printing on calendar if hit
         for meal in mealsInDateRange {
         let mealName = meal.0
         let mealDate = meal.1
         let mealType = meal.2
         print("loaded")
         print(mealName, mealDate, mealType)
         let tempDate = convertToDate(arg1: Int(mealDate))
         cell.Date.text = month[Calendar.current.component(.month, from: tempDate)-1] + " " + String(Calendar.current.component(.day, from: tempDate))
         cell.MealName.text = mealName
         cell.MealType.text = mealType
         }*/
        cell.layer.borderWidth = 0.5
        let mealName = mealsInDateRangeQueue[0].0
        let mealDate = mealsInDateRangeQueue[0].1
        let mealType = mealsInDateRangeQueue[0].2
        mealsInDateRangeQueue.removeFirst(1)
        let tempDate = convertToDate(arg1: Int(mealDate))
        cell.Date.text = month[Calendar.current.component(.month, from: tempDate)-1] + " " + String(Calendar.current.component(.day, from: tempDate))
        cell.MealName.text = mealName
        cell.MealType.text = mealType
        print("N = ",n)
        return cell
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
