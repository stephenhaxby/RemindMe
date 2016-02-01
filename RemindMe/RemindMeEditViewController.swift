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
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var reminderTimeTableViewControllerContainer: UIView!
    
    weak var reminderTimeTableViewController : ReminderTimeTableViewController?
    
    weak var remindMeViewController : RemindMeViewController?
    
    weak var reminderManager : iCloudReminderManager?
    
    var reminder: EKReminder?
    
    var defaults : NSUserDefaults {
        
        get {
            
            return NSUserDefaults.standardUserDefaults()
        }
    }
    
    deinit{
        
        remindMeViewController = nil
        reminderManager = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This makes the textview look like a normal text box
        reminderTitleTextView.layer.borderColor = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0).CGColor
        reminderTitleTextView.layer.borderWidth = 1.0
        reminderTitleTextView.layer.cornerRadius = 5
        
        //Color of the backgroud
        //red="0.94901960784313721" green="0.94901960784313721" blue="0.94901960784313721" alpha="1" />
        
        saveButton.layer.borderColor = UIColor(red:0.5, green:0.5, blue:0.5, alpha:1.0).CGColor
        saveButton.layer.borderWidth = 1.0
        saveButton.layer.cornerRadius = 5
        
        if let reminderItem = reminder {
            
            reminderTitleTextView.text = reminderItem.title
            
            if reminderTimeTableViewController != nil{
                
                reminderTimeTableViewController!.deselectSettingTimeButtons()
                
                if let itemReminderAlarmDateComponents : NSDateComponents = EKAlarmManager.getFirstAbsoluteDateComponentsFromAlarms(reminderItem.alarms) {
                    
                    for var i = 0; i < reminderTimeTableViewController!.tableView.visibleCells.count; i++ {
                        
                        if let reminderTimeTableViewCell : ReminderTimeTableViewCell = reminderTimeTableViewController!.tableView.visibleCells[i] as? ReminderTimeTableViewCell {
                            
                            if let leftButton = reminderTimeTableViewCell.leftButton {
                                
                                if reminderTimeTableViewCell.settings != nil && reminderTimeTableViewCell.settings!.settingOne != nil {
                                    
                                    if NSDateManager.timeIsEqualToTime(reminderTimeTableViewCell.settings!.settingOne!.time, date2Components : itemReminderAlarmDateComponents) {
                                        
                                        leftButton.selected = true
                                        break
                                    }
                                }
                            }
                            
                            if let rightButton = reminderTimeTableViewCell.rightButton {
                                
                                if reminderTimeTableViewCell.settings != nil && reminderTimeTableViewCell.settings!.settingTwo != nil {
                                    
                                    if NSDateManager.timeIsEqualToTime(reminderTimeTableViewCell.settings!.settingTwo!.time, date2Components : itemReminderAlarmDateComponents) {
                                     
                                        rightButton.selected = true
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if let reminderItem = reminder {
        
            if reminderItem.title == "" {

                reminderTitleTextView.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func timeButtonTouchUpInside(sender: AnyObject) {
     
        if let timeButton : UIButton = sender as? UIButton {
            
            timeButton.selected = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destinationViewController : ReminderTimeTableViewController = segue.destinationViewController as? ReminderTimeTableViewController {
            
            reminderTimeTableViewController = destinationViewController
            
            destinationViewController.remindMeEditViewController = self
        }
    }
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
        guard reminderManager != nil else {
            
            return
        }
        
        if let reminderItem = reminder {
         
            reminderItem.title = reminderTitleTextView.text
            
            if reminderTimeTableViewController != nil {
                
                var selectedTime : NSDate?
                
                for var i = 0; i < reminderTimeTableViewController!.tableView.visibleCells.count; i++ {
                    
                    if let reminderTimeTableViewCell : ReminderTimeTableViewCell = reminderTimeTableViewController!.tableView.visibleCells[i] as? ReminderTimeTableViewCell {
                        
                        if let leftButton = reminderTimeTableViewCell.leftButton {
                            
                            if leftButton.selected && reminderTimeTableViewCell.settings != nil && reminderTimeTableViewCell.settings!.settingOne != nil {
                                
                                selectedTime = reminderTimeTableViewCell.settings!.settingOne!.time
                                break
                            }
                        }
                        
                        if let rightButton = reminderTimeTableViewCell.rightButton {
                            
                            if rightButton.selected && reminderTimeTableViewCell.settings != nil && reminderTimeTableViewCell.settings!.settingTwo != nil {
                                
                                selectedTime = reminderTimeTableViewCell.settings!.settingTwo!.time
                                break
                            }
                        }
                    }
                }
                
                if selectedTime != nil {
                    
                    reminderItem.alarms = [getSelectedAlarmDateComponentsFromDate(selectedTime!)]
                    
                    reminderManager!.saveReminder(reminderItem)
                    
                    return
                }
            }
        }
        
        if let mainViewController = remindMeViewController {
            
            mainViewController.refreshInMainThread()
        }
    }
    
    private func getSelectedAlarmDateComponentsFromDate(date : NSDate) -> EKAlarm {
        
        let morningDateComponents : NSDateComponents = NSDateManager.getDateComponentsFromDate(date)
        
        let currentDateTime = NSDate()
        let reminderDate = NSDateManager.currentDateWithHour(morningDateComponents.hour, minute: morningDateComponents.minute, second: morningDateComponents.second)
        
        if NSDateManager.dateIsAfterDate(currentDateTime, date2: reminderDate) {
            
            return EKAlarm(absoluteDate: reminderDate)
        }
        else {
            
            return EKAlarm(absoluteDate: NSDateManager.addDaysToDate(reminderDate, days: 1))
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
