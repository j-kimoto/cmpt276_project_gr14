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

class WeekViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    var list = ["1","2","3","4","5"]
    @IBOutlet weak var WeekTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        WeekTableView.dataSource = self
        WeekTableView.delegate = self
        print("week view did load")
        print(CurrentYear)
        print(CurrentMonth)
        print(CurrentDay)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (list.count)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = month[CurrentMonth]+" "+String(CurrentDay+indexPath.row)
        
        return cell
    }

    
/*
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Close the database when switching views
        sqlite3_close(db)
        print("Closed the database")
    }*/
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //determine start and end of the week in seconds since 1970
    func CalcTime() -> integer_t
    {
        let numYear = CurrentYear - 1970
        var leapYearsDays = Int(round(Double(numYear/4)))
        for index in 0...CurrentMonth
        {
            leapYearsDays += numOfDays[index]
        }
        let numDays = numYear * 365 
        let numHours = numDays * 24
        var numSeconds = numHours * 3600
        numSeconds = numSeconds - dayOfWeek * 86400
        return Int32(numSeconds)
    }
    
}
