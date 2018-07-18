//
//  WeekTableViewCell.swift
//  Mind-Full Meals
//
//  Created by Jason Kimoto on 7/18/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

class WeekTableViewCell: UITableViewCell {
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var MealName: UILabel!
    @IBOutlet weak var MealType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
