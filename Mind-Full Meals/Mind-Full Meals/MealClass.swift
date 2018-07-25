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
    var Before_Full : String
    var After_Full : String
    var Image : String
    
    init(Meal_Name: String, Date: Date)
    {
        self.Meal_Name = Meal_Name
        self.Rating = 0
        self.Ingredients = [" "]
        self.Date = Date
        self.Meal_Type = " "
        self.Before_Full = " "
        self.After_Full = " "
        self.Image = " "
    }
    init(Meal_Name: String, Rating: NSInteger, Ingredients: Array<String>, Date: Date, Meal_Type: String, Before: String, After: String, Image: String)
    {
        self.Meal_Name = Meal_Name
        self.Rating = Rating
        self.Ingredients = Ingredients
        self.Date = Date
        self.Meal_Type = Meal_Type
        self.Before_Full = Before
        self.After_Full = After
        self.Image = Image
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
    func SetBefore(arg1:String)
    {
        self.Before_Full = arg1
    }
    func GetBefore() -> String
    {
        return self.Before_Full
    }
    func SetAfter(arg1:String)
    {
        self.After_Full = arg1
    }
    func GetAfter() -> String
    {
        return self.After_Full
    }
    func SetImage(arg1:String)
    {
        self.Image = arg1
    }
    func GetImage() -> String
    {
        return self.Image
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
                Before: \(Before_Full)
                After: \(After_Full)
                Image: \(Image)
                """
    }
}
