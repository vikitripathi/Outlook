//
//  EventViewController.swift
//  Outlook
//
//  Created by abhishek dutt on 03/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//
import Foundation
import UIKit

protocol EventViewDelegate: class {
    func EventView(_ eventsView: EventViewController, didSelectCalendarModel model: CalendarModel)
    func showEventViewAsActiveView(_ isActive: Bool)
}

protocol EventViewDataSource: class {
    func fetchEventsViewData(isInitialFetch: Bool, isForPreviousData: Bool, completion: @escaping ((_ calendarList: [CalendarModel]) -> ()))
}

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    weak var delegate: EventViewDelegate?
    weak var datasource: EventViewDataSource?
    
    private var dataProvider = CalendarModuleDataProvider()
    private var dateList = [CalendarModel]()
    
    private var isLoading = false
    
    let locationManager = LocationManager.sharedManager
    let concurrentQueue = DispatchQueue(label: "EventModuleConcurrentQueue", attributes: .concurrent)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "eventCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.contentInset = UIEdgeInsets.zero
        
        locationManager.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        self.datasource?.fetchEventsViewData(isInitialFetch: true, isForPreviousData: false, completion: { [weak self] (calendarList) in
            
            self?.dateList = calendarList
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                let indexPath = IndexPath(row: 0, section: (self?.dataProvider.currentDayIndex(inCalendarList: calendarList))!)
                self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false) //set content offset by calculating
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dateList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateList[section].events!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        let eventModel = dateList[indexPath.section].events![indexPath.row]
        cell.configure(withEvent: eventModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! EventTableViewCell
        
        var eventModel = dateList[indexPath.section].events![indexPath.row]
        if let location = locationManager.userLocation {
            
            if eventModel.weatherAtEventTime == nil  {
                //location fecthed after user permission
                let timeInterval = eventModel.eventStartTime.timeIntervalSince1970 //events time
                
                concurrentQueue.async {
                    WeatherStore().fetchWeather(location: location, time: timeInterval.secondsString) { (weatherResult) in
                        switch weatherResult {
                        case let .success(weather):
                            DispatchQueue.main.async {
                                eventModel.weatherAtEventTime = weather
                                cell.configureWeather(event: eventModel)
                            }
                        case let .failure(error):
                            print("Error fetching weather: \(error)")
                        }
                    }
                }
                
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = EventTableViewCellHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
        headerView.configureDate(dateList[section].date)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    func reconfigureView(toRow row: Int) {
        let indexPath: IndexPath = IndexPath(row: 0, section: row)
        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
    }
    
    func scrollToCalendarModel(_ model: CalendarModel) {
        let indexPath: IndexPath = IndexPath(row: 0, section: dateList.index(of: model)!)
        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
    }
    
    func updateDataSource(_ calendarList: [CalendarModel], isForPreviousData: Bool) {
        let previousCount = dateList.count
        dateList = calendarList
        let currentCount = dateList.count
        isLoading = true
        
        guard self.tableView.indexPathsForVisibleRows != nil else {
            return
        }
        
        //check for nil and guard check
        let indexPath: IndexPath? = self.tableView.indexPathsForVisibleRows?.first
        
        guard let indexpath = indexPath else {
            return
        }
        
        var scrollToIndexPath = IndexPath(row: 0, section: ((currentCount - previousCount) + indexpath.section))
        if !isForPreviousData {
            scrollToIndexPath = IndexPath(row: 0, section:  (indexpath.section))
        }
        
        
        DispatchQueue.main.async { [weak self] in
            
            //let indexPath = self?.tableView.indexPathForRow(at: visiblePoint)!
            self?.tableView.reloadData()
            //self?.tableView.setContentOffset(newOffset, animated: false)
            self?.tableView.scrollToRow(at: scrollToIndexPath, at: .top, animated: false)
            self?.isLoading = false
        }
    }
    
    //MARK: - ScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            delegate?.showEventViewAsActiveView(true)
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrolleViewBoundsHeight = scrollView.bounds.size.height
        //print("offsetY: \(offsetY) , contentHeight: \(contentHeight), scrolleViewBoundsHeight: \(scrolleViewBoundsHeight) ")
        
        if (Float(offsetY) != 0 && Int(offsetY) > Int(contentHeight - scrolleViewBoundsHeight) && !isLoading) {
            isLoading = true
            self.datasource?.fetchEventsViewData(isInitialFetch: false, isForPreviousData: false, completion: { [weak self] (calendarList) in
                self?.dateList = calendarList
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.isLoading = false
                }
            })
        }else if (Float(offsetY) != 0 && Int(offsetY) < 50 && !isLoading ) { //make dynamic calculation
            isLoading = true
            //let visiblePoint = scrollView.bounds.origin
            self.datasource?.fetchEventsViewData(isInitialFetch: false, isForPreviousData: true, completion: { [weak self] (calendarList) in
                self?.updateDataSource(calendarList, isForPreviousData: true)
            })
        }
        
    }
    
    func recalculateUsingTargetContentOffset(_ point: CGPoint) -> CGPoint {
        
        return CGPoint()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        //Intercept and recalculate the desired content offset
        //var targetOffset = recalculateUsingTargetContentOffset(targetContentOffset.pointee)
        
        let indexPath = tableView.indexPathForRow(at: targetContentOffset.pointee)
        
        guard let indexpath = indexPath else {
            return
        }
        //Reset the targetContentOffset with your recalculated value
        //let p = withUnsafeMutablePointer(to: &targetOffset) { $0 }
        //targetContentOffset.pointee.y = targetOffset.y
        //indexPath?.row = 0
        targetContentOffset.pointee.y = tableView.rectForRow(at: indexpath).origin.y - 15.0
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //Put optional check on indexpath everywhere
        let indexPath: IndexPath = (self.tableView.indexPathsForVisibleRows?[0])!
        
        delegate?.EventView(self, didSelectCalendarModel: dateList[indexPath.section])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let indexPath: IndexPath = (self.tableView.indexPathsForVisibleRows?[0])!
//        delegate?.EventView(self, didSelectCalendarModel: dateList[indexPath.section])
    }

}

extension EventViewController: LocationManagerDelegate {
    
    func fetchedUserLocation(_ userLocation: Location) {
        loadData()
    }
}
