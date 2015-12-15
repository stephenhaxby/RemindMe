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
                
                let originalReminderText : NSString = NSString(string: reminderTextLabel.text!)
                
                var reminderText : NSString = NSString(string: reminderTextLabel.text!)
                
                truncateText(reminderText, forLabel: reminderTextLabel)
                
                var newReminderText = String(reminderText)
                
                if originalReminderText.length > reminderText.length {
                    
                    reminderText = reminderText.substringWithRange(NSRange(location: 0, length: reminderText.length-3))
                    
                    newReminderText.appendContentsOf("...")
                }
                
                reminderTextLabel.text = newReminderText
                
                if let dueDateComponents = itemReminder.dueDateComponents {

                    reminderTimeLable.text = NSDateManager.dateStringFromComponents(dueDateComponents)
                }
                
                setupCellVisibilityFor(itemReminder)
            }
        }
    }
    
    func truncateText(var text : NSString, forLabel : UILabel) {
        
        let size : CGSize = text.sizeWithAttributes([NSFontAttributeName : reminderTextLabel.font!])
        
        let labelWidth = forLabel.bounds.size.width
        
        if size.width > labelWidth {
            
            text = text.substringWithRange(NSRange(location: 0, length: text.length-1))
            
            truncateText(text, forLabel: forLabel)
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