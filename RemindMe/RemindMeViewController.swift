//
//  ViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 26/11/2015.
//  Copyright © 2015 Stephen Haxby. All rights reserved.
//

import UIKit
import EventKit

class RemindMeViewController: UITableViewController, UIGestureRecognizerDelegate {

    var eventStoreObserver : NSObjectProtocol?
    
    var reminderList = [RemindMeItem]()
    
    var storageFacade : StorageFacadeProtocol?
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet var remindersTableView: UITableView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Sets the method to run when the Event Store is updated in the background
        eventStoreObserver = NSNotificationCenter.defaultCenter().addObserverForName(EKEventStoreChangedNotification, object: nil, queue: nil){
            (notification) -> Void in
            
            self.loadRemindersListWithRefresh(true)
        }
    }
    
    deinit {
        
        // Dealocate the observer above
        if let observer = eventStoreObserver{
            
            NSNotificationCenter.defaultCenter().removeObserver(observer, name: EKEventStoreChangedNotification, object: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the text and font of the Settings button (unicode)
        settingsButton.setTitle("\u{2699}", forState: UIControlState.Normal)
        settingsButton.titleLabel?.font = UIFont.boldSystemFontOfSize(26)
        
        loadRemindersListWithRefresh(true)
    }
    
    // When a refresh is actioned
    @IBAction func refreshControlValueChanged(sender: UIRefreshControl) {
        
        loadRemindersList()
        
        sender.endRefreshing()
    }
    
    // Disable table editing once the Done button is pressed
    @IBAction func doneButtonTouchUpInside(sender: UIButton) {
        
        self.editing = false
        
        // Hide the Done button
        sender.hidden = true

        var reminderItemSequence : [ReminderItemSequence] = [ReminderItemSequence]()
        
        // Loop through each reminder and save it's order to a new list
        for i in 0 ..< reminderList.count {
            
            reminderItemSequence.append(ReminderItemSequence(calendarItemExternalIdentifier: reminderList[i].id, sequenceNumber: i))
        }
        
        // Save our reminder sequence to disk
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(reminderItemSequence, toFile: ReminderItemSequence.ArchiveURL.path!)
        
        if !isSuccessfulSave {
            
            displayError("Unable to save Reminder Order!")
        }
        
        loadRemindersList()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // If it's from the settings button, don't do anything
        guard segue.identifier != "settingsSegue" else {
            
            return
        }
        
        // Setup the destination view controllers data
        let remindMeEditViewController : RemindMeEditViewController = segue.destinationViewController as! RemindMeEditViewController
        remindMeEditViewController.remindMeViewController = self
        remindMeEditViewController.storageFacade = storageFacade
        
        // If we are editing an existing item
        if let reminderListItem : RemindMeItem = sender as? RemindMeItem {
            
            if segue.identifier == "tableViewCellSegue" {

                remindMeEditViewController.reminder = reminderListItem
            }
        }
        else if sender is TableRowFooterAddNew || sender is UIButton {
            
            // If we are creating a new item
            remindMeEditViewController.reminder = RemindMeItem()
            
            remindMeEditViewController.isNewReminder = true
        }
    }
    
    // Refresh the list in the main UI thread
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
        
        storageFacade!.getReminders(getReminderList)
    }
    
    func getReminderList(iCloudShoppingList : [RemindMeItem]){

        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            if let reminderListTable = self.tableView{
                
                // Filter out reminder items that don't have an alarm set
                let scheduledItems : [RemindMeItem] = iCloudShoppingList.filter({(reminder : RemindMeItem) in reminder.date != nil})
                
                // Load up the reminder item sequence from disk
                if let reminderItemSequence : [ReminderItemSequence] = NSKeyedUnarchiver.unarchiveObjectWithFile(ReminderItemSequence.ArchiveURL.path!) as? [ReminderItemSequence] {
                    
                    var sortedScheduledItems : [RemindMeItem] = [RemindMeItem]()
                    
                    // For each item sequence that was saved
                    for itemSequence in reminderItemSequence {
                        
                        // Get the first matching item by calendarItemExternalIdentifier and add to our new list
                        if let matchingReminderItem : RemindMeItem = scheduledItems.filter({(reminderItem : RemindMeItem) in
                            reminderItem.id == itemSequence.calendarItemExternalIdentifier}).first {
                            
                            sortedScheduledItems.append(matchingReminderItem)
                        }
                    }
                    
                    // Add the new sorted items to our list
                    self.reminderList = sortedScheduledItems
                    
                    // Get all items that were not in our sorted item list and append them to the sorted list
                    let unSortedScheduleItems : [RemindMeItem] = scheduledItems.filter({(reminderItem : RemindMeItem) in
                        sortedScheduledItems.indexOf({$0.id == reminderItem.id}) == nil})
                    
                    self.reminderList.appendContentsOf(unSortedScheduleItems)
                }
                else{
                    
                    // If no sequence could be loaded from disk
                    self.reminderList = scheduledItems
                }
                
                // Update the app's badge icon
                UIApplication.sharedApplication().applicationIconBadgeNumber = scheduledItems.count
                
                // Request a reload of the Table
                reminderListTable.reloadData()
            }
        }
    }
    
    // Once access is granted to the reminders list
    func requestedAccessToReminders(status : Bool){
        
        if !status {
            
            displayError("Please allow Remind Me to access 'Reminders'...")
        }
        
        loadRemindersList()
        
        endRefreshControl()
    }
    
    // This method gets called for our Gesture Recognizer
    func cellLongPressed(gestureRecognizer:UIGestureRecognizer) {
        
        // If it's the begining of the gesture, set the table to editing mode
        if (gestureRecognizer.state == UIGestureRecognizerState.Began){

            self.editing = true
            
            doneButton.hidden = false
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reminderList.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get the table cell
        let cell : RemindMeTableViewCell = tableView.dequeueReusableCellWithIdentifier("ReminderCell")! as! RemindMeTableViewCell
        
        // Setup a Long Press Gesture for each cell, calling the cellLongPressed method
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellLongPressed:")
        longPress.delegate = self
        longPress.minimumPressDuration = 1
        longPress.numberOfTouchesRequired = 1
        
        cell.addGestureRecognizer(longPress)

        // Sets the reminder list item for the cell
        var reminderListItem : RemindMeItem = reminderList[indexPath.row]
        cell.reminder = reminderListItem
        
        return cell
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return false
    }

    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {

        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let itemToMove = reminderList[sourceIndexPath.row]
        
        reminderList.removeAtIndex(sourceIndexPath.row)
        
        reminderList.insert(itemToMove, atIndex: destinationIndexPath.row)
    }
    
    // This method is for when an item is selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var reminderListItem : RemindMeItem?

        reminderListItem  = reminderList[indexPath.row]
        
        // Manually perform the tableViewCellSegue to go to the edit page
        performSegueWithIdentifier("tableViewCellSegue", sender: reminderListItem)
    }
    
    // This method is setting which cells can be edited
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    //This method is for the swipe left to delete
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.row < reminderList.count){
            
            let listItem : RemindMeItem = reminderList[indexPath.row]

            storageFacade!.removeReminder(listItem)
            
//            guard storageFacade.removeReminder(listItem) else {
//                
//                displayError("Your reminder list item could not be removed...")
//                
//                return
//            }
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerRow = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! TableRowHeaderSpacer
        
        // Set the background color of the header cell
        headerRow.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        
        return headerRow
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        // Set's the height of the Header
        return CGFloat(12)
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let  footerRow = tableView.dequeueReusableCellWithIdentifier("FooterCell") as! TableRowFooterAddNew
        
        // Set's up the footer cell so we can perform actions on it
        footerRow.remindMeViewController = self
        
        // Set the background color of the footer cell
        footerRow.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        
        return footerRow
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        // Set's the height for the footer cell
        return CGFloat(64)
    }
}

