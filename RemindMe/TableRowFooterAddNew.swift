//
//  TableRowFooterAddNew.swift
//  RemindMe
//
//  Created by Stephen Haxby on 23/02/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit

class TableRowFooterAddNew : UITableViewCell {
    
    weak var remindMeViewController : RemindMeViewController?
    
    @IBOutlet weak var footerAddNewView: UIView!
    
    @IBOutlet weak var addNewButton: UIButton!
    
    @IBAction func addNewButtonTouchUpInside(sender: AnyObject) {
        
//        if remindMeViewController != nil && reminder != nil {
//
//            reminder!.title = ""
//
//            remindMeViewController!.performSegueWithIdentifier("tableViewCellSegue", sender: reminder)
//        }
    }
    
    override func layoutSubviews() {
        
        if let containerView = footerAddNewView {
            
            containerView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        }
        
        let selectPress : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "viewSelected:")
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
