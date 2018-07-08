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
    private var amount: Int
    
    init(name: String, amount: Int) {
        /* Used assert because not using failable initializers
           Assert runs in Xcode's Debug configuration but not in the release version */
        assert(amount >= 0, "The food amount should be at least 0")
        
        self.name = name
        self.amount = amount
    }
    func getName() -> String {
        return name
    }
    func setName(name: String) {
        self.name = name
    }
    func getAmount() -> Int {
        return amount
    }
    func setAmount(amount: Int) {
        self.amount = amount
    }
}
