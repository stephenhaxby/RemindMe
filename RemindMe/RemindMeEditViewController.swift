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
            
            if let morningDate : NSDate = getStoredMorningDate() {
                
                if reminderItem.dueDateComponents != nil &&
                    NSDateManager.timeIsEqualToTime(morningDate, date2Components : reminderItem.dueDateComponents!) {
                    
                    morningButton.selected = true
                }
                else {

                    morningButton.selected = false
                }
            }
            
            if let afternoonDate : NSDate = getStoredAfternoonDate() {

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
                    
                    reminderItem.dueDateComponents = getSelectedDueDateComponentsFromDate(morningDate)
                }
            }
            else if (tonightButton.selected) {
                
                if let afternoonDate : NSDate = getStoredAfternoonDate() {
                    
                    reminderItem.dueDateComponents = getSelectedDueDateComponentsFromDate(afternoonDate)
                }
            }
    
            reminderManager!.saveReminder(reminderItem)
        }
    }
    
    private func getSelectedDueDateComponentsFromDate(date : NSDate) -> NSDateComponents {
        
        let morningDateComponents : NSDateComponents = NSDateManager.getDateComponentsFromDate(date)
        
        let currentDateTime = NSDate()
        let reminderDate = NSDateManager.currentDateWithHour(morningDateComponents.hour, minute: morningDateComponents.minute, second: morningDateComponents.second)
        
        if NSDateManager.dateIsAfterDate(currentDateTime, date2: reminderDate) {
            
            return NSDateManager.getDateComponentsFromDate(reminderDate)
        }
        else {
            
            return NSDateManager.getDateComponentsFromDate(NSDateManager.addDaysToDate(reminderDate, days: 1))
        }
    }
    
    private func getStoredMorningDate() -> NSDate? {
        
        return getStoredDateForKey(Constants.MorningAlertTime)
    }
    
    private func getStoredAfternoonDate() -> NSDate? {
        
        return getStoredDateForKey(Constants.AfternoonAlertTime)
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
