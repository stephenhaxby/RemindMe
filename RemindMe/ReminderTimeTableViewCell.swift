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
                
                leftButton.hidden = true
                rightButton.hidden = true
                
                if let settingOne : Setting = settings!.settingOne {
                    
                    leftButton.setTitle(settingOne.name, forState: UIControlState.Normal)
                    leftButton.hidden = false
                }
                
                if let settingTwo : Setting = settings!.settingTwo {
                    
                    rightButton.setTitle(settingTwo.name, forState: UIControlState.Normal)
                    rightButton.hidden = false
                }
            }
        }
    }
    
    @IBAction func buttonTouchUpInside(sender: AnyObject) {

        if reminderTimeTableViewController != nil {
            
            reminderTimeTableViewController!.deselectSettingTimeButtons()
            
            if let button : UIButton = sender as? UIButton {
                
                if button == leftButton {
                    
                    reminderTimeTableViewController!.setReminder((settings?.settingOne)!)
                }
                else if button == rightButton {
                    
                    reminderTimeTableViewController!.setReminder((settings?.settingTwo)!)
                }
                
                button.selected = true
            }
        }
    }
}
