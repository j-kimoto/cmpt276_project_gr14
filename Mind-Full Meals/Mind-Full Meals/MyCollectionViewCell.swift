//
//  MyCollectionViewCell.swift
//  Mind-Full Meals
//
//  Created by Jason Kimoto on 2018-07-03.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var meal1labe: UILabel!
    @IBOutlet weak var meal1: UIButton!
    @IBAction func meal1(_ sender: Any)
    {

    }
    
    @IBOutlet weak var meal2: UIButton!
    @IBAction func meal2(_ sender: Any)
    {
    
    }
    
    @IBOutlet weak var meal3: UIButton!
    @IBAction func meal3(_ sender: Any)
    {
    
    }
    
    
    
    func makeBreakfast()
    {
        meal1.isHidden = false
    }
    func makeLunch()
    {
        meal2.isHidden = false
    }
    func makeDinner()
    {
        meal3.isHidden = false
    }
}
