//
//  ViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 26/11/2015.
//  Copyright © 2015 Stephen Haxby. All rights reserved.
//

import UIKit
import EventKit
import UserNotifications

class RemindMeViewController: UITableViewController, UIGestureRecognizerDelegate {

    var refreshListObserver : NSObjectProtocol?
    var refreshListScrollToBottomObserver : NSObjectProtocol?
    var notificationEditObserver : NSObjectProtocol?
    
    var reminderList = [RemindMeItem]()
    
    let storageFacade : StorageFacadeProtocol = (UIApplication.shared.delegate as! AppDelegate).AppStorageFacade
    
    let reminderItemSequenceRepository = ReminderItemSequenceRepository()
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet var remindersTableView: UITableView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Sets the method to run when the Event Store is updated in the background
        refreshListObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constants.RefreshNotification), object: nil, queue: nil){
            (notification) -> Void in
            
            self.loadRemindersListAnd(scrollToBottom: false)
        }
        
        refreshListScrollToBottomObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constants.RefreshNotificationScrollToBottom), object: nil, queue: nil){
            (notification) -> Void in
            
            self.loadRemindersListAnd(scrollToBottom: true)
        }
        
        notificationEditObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constants.NotificationActionEdit), object: nil, queue: nil){
            (notification) -> Void in

            let remindMeItemIndex : Int? = self.reminderList.index(where: {(remindMeItem : RemindMeItem) in remindMeItem.id == notification.object as? String})
            
            if remindMeItemIndex != nil {
                
                self.performSegue(withIdentifier: "tableViewCellSegue", sender: self.reminderList[remindMeItemIndex!])
            }
        }
    }
    
    deinit {
        
        // Dealocate the observer above
        if let observer = refreshListObserver{
            
            NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: Constants.RefreshNotification), object: nil)
        }
        
        if let observer = refreshListScrollToBottomObserver{
            
            NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: Constants.RefreshNotificationScrollToBottom), object: nil)
        }
        
        if let observer = notificationEditObserver{
            
            NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: Constants.NotificationActionEdit), object: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
        
        // Set the text and font of the Settings button (unicode)
        settingsButton.setTitle("\u{1F550}", for: UIControlState())
        settingsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
        
        setDoneButtonTitleText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        //tableView.backgroundColor = .lightGrayColor()
        
        //Add a blur effect
        //let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        //let blurView = UIVisualEffectView(effect: blurEffect)
        //blurView.frame = imageView.bounds
        //imageView.addSubview(blurView)
        
        let backgroundImage = UIImage(named: "old-white-background")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill //.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.center = view.center
        self.tableView.backgroundView = imageView
        
        //The background view sit's above the refresh control so we need to put it back a notch...
        self.tableView.backgroundView!.layer.zPosition -= 1;
    }
    
    // Disable table editing once the Done button is pressed
    @IBAction func doneButtonTouchUpInside(_ sender: UIButton) {
        
        let isEditing : Bool = self.isEditing
        
        self.isEditing = !self.isEditing
        
        setDoneButtonTitleText()
        
        if isEditing {
            
            refreshSequence()
            
            loadRemindersList()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // If it's from the settings button, don't do anything
        guard segue.identifier != "settingsSegue" else {
            
            return
        }
        
        // Setup the destination view controllers data
        let remindMeEditViewController : RemindMeEditViewController = segue.destination as! RemindMeEditViewController
        remindMeEditViewController.remindMeViewController = self
        
        // If we are editing an existing item
        if let reminderListItem : RemindMeItem = sender as? RemindMeItem {
            
            if segue.identifier == "tableViewCellSegue" {

                remindMeEditViewController.reminder = reminderListItem
            }
        }
    }
    
    func refreshSequence() {
        
        var reminderItemSequence : [ReminderItemSequence] = [ReminderItemSequence]()
        
        // Loop through each reminder and save it's order to a new list
        for i in 0 ..< reminderList.count {
            
            reminderItemSequence.append(ReminderItemSequence(calendarItemExternalIdentifier: reminderList[i].id, sequenceNumber: i))
        }
        
        // Serialize the reminder item sequence list to the file system
        guard reminderItemSequenceRepository.Archive(reminderItemSequenceList: reminderItemSequence) else {
            
            displayError("Unable to save Reminder Order!")
            return
        }
    }
    
    // Refresh the list in the main UI thread
    func refreshInMainThread() {
        
        //As we a in another thread, post back to the main thread so we can update the UI
        DispatchQueue.main.async { () -> Void in
            
            self.loadRemindersListAnd(scrollToBottom: false)
        }
    }
    
    func displayError(_ message : String){
        
        //Display an alert to specify that we couldn't get access
        let errorAlert = UIAlertController(title: "Error!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        //Add an Ok button to the alert
        errorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:
            { (action: UIAlertAction!) in
                
        }))
        
        //Present the alert
        self.present(errorAlert, animated: true, completion: nil)
    }
    
    func loadRemindersList(){
        
        storageFacade.getReminders(getReminderList)
    }
    
    func loadRemindersListAnd(scrollToBottom : Bool){
        
        loadRemindersList()
        
        if scrollToBottom {
            
            DispatchQueue.main.async { () -> Void in
                
                let indexPath = IndexPath(row: self.reminderList.count-1, section: 0)
                self.remindersTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
            }
        }
    }
    
    func getReminderList(_ shoppingList : [RemindMeItem]){

        DispatchQueue.main.async { () -> Void in
            
            if let reminderListTable = self.tableView{
                
                let reminderItemSequence  : [ReminderItemSequence] = self.reminderItemSequenceRepository.UnArchive()
                
                // Load up the reminder item sequence from disk
                if reminderItemSequence.count > 0 {
                    
                    var sortedScheduledItems : [RemindMeItem] = [RemindMeItem]()
                    
                    // For each item sequence that was saved
                    for itemSequence in reminderItemSequence {
                        
                        // Get the first matching item by calendarItemExternalIdentifier and add to our new list
                        if let matchingReminderItem : RemindMeItem = shoppingList.filter({(reminderItem : RemindMeItem) in
                            reminderItem.id == itemSequence.calendarItemExternalIdentifier}).first {
                            
                            sortedScheduledItems.append(matchingReminderItem)
                        }
                    }
                    
                    // Add the new sorted items to our list
                    self.reminderList = sortedScheduledItems
                    
                    // Get all items that were not in our sorted item list and append them to the sorted list
                    let unSortedScheduleItems : [RemindMeItem] = shoppingList.filter({(reminderItem : RemindMeItem) in
                        sortedScheduledItems.index(where: {$0.id == reminderItem.id}) == nil})
                    
                    if unSortedScheduleItems.count > 0 {
                    
                        self.reminderList.append(contentsOf: unSortedScheduleItems)
                        
                        self.refreshSequence()
                    }                    
                }
                else{
                    
                    // If no sequence could be loaded from disk
                    self.reminderList = shoppingList
                    
                    self.refreshSequence()
                }
                
                // Update the app's badge icon
                UIApplication.shared.applicationIconBadgeNumber = shoppingList.count
                
                // Request a reload of the Table
                reminderListTable.reloadData()
            }
        }
    }
    
    // This method gets called for our Gesture Recognizer
    func cellLongPressed(_ gestureRecognizer:UIGestureRecognizer) {
        
        // If it's the begining of the gesture, set the table to editing mode
        if (gestureRecognizer.state == UIGestureRecognizerState.began){

            self.isEditing = true
            
            setDoneButtonTitleText()
        }
    }
    
    func setDoneButtonTitleText() {
        
        let titleText : String = self.isEditing ? "Done" : "Edit"
        
        doneButton.setTitle(titleText, for: UIControlState())
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reminderList.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get the table cell
        let cell : RemindMeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell")! as! RemindMeTableViewCell
        
        // Setup a Long Press Gesture for each cell, calling the cellLongPressed method
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RemindMeViewController.cellLongPressed(_:)))
        longPress.delegate = self
        longPress.minimumPressDuration = 1
        longPress.numberOfTouchesRequired = 1
        
        cell.addGestureRecognizer(longPress)

        // Sets the reminder list item for the cell
        let reminderListItem : RemindMeItem = reminderList[(indexPath as NSIndexPath).row]
        cell.reminder = reminderListItem
        cell.remindMeViewController = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        
        return false
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {

        return UITableViewCellEditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let itemToMove = reminderList[(sourceIndexPath as NSIndexPath).row]
        
        reminderList.remove(at: (sourceIndexPath as NSIndexPath).row)
        
        reminderList.insert(itemToMove, at: (destinationIndexPath as NSIndexPath).row)
    }
    
    // This method is for when an item is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var reminderListItem : RemindMeItem?

        reminderListItem  = reminderList[(indexPath as NSIndexPath).row]
        
        // Manually perform the tableViewCellSegue to go to the edit page
        performSegue(withIdentifier: "tableViewCellSegue", sender: reminderListItem)
    }
    
    // This method is setting which cells can be edited
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    //This method is for the swipe left to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if((indexPath as NSIndexPath).row < reminderList.count){
            
            let listItem : RemindMeItem = reminderList[(indexPath as NSIndexPath).row]

            if storageFacade.removeReminder(listItem) {
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.RefreshNotification), object: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:0.6)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let  footerRow = tableView.dequeueReusableCell(withIdentifier: "FooterCell") as! TableRowFooterAddNew
        
        // Set's up the footer cell so we can perform actions on it
        footerRow.remindMeViewController = self
        
        // Set the background color of the footer cell
        footerRow.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:0.8)
        
        return footerRow
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        // Set's the height for the footer cell
        return CGFloat(64)
    }
}

