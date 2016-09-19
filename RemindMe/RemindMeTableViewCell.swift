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
    
    var reminder: RemindMeItem? {
        didSet {
            
            if let itemReminder = reminder {

                reminderTextLabel.text = itemReminder.title
                
                let originalReminderText : NSString = NSString(string: reminderTextLabel.text!)
                
                var reminderText : NSString = NSString(string: reminderTextLabel.text!)
                
                truncateText(&reminderText, forLabel: reminderTextLabel)
                
                var newReminderText = String(reminderText)
                
                // If the original text is greater than the truncated version, replace the final 3 characters with "..."
                if originalReminderText.length > reminderText.length {
                    
                    reminderText = reminderText.substring(with: NSRange(location: 0, length: reminderText.length-3)) as NSString
                    
                    newReminderText.append("...")
                }
                
                reminderTextLabel.text = newReminderText
                
                // Set's the reminder time label
                if let itemReminderAlarmDateComponents : DateComponents = NSDateManager.getDateComponentsFromDate(itemReminder.date!) {
                    
                    reminderTimeLable.text = NSDateManager.dateStringFromComponents(itemReminderAlarmDateComponents)
                }
            }
        }
    }
    
    // Function to truncate the text for a label based on it's visible size.
    func truncateText(_ text : inout NSString, forLabel : UILabel) {
        
        let size : CGSize = text.size(attributes: [NSFontAttributeName : reminderTextLabel.font!])
        
        let labelWidth = forLabel.bounds.size.width
        
        if size.width > labelWidth {
            
            text = text.substring(with: NSRange(location: 0, length: text.length-1)) as NSString
            
            truncateText(&text, forLabel: forLabel)
        }
    }
}
