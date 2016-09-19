//
//  ReminderTimeTableViewCell.swift
//  RemindMe
//
//  Created by Stephen Haxby on 11/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit

class ReminderTimeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftButton: UIButton!
    
    @IBOutlet weak var rightButton: UIButton!
    
    weak var reminderTimeTableViewController : ReminderTimeTableViewController?
    
    var settings: ReminderTimeTableViewCellItem? {
        didSet {
            
            if settings != nil {
                
                leftButton.isHidden = true
                rightButton.isHidden = true
                
                if let settingOne : Setting = settings!.settingOne {
                    
                    leftButton.setTitle(settingOne.name, for: UIControlState())
                    leftButton.isHidden = false
                }
                
                if let settingTwo : Setting = settings!.settingTwo {
                    
                    rightButton.setTitle(settingTwo.name, for: UIControlState())
                    rightButton.isHidden = false
                }
            }
        }
    }
    
    @IBAction func buttonTouchUpInside(_ sender: AnyObject) {

        if reminderTimeTableViewController != nil && settings != nil {
            
            //When a button is pressed we need to deselect any that are visible
            //Any selected buttons off screen should be taken care of when the user scrolls
            reminderTimeTableViewController!.deselectSettingTimeButtons()
            
            if let button : UIButton = sender as? UIButton {
                
                //Set the parent view controllers reminder setting 
                if button == leftButton {
                    
                    reminderTimeTableViewController!.selectedSetting = settings!.settingOne!
                }
                else if button == rightButton {
                    
                    reminderTimeTableViewController!.selectedSetting = settings!.settingTwo!
                }
                
                button.isSelected = true
            }
        }
    }
}
