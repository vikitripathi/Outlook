//
//  CalendarModuleDataProvider.swift
//  Outlook
//
//  Created by abhishek dutt on 04/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import Foundation

class CalendarModuleDataProvider {
    private var dateList = [DateModel]()
    
    var startDate = DateModel.twoMonthsAgoDateModel
    var endDate = DateModel.twoMonthsLaterDateModel
    
    //handle other view element or create corresponding viewModel
    var currentDateList: [DateModel] {
        
        startDate.offsetToSunday()
        endDate.offsetToSaturday()
        
        updateDateList(from: startDate,endDate: endDate)
        
        return dateList
    }
    
    //check custom iterator implementation
    func updateDateList(from startDateModel: DateModel,endDate endDateModel: DateModel) {
        
        var startDateModel = startDateModel
        let endDateModel = endDateModel
        
        while startDateModel <= endDateModel {
            dateList.append(startDateModel)
            startDateModel.next()
        }
    }
    
    func updateDateList() {
        
    }
}
