//
//  CalendarModuleDataProvider.swift
//  Outlook
//
//  Created by abhishek dutt on 04/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import Foundation

//check to add optional feature where needed
class CalendarModuleDataProvider {
    private var dateList = [DateModel]()
    
    var startDate = DateModel.twoMonthsAgoDateModel
    var endDate = DateModel.twoMonthsLaterDateModel
    
    var currentDateIndex: Int {
        let currentDateModel = DateModel()
        return dateList.index(of: currentDateModel)!
    }
    
    //handle other view element or create corresponding viewModel
    var currentDateList: [DateModel] {
        startDate.offsetToSunday()
        endDate.offsetToSaturday()
        
        createDateList(from: startDate,endDate: endDate)
        
        return dateList
    }
    
    var currentEventList: [EventModel] {
        return getStaticEventLists()
    }
    
    //check custom iterator implementation
    func createDateList(from startDateModel: DateModel,endDate endDateModel: DateModel) {
        var startDateModel = startDateModel
        let endDateModel = endDateModel
        
        while startDateModel <= endDateModel {
            dateList.append(startDateModel)
            startDateModel.next()
        }
    }
    
    // TODO: remove code repeat
    func updateDateListForPreviousTwoMonths() -> [DateModel] {
        let previousStartDate = startDate
        var newList = [DateModel]()
        
        startDate.offsetDateModel(byMonth: -2)
        startDate.offsetToSunday()
        
        while startDate < previousStartDate {
            newList.append(startDate)
            startDate.next()
        }
        return updatedDateList(atStart: true, withList: newList)
    }
    
    func updateDateListForComingTwoMonths() -> [DateModel] {
        var previousEndDate = endDate
        var newList = [DateModel]()
        
        endDate.offsetDateModel(byMonth: 2)
        endDate.offsetToSaturday()
        
        previousEndDate.next()
        while previousEndDate <= endDate {
            newList.append(previousEndDate)
            previousEndDate.next()
        }
        return updatedDateList(atStart: false, withList: newList)
    }
    
    private func updatedDateList(atStart: Bool, withList newList: [DateModel]) -> [DateModel] {
        var newList = newList
        
        if atStart {
            newList.append(contentsOf: dateList)
            dateList = newList
        }else {
            dateList.append(contentsOf: newList)
        }
        
        return dateList
    }
    
    private func getStaticEventLists() -> [EventModel] {
        let event1 =  EventModel.dummyEventModel3
        let event2 =  EventModel.dummyEventModel1
        let event3 =  EventModel.dummyEventModel2
        
        var list = [EventModel]()
        list.append(event1)
        list.append(event2)
        list.append(event3)
        return list
    }
}
