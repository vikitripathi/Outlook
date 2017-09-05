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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "eventCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 93
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
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
        headerView.configureDate(section)
        return headerView
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
