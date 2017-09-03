//
//  EventTableViewCellHeaderView.swift
//  Outlook
//
//  Created by abhishek dutt on 04/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import UIKit

class EventTableViewCellHeaderView: UIView {

    var label: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.makeColor(red: 246.0, green: 249.0, blue: 251.0, alpha: 1.0)
        
        label = UILabel(frame: CGRect(x: 8, y: 2, width: self.frame.size.width, height: 16))
        label?.textAlignment = NSTextAlignment.left
        label?.font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightRegular)
        label?.textColor = UIColor.lightGray
        self.addSubview(label!)
    }
    
    func configureDate(_ section: Int)  {
        label?.text = "Monday, September \(section)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
