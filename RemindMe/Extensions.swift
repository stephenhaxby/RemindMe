//
//  Utilities.swift
//  RemindMe
//
//  Created by Stephen Haxby on 3/2/17.
//  Copyright © 2017 Stephen Haxby. All rights reserved.
//

import UIKit

extension UIButton {

    func toggleTintAndBackground() {
        
        let newTintColor : UIColor? = backgroundColor == nil ? UIColor.white : UIColor(cgColor: backgroundColor!.cgColor)
        let newBackgroundColor : UIColor? = tintColor == UIColor.white ? nil : UIColor(cgColor: tintColor!.cgColor)

        tintColor = newTintColor
        backgroundColor = newBackgroundColor
    }

    func resetTintAndBackground() {

        if tintColor == UIColor.white {

            tintColor = UIColor(cgColor: backgroundColor!.cgColor)
            backgroundColor = nil
        }
    }
}
