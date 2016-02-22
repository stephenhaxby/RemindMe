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
    
    var reminderList = [EKReminder]()
    
    let reminderManager : iCloudReminderManager = iCloudReminderManager()
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet var remindersTableView: UITableView!
    
    @IBOutlet weak var doneButton: UIButton!
    
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
    
    @IBAction func doneButtonTouchUpInside(sender: UIButton) {
        
        self.editing = false
        
        sender.hidden = true
        
        //setAddNewButton(false)
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
    
    func cellLongPressed(gestureRecognizer:UIGestureRecognizer) {
        
//        if (gestureRecognizer.state == UIGestureRecognizerState.Ended) {
//
//            self.editing = true
//
//            var point = gestureRecognizer.locationInView(self.tableView)
//            
//            if let indexPath = self.tableView.indexPathForRowAtPoint(point) {
//
//                let data = reminderList[indexPath.row] as EKReminder
//            }
//        }
        if (gestureRecognizer.state == UIGestureRecognizerState.Began){

            self.editing = true
            
            doneButton.hidden = false
            
            //setAddNewButton(true)
            
            reminderList.removeAtIndex(reminderList.count-1)

            let indexPath : NSIndexPath = NSIndexPath(forRow: tableView.visibleCells.count-1, inSection: 0)
            var indexPaths : [NSIndexPath] = [NSIndexPath]()
            indexPaths.append(indexPath)
            
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    
//    func setAddNewButton(hidden : Bool) {
//        
//        if let tableViewCell = tableView.visibleCells[tableView.visibleCells.count-1] as? RemindMeTableViewCell {
//            
//            if let addNewButton = tableViewCell.addNewButton {
//                
//                addNewButton.hidden = hidden
//            }
//        }
//    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reminderList.count + 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //TODO: None of this is checked for nulls blah blah blah...
        
        let cell : RemindMeTableViewCell = tableView.dequeueReusableCellWithIdentifier("ReminderCell")! as! RemindMeTableViewCell
        
        if indexPath.row > 0 {
            
            //table.allowsSelectionDuringEditing
            
            let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellLongPressed:")
            longPress.delegate = self
            longPress.minimumPressDuration = 1
            longPress.numberOfTouchesRequired = 1
            
            cell.addGestureRecognizer(longPress)
        }
        
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return false
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        //TODO: You don't want to move the spacer cells...
        
        if let tableViewCell = tableView.visibleCells[indexPath.row] as? RemindMeTableViewCell {

            if tableViewCell.reminderTextLabel == Constants.ReminderItemTableViewCell.NewItemCell{
                
                return false
            }
        }
        
        return true
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        //return indexPath.row != 0 ? UITableViewCellEditingStyle.Delete : UITableViewCellEditingStyle.None

        return UITableViewCellEditingStyle.None
    }
    
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let itemToMove = reminderList[sourceIndexPath.row]
        
        reminderList.removeAtIndex(sourceIndexPath.row-1)
        
        reminderList.insert(itemToMove, atIndex: destinationIndexPath.row-1)
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

