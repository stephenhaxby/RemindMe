//
//  RemindMeTableViewCell.swift
//  RemindMe
//
//  Created by Stephen Haxby on 1/12/2015.
//  Copyright © 2015 Stephen Haxby. All rights reserved.
//

import UIKit
import EventKit

class RemindMeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reminderTextLabel: UILabel!
    
    @IBOutlet weak var reminderTimeLable: UILabel!
    
    @IBOutlet weak var addNewButton: UIButton!
    
    var reminder: EKReminder? {
        didSet {
            
            if let itemReminder = reminder {

                reminderTextLabel.text = itemReminder.title
                
                if let dueDateComponents = itemReminder.dueDateComponents {

                    reminderTimeLable.text = NSDateManager.dateStringFromComponents(dueDateComponents)
                }
                
                setupCellVisibilityFor(itemReminder)
            }
        }
    }
    
    @IBAction func addNewButtonTouchUpInside(sender: AnyObject) {
        
        
    }
    
    func setupCellVisibilityFor(reminder : EKReminder){
        
        switch reminder.title{
            
        case Constants.ReminderItemTableViewCell.EmptyCell:
            reminderTextLabel.text = ""
            reminderTimeLable.text = ""
            addNewButton.hidden = true
        case Constants.ReminderItemTableViewCell.NewItemCell:
            reminderTextLabel.text = ""
            reminderTimeLable.text = ""
            addNewButton.hidden = false
        default:
            addNewButton.hidden = true
        }
    }
    
    
}