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
    func showCalendarHighlighted(_ eventsView: EventViewController, withIndex index: Int)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "eventCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.contentInset = UIEdgeInsets.zero
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.datasource?.fetchEventsViewData(isInitialFetch: true, isForPreviousData: false, completion: { [weak self] (calendarList) in
            
            self?.dateList = calendarList
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                let indexPath = IndexPath(row: 0, section: (self?.dataProvider.currentDayIndex(inCalendarList: calendarList))!)
                self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false) //set content offset by calculating
            }
        })
        //move to service protocol
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dateList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateList[section].events!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        cell.configure(withEvent: dateList[indexPath.section].events![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //let cell = cell as! EventTableViewCell
        //cell.testDayLabel.text = String(describing:indexPath.section)
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
    
    //MARK: - ScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            delegate?.showEventViewAsActiveView(true)
        }else {
            
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrolleViewBoundsHeight = scrollView.bounds.size.height
        print("offsetY: \(offsetY) , contentHeight: \(contentHeight), scrolleViewBoundsHeight: \(scrolleViewBoundsHeight) ")
        
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
            let visiblePoint = scrollView.bounds.origin
            self.datasource?.fetchEventsViewData(isInitialFetch: false, isForPreviousData: true, completion: { [weak self] (calendarList) in
                let previousCount = self?.dateList.count
                self?.dateList = calendarList
                DispatchQueue.main.async {
                    let currentCount = self?.dateList.count
                    //let indexPath = self?.tableView.indexPathForRow(at: visiblePoint)!
                    self?.tableView.reloadData()
                    
                    //self?.tableView.setContentOffset(newOffset, animated: false)
                    
                    //find previous indexpath and do calculation likewise
                    let scrollToIndexPath = IndexPath(row: 0, section: (currentCount! - previousCount!))
                    self?.tableView.scrollToRow(at: scrollToIndexPath, at: .top, animated: false)
                    self?.isLoading = false
                }
            })
        }
        
    }
    
    func recalculateUsingTargetContentOffset(_ point: CGPoint) -> CGPoint {
        
        return CGPoint()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        //Intercept and recalculate the desired content offset
        //var targetOffset = recalculateUsingTargetContentOffset(targetContentOffset.pointee)
        
        var indexPath = tableView.indexPathForRow(at: targetContentOffset.pointee)
        
        //Reset the targetContentOffset with your recalculated value
        //let p = withUnsafeMutablePointer(to: &targetOffset) { $0 }
        //targetContentOffset.pointee.y = targetOffset.y
        indexPath?.row = 0
        targetContentOffset.pointee.y = tableView.rectForHeader(inSection: indexPath!.section).origin.y
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //let indexPath: IndexPath = (self.tableView.indexPathsForVisibleRows?[0])!
        //delegate?.showCalendarHighlighted(self, withIndex: indexPath.section)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //let indexPath: IndexPath = (self.tableView.indexPathsForVisibleRows?[0])!
        //delegate?.showCalendarHighlighted(self, withIndex: indexPath.section)
    }

}
