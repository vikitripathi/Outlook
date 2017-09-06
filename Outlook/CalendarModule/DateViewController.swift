//
//  DateViewController.swift
//  Outlook
//
//  Created by abhishek dutt on 03/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import UIKit

protocol DateViewDelegate: class {
    func showEventsHighlighted(_ daterView: DateViewController, withIndex index: Int)
    func showDateViewAsActiveView(_ isActive: Bool)
}

//create datasource and dataprovider

class DateViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate  {

    @IBOutlet var collectionView: UICollectionView!
    
    weak var delegate: DateViewDelegate?
    
    private var panGesture: UIPanGestureRecognizer?
    
    private var dateList = [DateModel]()
    private var dataProvider = CalendarModuleDataProvider()
    
    private var isLoading = false
    private var isInitialLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.register(UINib(nibName: "DateCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "dateCell")
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        
        //move to service protocol
        let concurrentQueue = DispatchQueue(label: "DateViewCalendarQueue", attributes: .concurrent)
        weak var weakSelf = self
        concurrentQueue.async {
            //use guard let for wealself or check unowned
            //weakSelf?.isLoading = true
            weakSelf?.dateList = (weakSelf?.dataProvider.currentDateList)!
            
            DispatchQueue.main.async {
                weakSelf?.collectionView.reloadData()
                //weakSelf?.isLoading = false
                let indexPath = IndexPath(row: (weakSelf?.dataProvider.currentDateIndex)!, section: 0)
                weakSelf?.collectionView.scrollToItem(at: indexPath, at: .top, animated: false) //set content offset by calculating
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func reconfigureView(toRow row: Int) {
        let indexPath: IndexPath = IndexPath(row: row, section: 0)
        
        if let selectedIndexpaths = self.collectionView.indexPathsForSelectedItems {
            for previousIndexPath in selectedIndexpaths {
                let prevcell = collectionView.cellForItem(at: previousIndexPath) as? DateCollectionViewCell
                prevcell?.selectedStateBackgroundView.isHidden = true
                self.collectionView.deselectItem(at: previousIndexPath, animated: false)
            }
            //self.collectionView.reloadItems(at: selectedIndexpaths)
        }
        
        self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.top)
        let cell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell
        cell?.selectedStateBackgroundView.isHidden = false
        
    }
    
    //MARK: - ScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrolleViewBoundsHeight = scrollView.bounds.size.height
        print("offsetY: \(offsetY) , contentHeight: \(contentHeight) , boundsHeight: \(scrolleViewBoundsHeight)")
        
        if (Float(offsetY) != 0 && Int(offsetY) > Int(contentHeight - scrolleViewBoundsHeight)) {
            let concurrentQueue = DispatchQueue(label: "DateViewCalendarQueue", attributes: .concurrent)
            weak var weakSelf = self
            concurrentQueue.async {
                weakSelf?.dateList = (weakSelf?.dataProvider.updateDateListForComingTwoMonths())!
                DispatchQueue.main.async {
                    weakSelf?.collectionView.reloadData()
                }
            }
            
        }else if (Float(offsetY) != 0 && Int(offsetY) == 50 ) { //make dynamic calculation
            let concurrentQueue = DispatchQueue(label: "DateViewCalendarQueue", attributes: .concurrent)
            weak var weakSelf = self
            concurrentQueue.async {
                let previousCount = weakSelf?.dateList.count
                weakSelf?.dateList = (weakSelf?.dataProvider.updateDateListForPreviousTwoMonths())!
                DispatchQueue.main.async {
                    weakSelf?.collectionView.reloadData()
                    //weakSelf?.collectionView.scrollRectToVisible(CGRect, animated: <#T##Bool#>)
                    //weakSelf?.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                    print(weakSelf?.dateList.count ?? "Empty")
                    let currentOffset = weakSelf?.collectionView.contentOffset
                    let yOffset = Float(((weakSelf?.dateList.count)! - previousCount!) / 7) * Float((weakSelf?.collectionView.frame.size.width)! / 7 )
                    print(currentOffset ?? "empty current offset")
                    print(yOffset)
                    let newOffset = CGPoint(x: (currentOffset?.x)!, y: (currentOffset?.y)! + CGFloat(yOffset))
                    weakSelf?.collectionView.reloadData()
                    weakSelf?.collectionView.setContentOffset(newOffset, animated: false)
                }
            }
            
        }
        
        
//        if isLoading {
//            return
//        }
//        //let indexPath = IndexPath(row: (weakSelf?.dataProvider.currentDateIndex)!, section: 0)
//        let currentRowIndex = indexPath.row
//        
//        //move to service protocol
//        let concurrentQueue = DispatchQueue(label: "DateViewCalendarQueue", attributes: .concurrent)
//        weak var weakSelf = self
//        
//        if (currentRowIndex == 28) {
//            concurrentQueue.async {
//                //use guard let for wealself or check unowned
//                weakSelf?.isLoading = true
//                weakSelf?.dateList = (weakSelf?.dataProvider.updateDateListForPreviousTwoMonths())!
//                
//                DispatchQueue.main.async {
//                    weakSelf?.collectionView.reloadData()
//                    //                    let indexPath = IndexPath(row: currentRowIndex, section: 0)
//                    //                    weakSelf?.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
//                    weakSelf?.isLoading = false
//                }
//            }
//            
//        }else if (currentRowIndex == (dateList.count - 28)) {
//            concurrentQueue.async {
//                //use guard let for wealself or check unowned
//                weakSelf?.isLoading = true
//                weakSelf?.dateList = (weakSelf?.dataProvider.updateDateListForComingTwoMonths())!
//                
//                DispatchQueue.main.async {
//                    weakSelf?.collectionView.reloadData()
//                    //                    let indexPath = IndexPath(row: currentRowIndex, section: 0)
//                    //                    weakSelf?.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
//                    weakSelf?.isLoading = false
//                }
//            }
//        }
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
        let currentCellModel = dateList[indexPath.row] as DateModel
        
        //configure cell
        cell.dateLabel.text = String(describing: currentCellModel.thisDay)
        cell.monthLabel.text = currentCellModel.getCurrentMonth()
        //cell.yearLabel.text = String(describing: currentCellModel.currentYear)
        cell.yearLabel.isHidden = true
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! DateCollectionViewCell
        if cell.isSelected {
            cell.selectedStateBackgroundView.isHidden = false
        }else {
            cell.selectedStateBackgroundView.isHidden = true
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell
        cell?.selectedStateBackgroundView.isHidden = false
        
        delegate?.showEventsHighlighted(self, withIndex: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell
        cell?.selectedStateBackgroundView.isHidden  = true
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width / 7
        return CGSize(width: floor(itemWidth), height: itemWidth)
    }

}
