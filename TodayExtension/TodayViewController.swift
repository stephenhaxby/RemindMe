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
    
    var reminderList = [RemindMeItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        let storageFacade = ReminderFacade(reminderRepository: ReminderRepository(managedObjectContext: coreDataContext))

        storageFacade.getReminders(getReminders)

        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
    }
    
    func getReminders(reminders : [RemindMeItem]) {
        
        reminderList = reminders
        
        localNotificationManager.getPendingReminderNotificationRequests(getUNNotificationRequests: updateReminderListWithPendingNotifications)
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
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
     
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize
        }
        else {
            
            //TODO: Not sure what we can do here for the content size.?.?
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
        
        return cell
    }
    
    func updateReminderListWithPendingNotifications(notificationRequests : [UNNotificationRequest]) {
        
        for remindMeItem in reminderList {
            
            if (!notificationRequests.contains { notificationRequest in
                
                return notificationRequest.identifier.hasPrefix(remindMeItem.id)
            }){
                deliveredReminderList.append(remindMeItem)
            }
        }
        
        deliveredReminderList.sort {
            (reminder1, reminder2) in
            if reminder1.type == 0 && reminder2.type == 0 {
                return reminder1.date! < reminder2.date!
            }
            else {
                return true
            }
        }
        
        tableView.reloadData()
    }
}







