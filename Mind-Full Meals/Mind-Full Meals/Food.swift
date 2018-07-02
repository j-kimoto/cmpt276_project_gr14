//
//  Food.swift
//  Mind-Full MealsTests
//
//  Created by Mary Wang on 2018-07-02.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import Foundation

class Food {
    private var name: String
    private var amount: Int?
    
    init(name: String) {
        self.name = name
    }
    func getName() -> String {
        return name
    }
    func setName(name: String) {
        self.name = name
    }
    func getAmount() -> Int {
        if let unwrappedAmount = amount {
            return unwrappedAmount
        } else {
            return 0
        }
    }
    func setAmount(amount: Int) {
        self.amount = amount
    }
}
