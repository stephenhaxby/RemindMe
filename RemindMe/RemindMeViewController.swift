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

    var eventStoreObserver : NSObjectProtocol?
    
    var reminderList = [EKReminder]()
    
    let reminderManager : iCloudReminderManager = iCloudReminderManager()
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet var remindersTableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        eventStoreObserver = NSNotificationCenter.defaultCenter().addObserverForName(EKEventStoreChangedNotification, object: nil, queue: nil){
            (notification) -> Void in
            
            self.loadRemindersListWithRefresh(true)
        }
    }
    
    deinit {
        
        if let observer = eventStoreObserver{
            
            NSNotificationCenter.defaultCenter().removeObserver(observer, name: EKEventStoreChangedNotification, object: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set the text and font of the Settings button (unicode)
        settingsButton.setTitle("\u{2699}", forState: UIControlState.Normal)
        settingsButton.titleLabel?.font = UIFont.boldSystemFontOfSize(26)
        
        startRefreshControl()
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let reminderListItem : EKReminder = sender as? EKReminder {
            
            if segue.identifier == "tableViewCellSegue" {
                
                let remindMeEditViewController : RemindMeEditViewController = segue.destinationViewController as! RemindMeEditViewController
                
                remindMeEditViewController.remindMeViewController = self
                remindMeEditViewController.reminderManager = reminderManager
                remindMeEditViewController.reminder = reminderListItem
            }
        }
    }
    
    func refreshInMainThread() {
        
        //As we a in another thread, post back to the main thread so we can update the UI
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.loadRemindersListWithRefresh(true)
        }
    }
    
    func startRefreshControl(){
        
        if let refresh = refreshControl{
            
            refresh.beginRefreshing()
        }
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
    
    func loadRemindersListWithRefresh(refresh : Bool) {
        
        if refresh {
            
            startRefreshControl()
            loadRemindersList()
            endRefreshControl()
        }
        else {
            
            loadRemindersList()
        }
    }
    
    func loadRemindersList(){
        
        reminderManager.getReminders(getReminderList)
    }
    
    func getReminderList(iCloudShoppingList : [EKReminder]){

        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            if let reminderListTable = self.tableView{
                
                let scheduledItems : [EKReminder] = iCloudShoppingList.filter({(reminder : EKReminder) in reminder.alarms != nil})
                
                //Join the two lists from above
                self.reminderList = scheduledItems
                
                UIApplication.sharedApplication().applicationIconBadgeNumber = scheduledItems.count
                
                //Request a reload of the Table
                reminderListTable.reloadData()
            }
        }
    }
    
    //Once access is granted to the reminders list
    func requestedAccessToReminders(status : Bool){
        
        if !status {
            
            displayError("Please allow Remind Me to access 'Reminders'...")
        }
        
        loadRemindersList()
        
        endRefreshControl()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reminderList.count + 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //TODO: None of this is checked for nulls blah blah blah...
        
        let cell : RemindMeTableViewCell = tableView.dequeueReusableCellWithIdentifier("ReminderCell")! as! RemindMeTableViewCell
        
        var reminderListItem : EKReminder?
        
        if indexPath.row == 0 {
            
            reminderListItem = reminderManager.getNewReminder()
            
            //getNewReminder can return nil if the EventStore isn't ready. This happens when the table is first loaded...
            guard reminderListItem != nil else {
                
                return RemindMeTableViewCell()
            }
            
            reminderListItem!.title = Constants.ReminderItemTableViewCell.EmptyCell
        }
        else if indexPath.row == reminderList.count+1 {
            
            reminderListItem = reminderManager.getNewReminder()
            
            //getNewReminder can return nil if the EventStore isn't ready. This happens when the table is first loaded...
            guard reminderListItem != nil else {
                
                return RemindMeTableViewCell()
            }
            
            reminderListItem!.title = Constants.ReminderItemTableViewCell.NewItemCell
            cell.remindMeViewController = self
        }
        else {
            
            reminderListItem  = reminderList[indexPath.row-1]
        }
        
        cell.reminder = reminderListItem!
        
        return cell
    }
    
    //This method is for when an item is selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var reminderListItem : EKReminder?
        
        if indexPath.row-1 == reminderList.count {
            
            reminderListItem = reminderManager.getNewReminder()
            
            //getNewReminder can return nil if the EventStore isn't ready. This happens when the table is first loaded...
            guard reminderListItem != nil else {
                
                return //TODO: Error message...
            }
        }
        else {
            
            reminderListItem  = reminderList[indexPath.row-1]
        }
        
        performSegueWithIdentifier("tableViewCellSegue", sender: reminderListItem)
    }
    
    
    //This method is setting which cells can be edited
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        //Don't allow delete of the last blank row...
        if(indexPath.row < reminderList.count+1){
            return true
        }
        
        return false
    }
    
    //This method is for the swipe left to delete
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.row < reminderList.count+1){
            
            let listItem : EKReminder = reminderList[indexPath.row-1]
            
            guard reminderManager.removeReminder(listItem) else {
                
                displayError("Your reminder list item could not be removed...")
                
                return
            }
        }
    }
    
    //This method is to set the row height of the first spacer row...
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0{
            
            return CGFloat(16)
        }
        
        return tableView.rowHeight
    }
}

