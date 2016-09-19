//
//  RemindMeEditViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 8/12/2015.
//  Copyright © 2015 Stephen Haxby. All rights reserved.
//

import UIKit

class RemindMeEditViewController : UIViewController {
    
    @IBOutlet weak var reminderTitleTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var reminderTimeTableViewControllerContainer: UIView!
    
    weak var reminderTimeTableViewController : ReminderTimeTableViewController?
    
    weak var remindMeViewController : RemindMeViewController?
    
    var storageFacade : StorageFacadeProtocol?

    var reminder : RemindMeItem?
    
    deinit{
        
        remindMeViewController = nil
        storageFacade = nil
        reminderTimeTableViewController = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //This makes the textview look like a normal text box (as by default it wont!)
        reminderTitleTextView.layer.borderColor = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0).cgColor
        reminderTitleTextView.layer.borderWidth = 1.0
        reminderTitleTextView.layer.cornerRadius = 5
        
        //Color of the backgroud
        //red="0.94901960784313721" green="0.94901960784313721" blue="0.94901960784313721" alpha="1" />
        
        //Create a save button that looks like a button...
        saveButton.layer.borderColor = UIColor(red:0.5, green:0.5, blue:0.5, alpha:1.0).cgColor
        saveButton.layer.borderWidth = 1.0
        saveButton.layer.cornerRadius = 5
        
        if let reminderItem = reminder {
            
            reminderTitleTextView.text = reminderItem.title
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let background = UIImage(named: "old-white-background")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
        
        if reminder == nil {
        
            reminderTitleTextView.becomeFirstResponder()
        }
    }
    
    // Sets up the relationships between controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let destinationViewController : ReminderTimeTableViewController = segue.destination as? ReminderTimeTableViewController {
            
            reminderTimeTableViewController = destinationViewController
            
            destinationViewController.remindMeEditViewController = self
            
            destinationViewController.reminder = reminder
        }
    }
    
    // When the back button is pressed we need to save everything
    @IBAction override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
        guard storageFacade != nil else {
            
            return
        }

        if reminder == nil {
            
            reminder = RemindMeItem()
        }
        
        reminder!.title = reminderTitleTextView.text
        
        if reminderTimeTableViewController != nil && reminderTimeTableViewController!.selectedSetting != nil {
            
            reminder!.date = getSelectedAlarmDateComponentsFromDate(reminderTimeTableViewController!.selectedSetting!.time as Date) as (Date)
            
            storageFacade!.createOrUpdateReminder(reminder!)
        }
    }
    
    // Return an alarm date/time for the selected date, making it either today or tomorrow depending on if the time has passed
    fileprivate func getSelectedAlarmDateComponentsFromDate(_ date : Date) -> Date {
        
        let morningDateComponents : DateComponents = NSDateManager.getDateComponentsFromDate(date)
        
        let currentDateTime = Date()
        let reminderDate = NSDateManager.currentDateWithHour(morningDateComponents.hour!, minute: morningDateComponents.minute!, second: morningDateComponents.second!)
        
        if NSDateManager.dateIsAfterDate(currentDateTime, date2: reminderDate) {
            
            return reminderDate
        }
        else {
            
            return NSDateManager.addDaysToDate(reminderDate, days: 1)
        }
    }
}
