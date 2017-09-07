//
//  EventViewController.swift
//  Outlook
//
//  Created by abhishek dutt on 03/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import UIKit

protocol EventViewDelegate: class {
    func showCalendarHighlighted(_ eventsView: EventViewController, withIndex index: Int)
    func showEventViewAsActiveView(_ isActive: Bool)
}

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    weak var delegate: EventViewDelegate?
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
        
        //move to service protocol
        let concurrentQueue = DispatchQueue(label: "EventViewCalendarQueue", attributes: .concurrent)
        weak var weakSelf = self
        concurrentQueue.async {
            //use guard let for wealself or check unowned
            //weakSelf?.isLoading = true
            weakSelf?.dateList = (weakSelf?.dataProvider.currentDateList)!
            
            DispatchQueue.main.async {
                weakSelf?.tableView.reloadData()
                //weakSelf?.isLoading = false
                //let indexPath = IndexPath(row: (weakSelf?.dataProvider.currentDateIndex)!, section: 0)
                //weakSelf?.collectionView.scrollToItem(at: indexPath, at: .top, animated: false) //set content offset by calculating
            }
        }
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
        print("offsetY: \(offsetY) , contentHeight: \(contentHeight) , boundsHeight: \(scrolleViewBoundsHeight)")
        
        if (Float(offsetY) != 0 && Int(offsetY) > Int(contentHeight - scrolleViewBoundsHeight)) {
            let concurrentQueue = DispatchQueue(label: "EventViewCalendarQueue", attributes: .concurrent)
            weak var weakSelf = self
            concurrentQueue.async {
//                weakSelf?.dateList = (weakSelf?.dataProvider.updateDateListForComingTwoMonths())!
//                DispatchQueue.main.async {
//                    weakSelf?.collectionView.reloadData()
//                }
            }
        } else if (Float(offsetY) != 0 && Int(offsetY) == 50 ) { //make dynamic calculation
            let concurrentQueue = DispatchQueue(label: "EventViewCalendarQueue", attributes: .concurrent)
            weak var weakSelf = self
            concurrentQueue.async {
//                let previousCount = weakSelf?.dateList.count
//                weakSelf?.dateList = (weakSelf?.dataProvider.updateDateListForPreviousTwoMonths())!
//                DispatchQueue.main.async {
//                    weakSelf?.collectionView.reloadData()
//                    //weakSelf?.collectionView.scrollRectToVisible(CGRect, animated: <#T##Bool#>)
//                    //weakSelf?.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
//                    print(weakSelf?.dateList.count ?? "Empty")
//                    let currentOffset = weakSelf?.collectionView.contentOffset
//                    let yOffset = Float(((weakSelf?.dateList.count)! - previousCount!) / 7) * Float((weakSelf?.collectionView.frame.size.width)! / 7 )
//                    print(currentOffset ?? "empty current offset")
//                    print(yOffset)
//                    let newOffset = CGPoint(x: (currentOffset?.x)!, y: (currentOffset?.y)! + CGFloat(yOffset))
//                    weakSelf?.collectionView.reloadData()
//                    weakSelf?.collectionView.setContentOffset(newOffset, animated: false)
//                }
            }
            
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let indexPath: IndexPath = (self.tableView.indexPathsForVisibleRows?[0])!
        delegate?.showCalendarHighlighted(self, withIndex: indexPath.section)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let indexPath: IndexPath = (self.tableView.indexPathsForVisibleRows?[0])!
        delegate?.showCalendarHighlighted(self, withIndex: indexPath.section)
    }

}
