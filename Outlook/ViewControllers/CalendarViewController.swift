//
//  CalendarViewController.swift
//  Outlook
//
//  Created by abhishek dutt on 03/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import UIKit

//set view of days letter on top and adjust constraint calculation
class CalendarViewController: UIViewController {
    @IBOutlet var dateContainerView: UIView!

    @IBOutlet var eventsContainerView: UIView!
    
    @IBOutlet var dateViewHeight: NSLayoutConstraint!
    
    @IBOutlet var calendarLabelsViewHeight: NSLayoutConstraint!
    
    @IBOutlet var calendarLabelView: UIView!
    
    var dateViewState: OutlookCalendar.ViewsCategory?
    
    fileprivate var dataProvider = CalendarModuleDataProvider()
    fileprivate var dateList = [CalendarModel]()
    
    fileprivate lazy var dateViewController: DateViewController = {
        var viewController = DateViewController()
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    fileprivate lazy var eventsViewController: EventViewController = {
        var viewController = EventViewController()
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    fileprivate lazy var viewSize: CGSize = {
       return CGSize(width: self.view.frame.width, height: self.view.frame.height)
    }()
    
    let concurrentQueue = DispatchQueue(label: "CalendarModuleConcurrentQueue", attributes: .concurrent)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Calendar"
        
        navigationController?.navigationBar.isTranslucent = false
        let navigationBar = navigationController?.navigationBar
        navigationBar?.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        navigationBar?.shadowImage = UIImage()
        
        dateViewState = OutlookCalendar.ViewsCategory.DateView(state: .Normal)
        //calendarLabelsViewHeight.constant = self.view.frame.width / 7
        
        dateViewController.delegate = self
        dateViewController.datasource = self
        
        eventsViewController.delegate = self
        eventsViewController.datasource = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarLabelView.isHidden = false
        configureView(0)
        
        /*
        weak var weakSelf = self
        DispatchQueue.main.async {
            // do stuff here
            weakSelf?.calendarLabelView.isHidden = false
            weakSelf?.configureView(0)
            //weakSelf?.add(asChildViewController: (weakSelf?.dateViewController)!)
            //add(asChildViewController: eventsViewController)
        }
        */
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        if viewController is DateViewController {
            // Configure Child View
            viewController.view.frame = dateContainerView.bounds
            
            // Add Child View as Subview
            dateContainerView.addSubview(viewController.view)
        }else if viewController is EventViewController {
            // Configure Child View
            viewController.view.frame = eventsContainerView.bounds
            
            // Add Child View as Subview
            eventsContainerView.addSubview(viewController.view)
            
        }
        
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleRightMargin, .flexibleBottomMargin]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    func configureView(_ animation: Float) {
        switch dateViewState! {
        case .DateView(let state):
            switch state {
            case .Normal:
                 dateViewController.resetState()
            default:
                break
            }
           
        default:
            break
        }
        
        
        let newHeightConstraintConstant: CGFloat = OutlookCalendar.getDateViewVisibleHeight(forDateView: dateViewState!, andContainerViewFrameSize: viewSize)
        dateViewHeight.constant = newHeightConstraintConstant
        
        //neeedsupdateconstriant call?
        
        weak var weakSelf = self
        UIView.animate(withDuration: Double(animation)) {
            weakSelf?.view.layoutIfNeeded()
        }
    }

}

extension CalendarViewController: EventViewDataSource {
    func fetchEventsViewData(isInitialFetch: Bool, isForPreviousData: Bool, completion: @escaping ((_ calendarList: [CalendarModel]) -> ())) {
        //dataProvider
        if isInitialFetch {
            //move to service protocol
            weak var weakSelf = self
            concurrentQueue.async(flags: .barrier) {
                if weakSelf?.dateList.count == 0 {
                    weakSelf?.dateList = (weakSelf?.dataProvider.currentDateList)!  //TODO: Check race conditions
                }
                
                completion((weakSelf?.dateList)!)
            }
        }else {
            if isForPreviousData {
                weak var weakSelf = self
                concurrentQueue.async(flags: .barrier) {
                    weakSelf?.dateList = (weakSelf?.dataProvider.updateDateListForPreviousTwoMonths())!  //TODO: Check race conditions
                    weakSelf?.dateViewController.updateDataSource((weakSelf?.dateList)!)
                    completion((weakSelf?.dateList)!)
                }
            }else {
                weak var weakSelf = self
                concurrentQueue.async(flags: .barrier) {
                    weakSelf?.dateList = (weakSelf?.dataProvider.updateDateListForComingTwoMonths())!  //TODO: Check race conditions
                    weakSelf?.dateViewController.updateDataSource((weakSelf?.dateList)!)
                    completion((weakSelf?.dateList)!)
                }
            }
        }
    }
}

extension CalendarViewController: DateViewDataSource {
    func fetchDateViewData(isInitialFetch: Bool, isForPreviousData: Bool, completion: @escaping ((_ calendarList: [CalendarModel]) -> ())) {
        if isInitialFetch {
            //move to service protocol
            //use guard let for weakself or check unowned
            weak var weakSelf = self
            concurrentQueue.async(flags: .barrier) {
                if weakSelf?.dateList.count == 0 {
                    weakSelf?.dateList = (weakSelf?.dataProvider.currentDateList)!  //TODO: Check race conditions
                }
                
                completion((weakSelf?.dateList)!)
            }
        }else {
            if isForPreviousData {
                weak var weakSelf = self
                concurrentQueue.async(flags: .barrier) {
                    weakSelf?.dateList = (weakSelf?.dataProvider.updateDateListForPreviousTwoMonths())!  //TODO: Check race conditions
                    weakSelf?.eventsViewController.updateDataSource((weakSelf?.dateList)!,isForPreviousData: true)
                    completion((weakSelf?.dateList)!)
                }
            }else {
                weak var weakSelf = self
                concurrentQueue.async(flags: .barrier) {
                    weakSelf?.dateList = (weakSelf?.dataProvider.updateDateListForComingTwoMonths())!  //TODO: Check race conditions
                    weakSelf?.eventsViewController.updateDataSource((weakSelf?.dateList)!,isForPreviousData: false)
                    completion((weakSelf?.dateList)!)
                }
            }
        }
    }
}


extension CalendarViewController: DateViewDelegate {
    
    func DateView(_ dateView: DateViewController, didSelectCalendarModel model: CalendarModel) {
        eventsViewController.scrollToCalendarModel(model)
    }
    
    func showDateViewAsActiveView(_ isActive: Bool) {
        if isActive {
            dateViewState = OutlookCalendar.ViewsCategory.DateView(state: .Focussed)
            configureView(0.5)
        }
    }
}

extension CalendarViewController: EventViewDelegate {
    
    func EventView(_ eventsView: EventViewController, didSelectCalendarModel model: CalendarModel) {
        dateViewController.scrollToCalendarModel(model)
    }
    
    func showEventViewAsActiveView(_ isActive: Bool) {
        if isActive {
            switch dateViewState! {
            case .DateView(let state):
                switch state {
                case .Normal:
                    break
                case .Focussed:
                    dateViewState = OutlookCalendar.ViewsCategory.DateView(state: .Normal)
                    configureView(0.5)
                }
                
            default:
                break
            }
            
            
        }
    }
}
