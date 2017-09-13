//
//  Weather.swift
//  Outlook
//
//  Created by abhishek dutt on 11/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import Foundation

class Weather {
    let category: WeatherCategory
    let summary: String
    let temperature: String
    
    init(category: WeatherCategory, summary: String, temperature: String) {
        self.category = category
        self.summary = summary
        self.temperature = temperature
    }
}
