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
    
    var reminder: EKReminder? {
        didSet {
            
            if let itemReminder = reminder {

                reminderTextLabel.text = itemReminder.title
                
                if let dueDateComponents = itemReminder.dueDateComponents {

                    reminderTimeLable.text = NSDateManager.dateStringFromComponents(dueDateComponents)
                }
            }
        }
    }
}