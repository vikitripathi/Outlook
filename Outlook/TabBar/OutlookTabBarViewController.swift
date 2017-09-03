//
//  OutlookTabBarViewController.swift
//  Outlook
//
//  Created by abhishek dutt on 03/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import UIKit

class OutlookTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let mailViewController = MailViewController()
        mailViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
        //        tabViewController1.tabBarItem = UITabBarItem(
        //        title: "Pie",
        //        image: UIImage(named: "pie_bar_icon"),
        //        tag: 1)
        
        let calendarViewController = CalendarViewController()
        calendarViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 1)
        
        let fileViewControllers = FileViewController()
        fileViewControllers.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 2)
        
        let peopleViewControllers = PeopleViewController()
        peopleViewControllers.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 3)
        
        let viewControllerList = [ mailViewController, calendarViewController, fileViewControllers, peopleViewControllers ]
        
        viewControllers = viewControllerList.map { UINavigationController(rootViewController: $0) }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
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
