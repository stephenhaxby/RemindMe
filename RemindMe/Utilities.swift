//
//  Utilities.swift
//  RemindMe
//
//  Created by Stephen Haxby on 3/2/17.
//  Copyright © 2017 Stephen Haxby. All rights reserved.
//

import UIKit

class Utilities {
    
    //Usage - let allTextFields : [UITextField] = getSubviewsOfView(view: myView)
    func getSubviewsOfView<T>(view : UIView) -> [T] {
        var viewsOfType = [T]()
        
        for subview in view.subviews {
            
            viewsOfType += getSubviewsOfView(view: subview)
            
            if subview is T {
                viewsOfType.append(subview as! T)
            }
        }
        
        return viewsOfType
    }
}
