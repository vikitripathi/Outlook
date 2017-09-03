//
//  DateCollectionViewCell.swift
//  Outlook
//
//  Created by abhishek dutt on 03/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {

    @IBOutlet var selectedStateBackgroundView: UIView!
    @IBOutlet var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundView = {
            let view = UIView(frame: self.bounds)
            view.backgroundColor = UIColor.makeColor(red: 246.0, green: 249.0, blue: 251.0, alpha: 1.0)
            return view
        }()
        
        self.selectedStateBackgroundView.makeCircular()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
