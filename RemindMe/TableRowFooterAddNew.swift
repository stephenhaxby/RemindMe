//
//  TableRowFooterAddNew.swift
//  RemindMe
//
//  Created by Stephen Haxby on 23/02/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit

// Footer cell class for adding a new reminder with a gesture recognizer to perform a segue to the edit page
class TableRowFooterAddNew : UITableViewCell {
    
    weak var remindMeViewController : RemindMeViewController?
    
    @IBOutlet weak var footerAddNewView: UIView!
    
    override func layoutSubviews() {
        
        if let containerView = footerAddNewView {
            
            //containerView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
            containerView.backgroundColor = .clearColor()
        }
        
        let selectPress : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TableRowFooterAddNew.viewSelected(_:)))
        selectPress.delegate = self
        //selectPress.minimumPressDuration = 1
        selectPress.numberOfTouchesRequired = 1
        
        self.addGestureRecognizer(selectPress)
    }
    
    func viewSelected(gestureRecognizer:UIGestureRecognizer) {
     
        if (gestureRecognizer.state == UIGestureRecognizerState.Ended) {
         
            if let tableViewController = remindMeViewController {
                
                tableViewController.performSegueWithIdentifier("tableViewCellSegue", sender: self)
            }
        }
    }
}
