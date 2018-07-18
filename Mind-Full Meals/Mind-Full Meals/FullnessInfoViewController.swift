//
//  FullnessInfoViewController.swift
//  Mind-Full Meals
//
//  Created by jbengco on 7/12/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

class FullnessInfo: UIViewController {
    
    @IBOutlet weak var fullnessSlider: UISlider!
    @IBOutlet var HungerLevel: [UILabel]!
    
    let smallText = ["1. Beyond Hungry", "2. Intolerable and Cranky", "3. Strong Urge to Eat", "4. Thinking About Food", "5. Minimally Satisfied", "6. Fully Satisfied", "7. Past Satisfaction", "8. Starting to Hurt", "9. Uncomfortable", "10. Beyond Full"]
    let bigText = ["1. Beyond Hungry\n   -You may have a headache\n   -You can't concentrate and feel dizzy\n   -You are totally out of energy", "2. Intolerable and Cranky\n   -You’re irritable and cranky\n   -You are very hungry, with little energy\n   -You may even feel nauseous\n   -You are at the stage of being famished", "3. Strong Urge to Eat\n   -You are feeling an emptiness in your stomach\n   -Your coordination begins to wane", "4. Thinking About Food\n   -Your body is giving you the signal that you might want to eat\n   -You are a little hungry.", "5. Satisfied\n   -Your body has enough fuel to keep it going\n   -You are physically and psychologically starting to feel satisfied", "6. Fully Satisfied\n   -You are fully at the point of satisfaction\n   -The ideal post meal hunger level", "7. Past Satisfaction\n   -You can still \"find room\" for a little more\n   -Your body is saying no but your mind is saying yes", "8. Starting to Hurt\n   -You ate too much\n   -You are actually starting to hurt", "9. Uncomfortable\n   -The after effects are really uncomfortable\n   -You feel heavy, tired and bloated\n   -You would rather go to bed", "10. Beyond Full\n   -Typical Thanksgiving Dinner feeling\n   -You are physically miserable\n   -You don't want to or can't move"]
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        let num = Int(round(sender.value))
        moveText(arg1:num)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    private func moveText(arg1: Int) {
        let num = arg1-1
        var counter = num
        while counter < 10 {
            // Used to move up labels 1 through arg1
            if counter < num {
                HungerLevel[counter].frame.origin.y = 15 + (CGFloat(counter)*35)
            }
            // Used to move down labels arg1+1 through 10
            else {
                HungerLevel[counter].frame.origin.y = 580 - (CGFloat(10-counter)*35)
            }
            counter = counter + 1
        }
        setText(arg1:arg1)
    }
    
    private func setText(arg1: Int) {
        // shrink all text then expand text of arg1
        let num = arg1-1
        var counter = 0
        while counter < 10 {
            HungerLevel[counter].text = smallText[counter]
            HungerLevel[counter].textColor = UIColor.black
            //HungerLevel[counter].sizeToFit()
            counter = counter + 1
        }
        HungerLevel[num].text = bigText[num]
        //HungerLevel[num].sizeToFit()
        HungerLevel[num].textColor = UIColor.red
    }
}
