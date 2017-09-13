//
//  EventModel.swift
//  Outlook
//
//  Created by abhishek dutt on 04/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import Foundation

//Use videmodel and move the conversion to it as per view configuration
struct EventModel {
    var eventStartTime: Date
    var eventDuration: TimeInterval?
    var eventTitle: String
    var eventLocation: String?
    var eventAttendees: [String]?
    var eventCategory: EventCategory
    
    var weatherAtEventTime: Weather? = nil
    
    static let myCalendar = Calendar(identifier: .gregorian)
    
    enum EventCategory {
        case Holiday
        case Meeting
        case Hangout
        case UnCategorised
    }
}


extension EventModel {
    
    //Use coredata to fetch these event details
    static let dummyEventModel1: EventModel = {
        let now = Date()
        var components = myCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        components.hour = 9
        components.minute = 30
        components.second = 0

        let eventStart = myCalendar.date(from: components)!

        let duration: TimeInterval = 900
        let title = "Dazzlr Sync Up"
        let location = "Quikr India Pvt Ltd"
        let attendees = ["Abhishek", "Spoorthi", "Srikrishna", "Prem"]
        let category = EventCategory.Meeting
        
       return EventModel(eventStartTime: eventStart, eventDuration: duration, eventTitle: title, eventLocation: location, eventAttendees: attendees, eventCategory: category, weatherAtEventTime: nil)
    }()
    
    static let dummyEventModel2: EventModel = {
        let now = Date()
        var components = myCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        components.hour = 16
        components.minute = 30
        components.second = 0
        
        let eventStart = myCalendar.date(from: components)!
        
        let duration: TimeInterval = 3600
        let title = "Party At Big Pitcher!"
        let location = "Big Pitcher, Bangalore"
        let attendees = ["Abhishek", "Spoorthi"]
        let category = EventCategory.Hangout
        
        return EventModel(eventStartTime: eventStart, eventDuration: duration, eventTitle: title, eventLocation: location, eventAttendees: attendees, eventCategory: category, weatherAtEventTime: nil)
    }()
    
    static let dummyEventModel3: EventModel = {
        let now = Date()
        var components = myCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let eventStart = myCalendar.date(from: components)!
        
        let title = "Onam"
        let category = EventCategory.Holiday
        
        return EventModel(eventStartTime: eventStart, eventDuration: nil, eventTitle: title, eventLocation: nil, eventAttendees: nil, eventCategory: category, weatherAtEventTime: nil)
    }()
}

extension EventModel {
    var getStartDateString: String {
        let hour = EventModel.myCalendar.component(.hour, from: eventStartTime)
        let minutes = EventModel.myCalendar.component(.minute, from: eventStartTime)
        return "\(hour):\(minutes)"
    }
}

extension TimeInterval{
    var minutes: Int{
        return Int((self/60).remainder(dividingBy: 60))
    }
    
    var hours: Int{
        return Int(self / (60*60))
    }
    
    var stringTime: String{
        if self.hours != 0{
            return "\(self.hours)h \(self.minutes)m"
        }else if self.minutes != 0{
            return "\(self.minutes)m"
        }
        return ""
    }
}
