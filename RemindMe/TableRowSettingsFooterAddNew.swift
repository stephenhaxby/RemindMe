//
//  TableRowSettingsFooterAddNew.swift
//  RemindMe
//
//  Created by Stephen Haxby on 29/02/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit

// Footer cell class for adding a new settings alarm item; complete with gesture recogniser to add the new row
class TableRowSettingsFooterAddNew : UITableViewCell {

    @IBOutlet weak var footerAddNewView: UIView!
    
    weak var settingsTableViewController: SettingsTableViewController!
    
    override func layoutSubviews() {
        
        if let containerView = footerAddNewView {
            
            containerView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        }
        
        let selectPress : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TableRowSettingsFooterAddNew.viewSelected(_:)))
        selectPress.delegate = self
        //selectPress.minimumPressDuration = 1
        selectPress.numberOfTouchesRequired = 1
        
        self.addGestureRecognizer(selectPress)
    }
    
    @IBAction func addNewButtonTouchUpInside(sender: AnyObject) {
        
        if let tableViewController = settingsTableViewController {
            
            tableViewController.addNewSettingRow()
        }
    }

    func viewSelected(gestureRecognizer:UIGestureRecognizer) {
        
        if (gestureRecognizer.state == UIGestureRecognizerState.Ended) {
            
            if let tableViewController = settingsTableViewController {
                
                tableViewController.addNewSettingRow()
            }
        }
    }
}
