//
//  DateViewController.swift
//  Outlook
//
//  Created by abhishek dutt on 03/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import UIKit

protocol DateViewDelegate: class {
    func DateView(_ dateView: DateViewController, didSelectCalendarModel model: CalendarModel)
    func showDateViewAsActiveView(_ isActive: Bool)
}

protocol DateViewDataSource: class {
    func fetchDateViewData(isInitialFetch: Bool, isForPreviousData: Bool, completion: @escaping ((_ calendarList: [CalendarModel]) -> ()))
}

//create datasource and dataprovider

class DateViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate  {

    @IBOutlet var collectionView: UICollectionView!
    
    weak var delegate: DateViewDelegate?
    weak var datasource: DateViewDataSource?
    
    private var panGesture: UIPanGestureRecognizer?
    
    private var dateList = [CalendarModel]()
    private var dataProvider = CalendarModuleDataProvider()
    
    private var isLoading = false
    private var isInitialLoading = false
    
    private var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.register(UINib(nibName: "DateCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "dateCell")
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //as calling in viewdidload is too soon as datasource is not set
        self.datasource?.fetchDateViewData(isInitialFetch: true, isForPreviousData: false, completion: { [weak self] (calendarList) in
            
            self?.dateList = calendarList
            DispatchQueue.main.async {
                //weakSelf?.isLoading = false
                let currentDayIndex = self?.dataProvider.currentDayIndex(inCalendarList: calendarList)
                var currentDayModel = self?.dateList[currentDayIndex!]
                currentDayModel!.date.modelState = OutlookCalendar.DateView.CellState.SelectedState(isDayOne: false)
                self?.dateList[currentDayIndex!] = currentDayModel!
                
                
                
                let indexPath = IndexPath(row: currentDayIndex!, section: 0)
                self?.selectedIndexPath = indexPath
                
                self?.collectionView.reloadData()
                
                //let cell = self?.collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell
                //cell?.selectedStateBackgroundView.isHidden = false
                
                self?.collectionView.scrollToItem(at: indexPath, at: .top, animated: false) //set content offset by calculating
                //self?.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.top)
            }
        })
    }
    
    func handleTap(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            delegate?.showDateViewAsActiveView(true)
        case .ended:
            self.collectionView.removeGestureRecognizer(self.panGesture!)
        default:
            break
        }
        
        sender.cancelsTouchesInView = false
    }
    
    func resetState() { //enum
        self.collectionView.addGestureRecognizer(self.panGesture!)
    }
    
//    func reconfigureView(toRow row: Int) {
//        let indexPath: IndexPath = IndexPath(row: row, section: 0)
//        
//        if let selectedIndexpaths = self.collectionView.indexPathsForSelectedItems {
//            for previousIndexPath in selectedIndexpaths {
//                let prevcell = collectionView.cellForItem(at: previousIndexPath) as? DateCollectionViewCell
//                prevcell?.selectedStateBackgroundView.isHidden = true
//                self.collectionView.deselectItem(at: previousIndexPath, animated: false)
//            }
//            //self.collectionView.reloadItems(at: selectedIndexpaths)
//        }
//        
//        self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.top)
//        let cell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell
//        cell?.selectedStateBackgroundView.isHidden = false
//        
//    }
    
    func scrollToCalendarModel(_ model: CalendarModel) {
        
        if let prevSelectedIndexpath = selectedIndexPath {
            let currentDayIndex = prevSelectedIndexpath.row
            var currentDayModel = dateList[currentDayIndex]
            currentDayModel.date.modelState = nil
            dateList[currentDayIndex] = currentDayModel
        }
        
        
        let indexPath = IndexPath(row: dateList.index(of: model)!, section: 0)
        //let cell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell
        //cell?.selectedStateBackgroundView.isHidden = false
        selectedIndexPath = indexPath
        
        let currentDayIndex = indexPath.row
        var currentDayModel = dateList[currentDayIndex]
        currentDayModel.date.modelState = OutlookCalendar.DateView.CellState.SelectedState(isDayOne: false)
        dateList[currentDayIndex] = currentDayModel
        collectionView.reloadData()
        
        collectionView.scrollToItem(at: indexPath, at: .top, animated: false) //set content offset by calculating
        
        //collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.top)
    }
    
    func updateDataSource(_ calendarList: [CalendarModel]) {
        let previousCount = dateList.count
        dateList = calendarList
        isLoading = true
        
        if let prevSelectedIndexpath = selectedIndexPath {
            let currentDayIndex = (dateList.count - previousCount) + prevSelectedIndexpath.row
            var currentDayModel = dateList[currentDayIndex]
            currentDayModel.date.modelState = OutlookCalendar.DateView.CellState.SelectedState(isDayOne: false)
            dateList[currentDayIndex] = currentDayModel
            selectedIndexPath = IndexPath(row: currentDayIndex, section: 0)
        }
        
        let currentOffset = collectionView.contentOffset
        let yOffset = Float(((dateList.count) - previousCount) / 7) * Float((collectionView.frame.size.width) / 7 )
        let newOffset = CGPoint(x: (currentOffset.x), y: (currentOffset.y) + CGFloat(yOffset))
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
            self?.collectionView.setContentOffset(newOffset, animated: false)
            self?.isLoading = false
        }
    }
    
    //MARK: - ScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrolleViewBoundsHeight = scrollView.bounds.size.height
        
        if (Float(offsetY) != 0 && Int(offsetY) > Int(contentHeight - scrolleViewBoundsHeight)   && !isLoading) {
            isLoading = true
            self.datasource?.fetchDateViewData(isInitialFetch: false, isForPreviousData: false, completion: { [weak self] (calendarList) in
                self?.dateList = calendarList
                
                if let prevSelectedIndexpath = self?.selectedIndexPath {
                    let currentDayIndex = prevSelectedIndexpath.row
                    var currentDayModel = self?.dateList[currentDayIndex]
                    currentDayModel?.date.modelState = OutlookCalendar.DateView.CellState.SelectedState(isDayOne: false)
                    self?.dateList[currentDayIndex] = currentDayModel!
                }
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    self?.isLoading = false
                }
            })
        }else if (Float(offsetY) != 0 && Int(offsetY) < 50 && !isLoading ) { //make dynamic calculation
            isLoading = true
            self.datasource?.fetchDateViewData(isInitialFetch: false, isForPreviousData: true, completion: { [weak self] (calendarList) in
                self?.updateDataSource(calendarList)
            })
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        //Intercept and recalculate the desired content offset
        let indexPath = collectionView.indexPathForItem(at: targetContentOffset.pointee)
        
        guard let indexpath = indexPath else {
            return
        }
        
        let cell = collectionView.cellForItem(at: indexpath)
        targetContentOffset.pointee.y = (cell?.frame.origin.y)!
    }
    
    //MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dateList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell",
                                                      for: indexPath) as! DateCollectionViewCell
        //let currentCellModel = dateList[indexPath.row].date as DateModel
        
        //configure cell
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! DateCollectionViewCell
        
        let currentCellModel = dateList[indexPath.row].date as DateModel
        
        guard let state = currentCellModel.modelState else {
            cell.selectedStateBackgroundView.isHidden = true
            cell.dateLabel.text = String(describing: currentCellModel.thisDay)
            
            if currentCellModel.thisDay == 1 {
                cell.monthLabel.text = currentCellModel.getCurrentMonth()
            }else {
                cell.monthLabel.text = nil
            }
            
            if currentCellModel.currentMonth == 1 && currentCellModel.thisDay == 1{
                cell.yearLabel.text = String(describing: currentCellModel.currentYear)
            }else{
                cell.yearLabel.text = nil
            }
            
            return
        }
        
        switch state {
        case .SelectedState(_):
            cell.selectedStateBackgroundView.isHidden = false
            cell.dateLabel.text = String(describing: currentCellModel.thisDay)
            cell.monthLabel.text = nil
            cell.yearLabel.text = nil
        default:
            cell.selectedStateBackgroundView.isHidden = true
            cell.dateLabel.text = String(describing: currentCellModel.thisDay)
            
            if currentCellModel.thisDay == 1 {
                cell.monthLabel.text = currentCellModel.getCurrentMonth()
            }else {
                cell.monthLabel.text = nil
            }
            
            if currentCellModel.currentMonth == 1 && currentCellModel.thisDay == 1{
                cell.yearLabel.text = String(describing: currentCellModel.currentYear)
            }else{
                cell.yearLabel.text = nil
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let prevSelectedIndexpath = selectedIndexPath {
            let currentDayIndex = prevSelectedIndexpath.row
            var currentDayModel = dateList[currentDayIndex]
            currentDayModel.date.modelState = nil
            dateList[currentDayIndex] = currentDayModel
        }
        
        //let cell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell
        //cell?.selectedStateBackgroundView.isHidden = false
        
        selectedIndexPath = indexPath
        let currentDayIndex = indexPath.row
        var currentDayModel = dateList[currentDayIndex]
        currentDayModel.date.modelState = OutlookCalendar.DateView.CellState.SelectedState(isDayOne: false)
        dateList[currentDayIndex] = currentDayModel
        collectionView.reloadData()
        
        delegate?.DateView(self, didSelectCalendarModel: dateList[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //let cell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell
        //cell?.selectedStateBackgroundView.isHidden  = true
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width / 7
        return CGSize(width: floor(itemWidth), height: itemWidth)
    }

}
