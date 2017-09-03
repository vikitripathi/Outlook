//
//  EventTableViewCell.swift
//  Outlook
//
//  Created by abhishek dutt on 04/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet var eventDetailView: UIView!
    @IBOutlet var indicatorView: UIView!
    @IBOutlet var timeView: UIView!
    
    @IBOutlet var eventStartTimeLabel: UILabel!
    @IBOutlet var eventDurationLabel: UILabel!
    @IBOutlet var eventHeaderLabel: UILabel!
    @IBOutlet var eventLocationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.indicatorView.makeCircular()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
