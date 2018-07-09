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
    var Date : Date
    var Meal_Type : String
    
    init(Meal_Name: String, Date: Date)
    {
        self.Meal_Name = Meal_Name
        self.Rating = 0
        self.Ingredients = [" "]
        self.Date = Date
        self.Meal_Type = " "
    }
    init(Meal_Name: String, Rating: NSInteger, Ingredients: Array<String>, Date: Date, Meal_Type: String)
    {
        self.Meal_Name = Meal_Name
        self.Rating = Rating
        self.Ingredients = Ingredients
        self.Date = Date
        self.Meal_Type = Meal_Type
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
    func SetDate(arg1:Date)
    {
        self.Date = arg1
    }
    func GetDate() -> Date
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

// Lets you print meal objects with print(object)
extension Meal: CustomStringConvertible {
    public var description: String {
        return  """
                Meal_Name: \(Meal_Name)
                Rating: \(Rating)
                Ingredients: \(Ingredients)
                Date: \(Date)
                Meal_Type: \(Meal_Type)
                """
    }
}
