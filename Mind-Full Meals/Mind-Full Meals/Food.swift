//
//  Food.swift
//  Mind-Full MealsTests
//
//  Created by Mary Wang on 2018-07-02.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import Foundation

enum FoodType: String {
    case vegetablesAndFruit = "Vegetables and Fruit"
    case proteins = "Milk and Alternatives"
    case grains = "Grain Products"
    case dairy = "Meat and Alternatives"
}

class Food {
    private var name: String
    private var amount: Int
    private var type: FoodType
    
    init(name: String, amount: Int, type: FoodType) {
        /* Used assert because not using failable initializers
           Assert runs in Xcode's Debug configuration but not in the release version */
        assert(amount >= 0, "The food amount should be at least 0")
        
        self.name = name
        self.amount = amount
        self.type = type
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
    func getType() -> FoodType {
        return type
    }
    func setType(type: FoodType) {
        self.type = type
    }
}

// Lets you print food objects with print(object)
extension Food: CustomStringConvertible {
    public var description: String {
        return  "Food name: \(name). Amount: \(amount). Type: \(type.rawValue)"
    }
}
