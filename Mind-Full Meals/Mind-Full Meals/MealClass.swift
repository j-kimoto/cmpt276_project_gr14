//
//  MealClass.swift
//  Mind-Full Meals
//
//  Created by Jason Kimoto on 6/30/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import Foundation
class Meal {
    var Meal_Name : String
    var Rating : NSInteger
    var Ingredients : Array<String>
    var Date : Array<NSInteger>
    var Meal_Type : String
    
    init()
    {
        self.Meal_Name = " "
        self.Rating = 0
        self .Ingredients = [" "]
        self.Date = [0,0,0]
        self.Meal_Type = " "
    }
    func SetMealName(arg1:String)
    {
        self.Meal_Name = arg1
    }
    func GetMealName() -> String
    {
        return self.Meal_Name
    }
    func SetRating(arg1:NSInteger)
    {
        self.Rating = arg1
    }
    func GetRating() -> NSInteger
    {
        return self.Rating
    }
    func SetIngredients(arg1:Array<String>)
    {
        self.Ingredients = arg1
    }
    func GetIngredients() -> Array<String>
    {
        return self.Ingredients
    }
    func SetDate(arg1:Array<NSInteger>)
    {
        self.Date = arg1
    }
    func GetDate() -> Array<NSInteger>
    {
        return self.Date
    }
    func SetMeal_Type(arg1:String)
    {
        self.Meal_Type = arg1
    }
    func GetMeal_Type() -> String
    {
        return self.Meal_Type
    }
}
