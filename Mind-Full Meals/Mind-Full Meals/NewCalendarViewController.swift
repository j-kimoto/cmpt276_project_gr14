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
var CurrentMonth = Calendar.current.component(.month, from: Date())
var CurrentYear = Calendar.current.component(.year, from: Date())
var dayOfWeek =  Calendar.current.component(.weekday, from: Date())

class NewCalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{

    @IBOutlet weak var MyCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        n = 0 // Resets n before loading the calendar
        
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
        var skip = dayOfWeek - (CurrentDay % 7)
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
        
        if n <= 6
        {
            if n == 3 // label the month
            {
                cell.date.text = month[CurrentMonth-1]
                print(skip)
            }
            else
            {
                cell.date.text = "  "
            }
        }
        else if n < 14 && n > 6 //label the days of the week
        {
            cell.date.text = day[n-7]
        }
        else if n >= 14 + skip && n < 14 + skip + numOfDays[CurrentMonth-1] //the days of the month
        {
            let numYear = CurrentYear - 1970
            var leapYears = Int(round(Double(numYear/4)))
            for index in 0...CurrentMonth-2
            {
                leapYears += numOfDays[index]
            }
            let numDays = numYear * 365 + leapYears + n - 14 - skip
            let numHours = numDays * 24
            let numSeconds = numHours * 3600
            let numEndSeconds = numSeconds + 86400
            cell.date.text = String(n-13-skip)
            //check for meals
            //if there are meals for this day
            //makemeals()
            if let x = UserDefaults.standard.object(forKey:String(numSeconds)) as? String
            {
                cell.makeBreakfast()
                cell.meal1labe.text = x
            }
           
        }
        else //beyond the days of the month
        {
            cell.date.text = "  "
        }
        n += 1
        return cell
    }
}

