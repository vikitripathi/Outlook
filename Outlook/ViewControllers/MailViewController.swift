//
//  MailViewController.swift
//  Outlook
//
//  Created by abhishek dutt on 03/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import UIKit
import EventKit

class MailViewController: UIViewController {
    
    var titles : [String] = []
    var startDates : [NSDate] = []
    var endDates : [NSDate] = []
    
    let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Mail"
        
        /*
        // Request access to calendar first
        eventStore.requestAccess(to: .event, completion: { [weak self] (granted, error) in
            if granted {
                print("calendar allowed")
                
                // create the event object
                /*
                let event = EKEvent(eventStore: store)
                event.title = self.activityPara.actName
                event.startDate = self.activityPara.actDate
                event.endDate = self.activityPara.actDate.addingTimeInterval(3600) // 1 hr time
                event.location = self.activityPara.actLocatnStr
                event.calendar = store.defaultCalendarForNewEvents
                
                let controller = EKEventEditViewController()
                controller.event = event
                controller.eventStore = store
                controller.editViewDelegate = self
                self.present(controller, animated: true)
                */
                
                let calendars = self?.eventStore.calendars(for: .event)
                for calendar in calendars! {
                    if calendar.title == "abhishek.dutt@quikr.com" {
                        
                        let oneMonthAgo = NSDate(timeIntervalSinceNow: -30*24*3600)
                        let oneMonthAfter = NSDate(timeIntervalSinceNow: +30*24*3600)
                        
                        let predicate = self?.eventStore.predicateForEvents(withStart: oneMonthAgo as Date, end: oneMonthAfter as Date, calendars: [calendar])
                        
                        let events = self?.eventStore.events(matching: predicate!)
                        
                        guard let eventList = events else {
                            return
                        }
                        
                        for event in eventList {
                            self?.titles.append(event.title)
                            self?.startDates.append(event.startDate as NSDate)
                            self?.endDates.append(event.endDate as NSDate)
                        }
                    }
                }
            }
            else
            {
                print("calendar not allowed")
            }           
        })
 
         */
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
