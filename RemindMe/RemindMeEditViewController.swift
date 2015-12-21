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
    
    weak var reminderManager : iCloudReminderManager?
    
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
            reminderTitleTextView.becomeFirstResponder()
            
            let morningDate : NSDate = getStoredMorningDate()
            let afternoonDate : NSDate = getStoredAfternoonDate()
            
            if let itemReminderAlarmDateComponents : NSDateComponents = EKAlarmManager.getFirstAbsoluteDateComponentsFromAlarms(reminderItem.alarms) {
                
                if NSDateManager.timeIsEqualToTime(morningDate, date2Components : itemReminderAlarmDateComponents) {
                        
                        morningButton.selected = true
                }
                else {
                    
                    morningButton.selected = false
                }
                
                if NSDateManager.timeIsEqualToTime(afternoonDate, date2Components: itemReminderAlarmDateComponents) {
                        
                        tonightButton.selected = true
                }
                else {
                    
                    tonightButton.selected = false
                }
            }
            else {
                
                let morningDateComponents : NSDateComponents = NSDateManager.getDateComponentsFromDate(morningDate)
                
                let afternoonDateComponents : NSDateComponents = NSDateManager.getDateComponentsFromDate(afternoonDate)
                
                let morningDateCompare : NSDate = NSDateManager.currentDateWithHour(morningDateComponents.hour, minute: morningDateComponents.minute, second: morningDateComponents.second)
                
                let afternoonDateCompare : NSDate = NSDateManager.currentDateWithHour(afternoonDateComponents.hour, minute: afternoonDateComponents.minute, second: afternoonDateComponents.second)
                
                if NSDateManager.dateIsBeforeDate(NSDate(), date2: morningDateCompare)
                    || NSDateManager.dateIsAfterDate(NSDate(), date2: afternoonDateCompare) {
                 
                    morningButton.selected = true
                }
                else if NSDateManager.dateIsBeforeDate(NSDate(), date2: afternoonDateCompare) {
                 
                    tonightButton.selected = true
                }
            }
        }
    }
    
    @IBAction func timeButtonTouchUpInside(sender: AnyObject) {
     
        tonightButton.selected = false
        morningButton.selected = false
        
        if let timeButton : UIButton = sender as? UIButton {
            
            timeButton.selected = true
        }
    }
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
        guard reminderManager != nil else {
            
            return
        }
        
        if let reminderItem = reminder {
         
            reminderItem.title = reminderTitleTextView.text
            
            if morningButton.selected {
                
                if let morningDate : NSDate = getStoredMorningDate() {
                    
                    reminderItem.alarms = [getSelectedAlarmDateComponentsFromDate(morningDate)]
                    
                    //reminderItem.dueDateComponents = getSelectedDueDateComponentsFromDate(morningDate)
                }
            }
            else if (tonightButton.selected) {
                
                if let afternoonDate : NSDate = getStoredAfternoonDate() {

                    reminderItem.alarms = [getSelectedAlarmDateComponentsFromDate(afternoonDate)]
                    
                    //reminderItem.dueDateComponents = getSelectedDueDateComponentsFromDate(afternoonDate)
                }
            }
    
            reminderManager!.saveReminder(reminderItem)
        }
    }
    
    private func getSelectedAlarmDateComponentsFromDate(date : NSDate) -> EKAlarm {
        
        let morningDateComponents : NSDateComponents = NSDateManager.getDateComponentsFromDate(date)
        
        let currentDateTime = NSDate()
        let reminderDate = NSDateManager.currentDateWithHour(morningDateComponents.hour, minute: morningDateComponents.minute, second: morningDateComponents.second)
        
        if NSDateManager.dateIsAfterDate(currentDateTime, date2: reminderDate) {
            
            return EKAlarm(absoluteDate: reminderDate)
            
            //return NSDateManager.getDateComponentsFromDate(reminderDate)
        }
        else {
            
            return EKAlarm(absoluteDate: NSDateManager.addDaysToDate(reminderDate, days: 1))
            
            //return NSDateManager.getDateComponentsFromDate(NSDateManager.addDaysToDate(reminderDate, days: 1))
        }
    }
    
    private func getStoredMorningDate() -> NSDate {
        
        let morningTime : NSDate? = getStoredDateForKey(Constants.MorningAlertTime)
        
        guard morningTime != nil else {
         
            return Constants.DefaultMorningTime
        }
        
        return morningTime!
    }
    
    private func getStoredAfternoonDate() -> NSDate {
        
        let afternoonTime : NSDate? = getStoredDateForKey(Constants.AfternoonAlertTime)
        
        guard afternoonTime != nil else {
            
            return Constants.DefaultMorningTime
        }
        
        return afternoonTime!
    }
    
    private func getStoredDateObjectForKey(key : String) -> AnyObject? {
        
        return defaults.objectForKey(key)
    }
    
    private func getStoredDateForKey(key : String) -> NSDate? {
        
        if let storedMorningDate = getStoredDateObjectForKey(key) {
            
            return storedMorningDate as? NSDate
        }
        
        return nil
    }
}
