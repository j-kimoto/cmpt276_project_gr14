//
//  FullnessInfoViewController.swift
//  Mind-Full Meals
//
//  Created by jbengco on 7/12/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

class FullnessInfoViewController: UIViewController {
    
    @IBOutlet var HungerLevel: [UILabel]!
    
    @IBOutlet weak var fullnessSlider: UISlider!
    
    @IBAction func fullnessChanged(_ sender: UISlider) {
        let num = Int(round(sender.value))
        moveText(arg1:num)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    private func moveText(arg1: Int) {
        moveUp(arg1:arg1)
        moveDown(arg1:arg1)
        setText(arg1:arg1)
    }
    
    private func moveUp(arg1: Int) {
        // move up 1 through arg1
        let num = arg1
        var counter = 1
        while counter < num {
            HungerLevel[counter].frame.origin.y = 150 + (CGFloat(counter)*35)
            counter = counter + 1
        }
    }
    
    private func moveDown(arg1: Int) {
        // move down arg1+1 through 10
        var counter = arg1
        while counter < 10 {
            HungerLevel[counter].frame.origin.y = 600 - (CGFloat(10-counter)*35)
            counter = counter + 1
        }
    }
    
    private func setText(arg1: Int) {
        // expand text of arg1
        var counter = 1
        while counter < 10 {
            
        }
    }
}
