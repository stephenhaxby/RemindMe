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
    
    func displayAlert(heading : String, message : String, inViewController controller : UIViewController) {
        
        DispatchQueue.main.async { () -> Void in
            
            let alertController = UIAlertController(title: heading, message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:
                { (action: UIAlertAction!) in
                    
            }))
            
            controller.present(alertController, animated: true, completion: nil)
        }
    }
}
