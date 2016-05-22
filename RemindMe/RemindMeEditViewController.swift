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
    
    var storageFacade : StorageFacadeProtocol?
    
    var isNewReminder : Bool = false
    
    var reminder: RemindMeItem?
    
    deinit{
        
        remindMeViewController = nil
        storageFacade = nil
        reminderTimeTableViewController = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //This makes the textview look like a normal text box (as by default it wont!)
        reminderTitleTextView.layer.borderColor = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0).CGColor
        reminderTitleTextView.layer.borderWidth = 1.0
        reminderTitleTextView.layer.cornerRadius = 5
        
        //Color of the backgroud
        //red="0.94901960784313721" green="0.94901960784313721" blue="0.94901960784313721" alpha="1" />
        
        //Create a save button that looks like a button...
        saveButton.layer.borderColor = UIColor(red:0.5, green:0.5, blue:0.5, alpha:1.0).CGColor
        saveButton.layer.borderWidth = 1.0
        saveButton.layer.cornerRadius = 5
        
        if let reminderItem = reminder {
            
            reminderTitleTextView.text = reminderItem.title
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Make the text box the first reponder for new reminders
        if let reminderItem = reminder {
        
            if reminderItem.title == "" {

                reminderTitleTextView.becomeFirstResponder()
            }
        }
    }
    
    // Sets up the relationships between controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destinationViewController : ReminderTimeTableViewController = segue.destinationViewController as? ReminderTimeTableViewController {
            
            reminderTimeTableViewController = destinationViewController
            
            destinationViewController.remindMeEditViewController = self
            
            destinationViewController.reminder = reminder
        }
    }
    
    // When the back button is pressed we need to save everything
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
        guard storageFacade != nil else {
            
            return
        }
        
        if let reminderItem = reminder {
         
            reminderItem.title = reminderTitleTextView.text
            
            if reminderTimeTableViewController != nil && reminderTimeTableViewController!.selectedSetting != nil {
            
                reminderItem.date = getSelectedAlarmDateComponentsFromDate(reminderTimeTableViewController!.selectedSetting!.time)
            
                storageFacade!.updateReminder(reminderItem)
            }
        }
        
//        // Refresh the main list in the main UI thread
//        if let mainViewController = remindMeViewController {
//            
//            mainViewController.refreshInMainThread()
//        }
    }
    
    // Return an alarm date/time for the selected date, making it either today or tomorrow depending on if the time has passed
    private func getSelectedAlarmDateComponentsFromDate(date : NSDate) -> NSDate {
        
        let morningDateComponents : NSDateComponents = NSDateManager.getDateComponentsFromDate(date)
        
        let currentDateTime = NSDate()
        let reminderDate = NSDateManager.currentDateWithHour(morningDateComponents.hour, minute: morningDateComponents.minute, second: morningDateComponents.second)
        
        if NSDateManager.dateIsAfterDate(currentDateTime, date2: reminderDate) {
            
            return reminderDate
        }
        else {
            
            return NSDateManager.addDaysToDate(reminderDate, days: 1)
        }
    }
}
