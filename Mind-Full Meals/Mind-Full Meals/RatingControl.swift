//
//  RatingControl.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 2018-06-28.
//  Copyright © 2018 CMPT 276. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    //MARK: Properties
    private var ratingButtons = [UIButton]()
    var rating = 0
    
    // You can change the star count in interface builder
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starColour: UIColor = UIColor.red
    
    //MARK: Initialization
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: Button Action
    @objc func ratingButtonTapped(button: UIButton) {
        print("Button pressed 👍")
    }
    
    //MARK: Private Methods
    private func setupButtons() {
        
        // Clear any existing buttons (when the star count is changed in interface builder)
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        // Goes from 0 to starCount-1 to make starCount buttons
        for _ in 0..<starCount {
            // Create the button
            let button = UIButton()
            button.backgroundColor = starColour
        
            // Setup the button action
            button.addTarget(self, action:
                #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
        
            // Add the button to the stack
            addArrangedSubview(button)
            
            // Add the new button to the rating button array
            ratingButtons.append(button)
        }
    }
}
