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
    
    
    @IBOutlet weak var WeekTableView: UITableView!
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //connecting to database
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Meal Database")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening meal database")
        }
        else {
            print("Connected to database")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }

    override func viewDidAppear(_ animated: Bool) {
        WeekTableView.reloadData()
    }
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
