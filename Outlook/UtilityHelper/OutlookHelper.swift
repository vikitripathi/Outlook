//
//  OutlookHelper.swift
//  Outlook
//
//  Created by abhishek dutt on 03/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import Foundation
import UIKit

//convert to custom protocol and extension
extension NSLayoutConstraint {
    func setMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

//convert to protcol
extension UIView {
    func makeCircular() {
        let dSize: CGFloat = min(self.frame.size.height, self.frame.size.width )
        self.layer.cornerRadius = dSize / 2.0
        //self.layer.bounds = CGRect(x: 0.0, y: 0.0, width: dSize, height: dSize)
        self.clipsToBounds = true
    }
}


extension UIColor {
    static func appleBlue() -> UIColor {
        return UIColor.init(colorLiteralRed: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0)
    }
    
    static func makeColor(red: Float, green: Float, blue: Float, alpha: Float) -> UIColor {
        return UIColor.init(colorLiteralRed: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}
