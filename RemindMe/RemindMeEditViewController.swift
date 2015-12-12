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
    
    @IBOutlet weak var tonightButton: UIButton!
    
    @IBOutlet weak var morningButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var reminder: EKReminder?
    
    var defaults : NSUserDefaults {
        
        get {
            
            return NSUserDefaults.standardUserDefaults()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        if let reminderItem = reminder {
            
            reminderTitleTextView.text = reminderItem.title
            
            if let storedMorningDate : AnyObject = defaults.objectForKey(Constants.MorningAlertTime) {
                
                if let morningDate : NSDate = storedMorningDate as? NSDate {
                    
                    if reminderItem.dueDateComponents != nil &&
                    
                        NSDateManager.timeIsEqualToTime(morningDate, date2Components : reminderItem.dueDateComponents!) {
                        
                        morningButton.selected = true
                    }
                    else {
                        
                        morningButton.selected = false
                    }
                }
            }
            
            if let storedAfternoonDate : AnyObject = defaults.objectForKey(Constants.AfternoonAlertTime) {
            
                if let afternoonDate : NSDate = storedAfternoonDate as? NSDate {

                    if reminderItem.dueDateComponents != nil &&
                        NSDateManager.timeIsEqualToTime(afternoonDate, date2Components: reminderItem.dueDateComponents!) {
                            
                            tonightButton.selected = true
                    }
                    else {
                        
                        tonightButton.selected = false
                    }
                }
            }
        }
    }
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
        if let reminderItem = reminder {
         
            reminderItem.title = reminderTitleTextView.text
            
            if morningButton.selected {
                
                if let storedMorningDate : AnyObject = defaults.objectForKey(Constants.MorningAlertTime) {
                    
                    if let morningDate : NSDate = storedMorningDate as? NSDate {
                        
                        let date : NSDate = NSDate()
                        let calendar = NSCalendar.currentCalendar()
                        
                        
                        let firstDateHour = calendar.component(NSCalendarUnit.Hour, fromDate: date)
                        let firstDateMinute = calendar.component(NSCalendarUnit.Minute, fromDate: date)

                        
//                        reminderItem.dueDateComponents =
                    }
                }
            }
            else if (tonightButton.selected) {
                
  //              reminderItem.dueDateComponents =
            }
        }
    }
}
