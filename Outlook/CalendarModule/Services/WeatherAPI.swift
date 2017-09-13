//
//  WeatherAPI.swift
//  Outlook
//
//  Created by abhishek dutt on 11/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import Foundation

enum WeatherCategory: String {
    case Clear
    case PartlyCloudy
    case Rain
    case Wind
    case Fog
    case Cloudy
    case Thunderstorm
    
    static func getCategory(category: String) -> WeatherCategory {
        switch category {
        case "clear-day", "clear-night", "clear":
            return .Clear
        case "partly-cloudy", "partly-cloudy-day", "partly-cloudy-night":
            return .PartlyCloudy
        case "cloudy":
            return .Cloudy
        case "rain", "snow", "sleet":
            return .Rain
        case "wind":
            return .Wind
        case "fog":
            return .Fog
        default:
            return .Thunderstorm
        }
    }
    
    func getWeatherStringValue() -> String {
        switch self {
        case .Clear:
            return "Clear"
        case .Cloudy, .PartlyCloudy:
            return "Cloudy"
        case .Rain, .Thunderstorm:
            return "Rain"
            
        default:
            return "Windy"
        }
    }
}

enum WeatherResult {
    case success(Weather) //associated value
    case failure(Error)
}

enum WeatherError: Error {
    case inValidJsonData
}

struct WeatherAPI {
    private static let baseURLString = "https://api.darksky.net/forecast/"
    
    private static let apiKey = "1b448cbaa2345221c237775616b797f0"
    
    //take param lat , long, date
    static func weatherUrl(fromLatitude latitude: String, longitude: String, time: String) -> URL {
         //static member cannt be used on instance type, so static func
        
        let baseParam = [
            "key" : apiKey,
            "latitude" : latitude,
            "longitude" : longitude,
            "time": time
        ]
        
        var urlString = baseURLString
        
        //use enum and order
        urlString += baseParam["key"]! + "/"
        urlString += baseParam["latitude"]! + ","
        urlString += baseParam["longitude"]! + ","
        urlString += baseParam["time"]!
        
//        for (key, value) in baseParam {
//            if key == "key" {
//                urlString += value + "/"
//            }else if key == "time" {
//                urlString += value
//            }else {
//                urlString += value + ","
//            }
//        }
        
        let components = URLComponents(string: urlString)
        
        //print("this is the URL \(String(describing: components?.url?.absoluteString))")
        
        return (components?.url!)!
    }
    
    private static func weather(fromJSON json: [String: Any]) -> Weather? {
        
        guard let weatherCategory = json["icon"] as? String,
            let summaryValue = json["summary"] as? String,
            let temperature = json["temperature"]
            else {
                return nil  //instead check for throwing error like corrupted model json
        }
        
        let weather = WeatherCategory.getCategory(category: weatherCategory)
        let temperatureStringValue = (temperature as! Double).temperatureString
        return Weather(category: weather, summary: summaryValue, temperature: temperatureStringValue)
    }
    
    static func weather(fromJSON data: Data) -> WeatherResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let jsonDictionary = jsonObject as? [AnyHashable: Any],
                let weatherDetailJson = jsonDictionary["currently"] as? [String: Any]
                else {
                    return .failure(WeatherError.inValidJsonData)
            }
            
            var finalWeather: Weather? = nil
            
            if let weather = weather(fromJSON: weatherDetailJson) {
                finalWeather = weather
            }
            
            if finalWeather == nil {
                return .failure(WeatherError.inValidJsonData)
            }
            
            return .success(finalWeather!)
            
        } catch let error { //pattern
            return .failure(error)
        }
    }
}
