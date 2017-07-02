//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Stephen Haxby on 28/9/16.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit
import NotificationCenter
import UserNotifications

class TodayViewController: UITableViewController, NCWidgetProviding {
    
    //Gets the managed object context for core data (as a singleton)
    let coreDataContext = CoreDataManager.context()
    
    let localNotificationManager : LocalNotificationManager = LocalNotificationManager()
    
    var deliveredReminderList = [RemindMeItem]()
    
    var storageFacade : StorageFacadeProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        
        let pressGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewPressed(_:)))
        pressGesture.numberOfTapsRequired = 1
        
        if tableView != nil {
            
            tableView.addGestureRecognizer(pressGesture)
        }
    }
    
    //TODO: Or should it be viewWillAppear?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if deliveredReminderList.count == 0 {
            
            displayNoOverdueRemindersOverlay()
        }
        
//        getStorageFacade().getReminders {
//            reminders in
//            
//            self.localNotificationManager.getPendingReminderNotificationRequests{
//                notificationRequests in
//                
//                let newDeliveredReminderList : [RemindMeItem] =
//                    self.populateDeliveredReminderList(reminders: reminders, notificationRequests: notificationRequests)
//                
//                if self.hasDeliveredReminderListDataChanged(newDeliveredReminderList: newDeliveredReminderList) {
//                
//                    //self.displayLoadingOverlay()
//                    
//                    self.deliveredReminderList = newDeliveredReminderList
//                    
//                    //TODO: Not sure if we'll need to do this here or not... Depends if the table has loaded yet or not...
//                    self.reloadTable()
//                }
//            }
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: @escaping ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        //Load data here and call completionhandler ONLY AFTER DATA HAS LOADED (as it's done in another thread!)
        getStorageFacade().getReminders {
            reminders in
            
            self.localNotificationManager.getPendingReminderNotificationRequests{
                notificationRequests in
                
                let newDeliveredReminderList : [RemindMeItem] =
                    self.populateDeliveredReminderList(reminders: reminders, notificationRequests: notificationRequests)
                
                if self.hasDeliveredReminderListDataChanged(newDeliveredReminderList: newDeliveredReminderList) {
                
                    //self.displayLoadingOverlay()
                    
                    self.deliveredReminderList = newDeliveredReminderList
                    
                    self.reloadTable()
                    completionHandler(NCUpdateResult.newData)
                }
                else {
                    
                    completionHandler(NCUpdateResult.noData)
                }
            }
        }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(64))
        }
        else {
            
            self.preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(deliveredReminderList.count * 64))
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return deliveredReminderList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get the table cell
        let cell : RemindMeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell")! as! RemindMeTableViewCell
        
        // Sets the reminder list item for the cell
        let reminderListItem : RemindMeItem = deliveredReminderList[(indexPath as NSIndexPath).row]
        cell.reminder = reminderListItem
        
        if indexPath.row == deliveredReminderList.count - 1 {
            
            clearTableOverlay()
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        displayLoadingOverlay()
        
        return 1
    }
    
    func viewPressed(_ gestureRecognizer: UIGestureRecognizer) {
        
        let url: URL? = URL(string: "RemindMe:")!
        
        if let appurl = url {
            
            self.extensionContext!.open(appurl, completionHandler: nil)
        }
    }
    
    func populateDeliveredReminderList(reminders : [RemindMeItem], notificationRequests : [UNNotificationRequest]) -> [RemindMeItem] {
        
        var newDeliveredReminderList = [RemindMeItem]()
        
        for remindMeItem in reminders {
            
            if (!notificationRequests.contains { notificationRequest in
                
                return notificationRequest.identifier.hasPrefix(remindMeItem.id)
                }){
                newDeliveredReminderList.append(remindMeItem)
            }
        }
        
        newDeliveredReminderList.sort {
            (reminder1, reminder2) in
            if reminder1.type == Constants.ReminderType.dateTime && reminder2.type == Constants.ReminderType.dateTime {
                return reminder1.date! < reminder2.date!
            }
            else {
                return true
            }
        }
        
        return newDeliveredReminderList
    }
    
    func hasDeliveredReminderListDataChanged(newDeliveredReminderList : [RemindMeItem]) -> Bool {
        
        if deliveredReminderList.count != newDeliveredReminderList.count {
            
            return true
        }
        
        var hasDataChanged : Bool = false
        
        for deliveredReminderItem in deliveredReminderList {
            
            if (!newDeliveredReminderList.contains {
                newDeliveredReminderItem in
                
                    return String(describing: deliveredReminderItem) == String(describing: newDeliveredReminderItem)}){

                hasDataChanged = true
                break
            }
        }
        
        return hasDataChanged
    }
    
    func getStorageFacade() -> StorageFacadeProtocol {
        
        if storageFacade == nil {
            
            storageFacade = ReminderFacade(reminderRepository: ReminderRepository(managedObjectContext: coreDataContext))
        }
        
        return storageFacade!
    }
    
    func displayLoadingOverlay() {
        
        tableView.separatorStyle = .none
        displayTableOverlay(message: "Loading data...")
    }
    
    func displayNoOverdueRemindersOverlay () {
        
        tableView.separatorStyle = .none
        displayTableOverlay(message: "No Overdue Reminders")
    }
    
    func displayTableOverlay(message : String) {
        
        let rect : CGRect = CGRect(x: 0, y: 0, width: Double(tableView.bounds.size.width), height: Double(tableView.bounds.size.height))
        
        let noDataLabel: UILabel = UILabel(frame: rect)
        
        noDataLabel.text = message
        noDataLabel.textColor = UIColor.black
        noDataLabel.textAlignment = .center
        tableView.backgroundView = noDataLabel
    }
    
    func clearTableOverlay() {
        
        tableView.backgroundView = nil
        tableView.separatorStyle = .singleLine
    }
    
    func reloadTable() {
        
        tableView.reloadData()
    }
}
