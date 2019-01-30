//
//  WeatherDataModel.swift
//  Morning Assist
//
//  Created by Mascarenhas on 2019-01-30.
//  Copyright © 2019 Mascarenhas. All rights reserved.
//
import UIKit

class WeatherDataModel
{
    var temperature: Int = 0
    var condition: Int  = 0
    var city: String = ""
    var weatherIcon: String = ""
    var iconBool: Bool = false
    
    func weatherIconImg(condition:Int)-> String
    {
        switch (condition){
            
        case 0...300 :
            return "tstorm1"
            
        case 301...500 :
            return "light_rain"
            
        case 501...600 :
            return "shower3"
            
        case 601...700 :
            return "snow4"
            
        case 701...771 :
            return "fog"
            
        case 772...799 :
            return "tstorm3"
            
        case 800 :
            return "sunny"
            
        case 801...804 :
            return "cloudy2"
            
        case 900...903, 905...1000  :
            return "tstorm3"
            
        case 903 :
            return "snow5"
            
        case 904 :
            return "sunny"
            
        default :
            return "dunno"
        }
    }
}
