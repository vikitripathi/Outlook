//
//  CalendarModel.swift
//  Outlook
//
//  Created by abhishek dutt on 04/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import Foundation

struct CalendarModel {
    var date: DateModel
    var events: [EventModel]?
    
}


extension CalendarModel: Equatable {
    
    public static func ==(lhs: CalendarModel, rhs: CalendarModel) -> Bool
    {
        return (lhs.date == rhs.date)
    }
}
