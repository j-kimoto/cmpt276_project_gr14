//
//  RatingControl.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 2018-06-28.
//  Copyright © 2018 CMPT 276. All rights reserved.
//

import UIKit

class RatingControl: UIStackView {
    //MARK: Initialization
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: Private Methods
    private func setupButtons() {
        let button = UIButton()
        button.backgroundColor = UIColor.red
    }
}
