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
    
    weak var remindMeViewController : RemindMeViewController?
    
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
                
                if let itemReminderAlarmDateComponents : NSDateComponents = EKAlarmManager.getFirstAbsoluteDateComponentsFromAlarms(itemReminder.alarms) {
                    
                    reminderTimeLable.text = NSDateManager.dateStringFromComponents(itemReminderAlarmDateComponents)
                }
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
}