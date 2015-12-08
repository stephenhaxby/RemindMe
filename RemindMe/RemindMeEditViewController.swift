//
//  RemindMeEditViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 8/12/2015.
//  Copyright © 2015 Stephen Haxby. All rights reserved.
//

import UIKit
import EventKit

class RemindMeEditViewController : UIViewController {
    
    @IBOutlet weak var reminderTitleTextView: UITextView!
    
    var reminder: EKReminder? {
        didSet {
            
            if let itemReminder = reminder {
            
                
                
                
                
                //TODO: As we set this in prepare for segue, we can't update any UI items because they haven't been created yet...
                //TODO: When the view has finished loading, do it then.
                
                
                
                
                
                
                
                
                
                reminderTitleTextView.text = itemReminder.title
                
//                reminderTextLabel.text = itemReminder.title
//                
//                if let dueDateComponents = itemReminder.dueDateComponents {
//                    
//                    reminderTimeLable.text = NSDateManager.dateStringFromComponents(dueDateComponents)
//                }
//                
//                setupCellVisibilityFor(itemReminder)
            }
        }
    }
}
