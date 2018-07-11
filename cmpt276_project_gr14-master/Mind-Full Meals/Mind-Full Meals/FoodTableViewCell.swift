//
//  FoodTableViewCell.swift
//  Mind-Full MealsTests
//
//  Created by Mary Wang on 2018-07-02.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

class FoodTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var foodAmountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
