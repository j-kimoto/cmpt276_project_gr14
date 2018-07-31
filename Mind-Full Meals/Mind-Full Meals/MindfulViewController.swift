//
//  MindfulViewController.swift
//  Mind-Full Meals
//
//  Created by jbengco on 7/31/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

class MindfulViewController: UIViewController {
    
    @IBOutlet var toggleArray: [UISwitch]!
    @IBOutlet weak var mindfulBar: UIProgressView!
    
    var counter = Float(0)
    
    @IBAction func switch1(_ sender: Any) {
        setProgress(toggle: 0)
    }
    
    @IBAction func switch2(_ sender: Any) {
        setProgress(toggle: 1)
    }
    
    @IBAction func switch3(_ sender: Any) {
        setProgress(toggle: 2)
    }
    
    @IBAction func switch4(_ sender: Any) {
        setProgress(toggle: 3)
    }
    
    @IBAction func switch5(_ sender: Any) {
        setProgress(toggle: 4)
    }
    
    @IBAction func switch6(_ sender: Any) {
        setProgress(toggle: 5)
    }
    
    @IBAction func switch7(_ sender: Any) {
        setProgress(toggle: 6)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Sets the switches and progress bar to equal UD
        let defaultArray = UserDefaults.standard.array(forKey: "toggleArray") as? [Bool] ?? [Bool]()
        getProgress(arr: defaultArray)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Save current switch toggle states
        let saveArray = saveValues()
        UserDefaults.standard.set(saveArray, forKey: "toggleArray")
    }
    
    // Checks if the toggle was on or off and changes the progress bar accordingly
    func setProgress(toggle: Int) {
        // If going on
        if toggleArray[toggle].isOn {
            counter += 1
        }
        // If turning off
        else {
            counter -= 1
        }
        mindfulBar.setProgress((counter/7), animated: true)
    }
    
    // Used on view load to set progress bar
    func getProgress(arr: [Bool]) {
        if arr.isEmpty == true {
            print("Empty Array")
        }
        else {
            var i = 0
            counter = Float(0)
            while i < 7 {
                if arr[i] == true {
                    toggleArray[i].setOn(true, animated: true)
                    counter += 1
                }
                i += 1
            }
        }
        mindfulBar.setProgress((counter/7), animated: true)
    }
    
    func saveValues() -> [Bool] {
        var i = 0
        var arr = Array(repeating: false, count: 7)
        while i < 7 {
            if toggleArray[i].isOn {
                arr[i] = true
            }
            i += 1
        }
        return arr
    }
}
