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
    
    var dateViewState: OutlookCalendar.ViewsCategory?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Calendar"
        
        navigationController?.navigationBar.isTranslucent = false
        
        dateViewState = OutlookCalendar.ViewsCategory.DateView(state: .Normal)
        
        dateViewController.delegate = self
        eventsViewController.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        weak var weakSelf = self
        DispatchQueue.main.async {
            // do stuff here
            weakSelf?.configureView(0)
            //weakSelf?.add(asChildViewController: (weakSelf?.dateViewController)!)
            //add(asChildViewController: eventsViewController)
        }
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

extension CalendarViewController: DateViewDelegate {
    
    func showEventsHighlighted(_ daterView: DateViewController, withIndex index: Int) {
        //eventsViewController.reconfigureView(toRow: index)
    }
    
    func showDateViewAsActiveView(_ isActive: Bool) {
        if isActive {
            dateViewState = OutlookCalendar.ViewsCategory.DateView(state: .Focussed)
            configureView(0.5)
        }
    }
}

extension CalendarViewController: EventViewDelegate {
    
    func showCalendarHighlighted(_ eventsView: EventViewController, withIndex index: Int) {
        //dateViewController.reconfigureView(toRow: index)
    }
    
    func showEventViewAsActiveView(_ isActive: Bool) {
        if isActive {
            dateViewState = OutlookCalendar.ViewsCategory.DateView(state: .Normal)
            configureView(0.5)
        }
    }
}
