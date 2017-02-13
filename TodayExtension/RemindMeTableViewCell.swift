//
//  RemindMeTableViewCell.swift
//  RemindMe
//
//  Created by Stephen Haxby on 28/9/16.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit
import EventKit

class RemindMeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reminderTextLabel: UILabel!
    
    @IBOutlet weak var reminderTimeLable: UILabel!
       
    var reminder: RemindMeItem? {
        didSet {
            
            if let itemReminder = reminder {
                
                reminderTextLabel.text = itemReminder.title
                reminderTimeLable.isHidden = false
                
                switch itemReminder.type {
                    case Constants.ReminderType.dateTime:
                        
                        // Set's the reminder time label
                        let itemReminderAlarmDateComponents : DateComponents = NSDateManager.getDateComponentsFromDate(reminder!.date!)
                        
                        reminderTimeLable.text = NSDateManager.dateStringFromComponents(itemReminderAlarmDateComponents)
                        reminderTimeLable.textColor = UIColor(colorLiteralRed: 1, green: 0.50058603286743164, blue: 0.0016310368664562702, alpha: 1)
                    
                    case Constants.ReminderType.location:
                    
                        reminderTimeLable.text = itemReminder.label
                        reminderTimeLable.textColor = UIColor(colorLiteralRed: 0, green: 0.47843137250000001, blue: 1, alpha: 1)
                    
                    default:
                        reminderTimeLable.isHidden = true
                }
            }
        }
    }
}

