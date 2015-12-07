//
//  ViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 26/11/2015.
//  Copyright © 2015 Stephen Haxby. All rights reserved.
//

import UIKit
import EventKit

class RemindMeViewController: UITableViewController {

    var reminderList = [EKReminder]()
    
    let reminderManager : iCloudReminderManager = iCloudReminderManager()
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet var remindersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set the text and font of the Settings button (unicode)
        settingsButton.setTitle("\u{2699}", forState: UIControlState.Normal)
        settingsButton.titleLabel?.font = UIFont.boldSystemFontOfSize(26)
        
        reminderManager.remindersListName = Constants.RemindersListName
        // Request access to Reminders
        reminderManager.requestAccessToReminders(requestedAccessToReminders)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshControlValueChanged(sender: UIRefreshControl) {
        
        loadRemindersList()
        
        sender.endRefreshing()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reminderList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //TODO: None of this is checked for nulls blah blah blah...
        
        let cell : RemindMeTableViewCell = tableView.dequeueReusableCellWithIdentifier("ReminderCell")! as! RemindMeTableViewCell
        
        let reminderListItem : EKReminder? = reminderList[indexPath.row]
        
        cell.reminder = reminderListItem!
        
        return cell
    }
    
    func endRefreshControl(){
        
        if let refresh = refreshControl{
            
            refresh.endRefreshing()
        }
    }
    
    func displayError(message : String){
        
        //Display an alert to specify that we couldn't get access
        let errorAlert = UIAlertController(title: "Error!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        //Add an Ok button to the alert
        errorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:
            { (action: UIAlertAction!) in
                
        }))
        
        //Present the alert
        self.presentViewController(errorAlert, animated: true, completion: nil)
    }
    
    func loadRemindersList(){
        
        reminderManager.getReminders(getReminderList)
    }
    
    func getReminderList(iCloudShoppingList : [EKReminder]){

        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            if let reminderListTable = self.tableView{
                
                let scheduledItems : [EKReminder] = iCloudShoppingList.filter({(reminder : EKReminder) in reminder.dueDateComponents != nil})
                
                //Join the two lists from above
                self.reminderList = scheduledItems
                
                //Request a reload of the Table
                reminderListTable.reloadData()
            }
        }
    }
    
    //Once access is granted to the reminders list
    func requestedAccessToReminders(status : Bool){
        
        if status {
            
            loadRemindersList()
        }
        else{
            
            displayError("Please allow Remind Me to access 'Reminders'...")
        }
        
        endRefreshControl()
    }
    
    
    
    
    
//    //This method is setting which cells can be edited
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        
//        //Don't allow delete of the last blank row...
//        if(indexPath.row < reminderList.count){
//            return true
//        }
//        
//        return false
//    }
    
    //This method is for the swipe left to delete
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.row < reminderList.count){
            
            let listItem : EKReminder = reminderList[indexPath.row]
            
            guard reminderManager.removeReminder(listItem) else {
                
                displayError("Your reminder list item could not be removed...")
                
                return
            }
        }
    }
}

