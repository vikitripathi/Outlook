//
//  WeatherStore.swift
//  Outlook
//
//  Created by abhishek dutt on 12/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import Foundation


class WeatherStore {
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    
    func fetchWeather(location: Location,time: String, completion: @escaping (WeatherResult) -> Void) {
        let url = WeatherAPI.weatherUrl(fromLatitude: location.latitude, longitude: location.longitude, time: time)
        
        let urlRequest = URLRequest(url: url) //url , method, parameter, headers
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in //data,_,error
            
            guard let jsonData = data else {
                completion(.failure(error!))
                return
            }
            
            let result = WeatherAPI.weather(fromJSON: jsonData)
            
            completion(result)
        }
        
        task.resume()
    }
}
