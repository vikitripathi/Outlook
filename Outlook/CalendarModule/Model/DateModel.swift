//
//  DateModel.swift
//  Outlook
//
//  Created by abhishek dutt on 04/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import Foundation
import UIKit

struct DateModel {
    var thisDay: Int
    var day: WeekDayIndex
    
    var currentMonth: Int
    var currentYear: Int
    
    var thisDate: Date
    
    static let myCalendar = Calendar(identifier: .gregorian)
    
    enum WeekDayIndex: Int {
        case Sunday = 0
        case Monday
        case Tuesday
        case Wednesday
        case Thursday
        case Friday
        case Saturday
    }
    
    init(date: Date = Date()) {
        thisDate = date
        
        let weekDay = DateModel.myCalendar.component(.weekday, from: date)
        day  = DateModel.WeekDayIndex(rawValue: weekDay - 1)!
        
        thisDay = DateModel.myCalendar.component(.day, from: date)
        currentMonth = DateModel.myCalendar.component(.month, from: date)
        currentYear = DateModel.myCalendar.component(.year, from: date)
    }
    
    //TODO: Remove Code Duplicacy
    mutating func setupDateModel(from date: Date) {
        let weekDay = DateModel.myCalendar.component(.weekday, from: date)
        day  = DateModel.WeekDayIndex(rawValue: weekDay - 1)!
        
        thisDay = DateModel.myCalendar.component(.day, from: date)
        currentMonth = DateModel.myCalendar.component(.month, from: date)
        currentYear = DateModel.myCalendar.component(.year, from: date)
    }
    
    mutating func next() {
        thisDate = (DateModel.myCalendar as NSCalendar).date(byAdding: .day, value: 1, to: thisDate, options: [])!
        
        setupDateModel(from: thisDate)
    }
    
    mutating func prev() {
        thisDate = (DateModel.myCalendar as NSCalendar).date(byAdding: .day, value: -1, to: thisDate, options: [])!
        
        setupDateModel(from: thisDate)
    }
    
    mutating func  offsetToSunday() {
        if day == .Sunday {
            return
        }
        let daysFromSunday = day.rawValue
        
        thisDate = (DateModel.myCalendar as NSCalendar).date(byAdding: .day, value: -daysFromSunday, to: thisDate, options: [])!
        
        setupDateModel(from: thisDate)
    }
    
    mutating func offsetToSaturday() {
        if day == .Saturday {
            return
        }
        let daysFromSaturday = WeekDayIndex.Saturday.rawValue - day.rawValue
        
        thisDate = (DateModel.myCalendar as NSCalendar).date(byAdding: .day, value: daysFromSaturday, to: thisDate, options: [])!
        
        setupDateModel(from: thisDate)
    }
}

extension DateModel {
    static let currentDateModel = DateModel() //access using DateModel.currentDateModel
    
    static let twoMonthsAgoDateModel: DateModel = {
        let twoMonthsAgoDate = (myCalendar as NSCalendar).date(byAdding: .month, value: -2, to: Date())!
        
        return DateModel(date: twoMonthsAgoDate)
        
    }()
    
    static let twoMonthsLaterDateModel: DateModel = {
        let twoMonthsAgoDate = (myCalendar as NSCalendar).date(byAdding: .month, value: 2, to: Date())!
        
        return DateModel(date: twoMonthsAgoDate)
        
    }()
}

extension DateModel: Comparable {
    
    public static func ==(lhs: DateModel, rhs: DateModel) -> Bool
    {
        return (lhs.thisDay == rhs.thisDay) && (lhs.currentYear == rhs.currentYear) && (lhs.currentMonth == rhs.currentMonth)
    }
    
    public static func <(lhs: DateModel, rhs: DateModel) -> Bool
    {
        if (lhs.currentYear < rhs.currentYear) {
            return true
        }else if (lhs.currentYear == rhs.currentYear) {
            if(lhs.currentMonth < rhs.currentMonth){
                return true
            }else if(lhs.currentMonth == rhs.currentMonth) {
                return lhs.thisDay < rhs.thisDay
            }
        }
        return false
    }
}

extension DateModel: CustomStringConvertible {
    var description: String {
        return "(date: \(thisDay),day: \(day) ,month: \(currentMonth))"
    }
}
