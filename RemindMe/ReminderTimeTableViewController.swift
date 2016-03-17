//
//  ReminderTimeTableViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 11/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit

class ReminderTimeTableViewController: UITableViewController {
    
    var settingRepository : SettingRepository = SettingRepository(appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
    
    var reminderTimeTableViewCellItems : [ReminderTimeTableViewCellItem] = [ReminderTimeTableViewCellItem]()
    
    weak var remindMeEditViewController : RemindMeEditViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear the table separator color
        tableView.separatorColor = UIColor.clearColor();
        
        // Setup the table cells to display the user default alarm options (left and right)
        reminderTimeTableViewCellItems.removeAll()
        
        // Get the settings from CoreData
        var settingsList : [Setting] = settingRepository.getSettings()
        
        // Create default values for morning and afternoon if none exist...
        if settingsList.count == 0 {
            
            settingsList.append(settingRepository.createNewSetting(Constants.DefaultMorningTimeText, time: Constants.DefaultMorningTime))
            
            settingsList.append(settingRepository.createNewSetting(Constants.DefaultAfternoonTimeText, time: Constants.DefaultAfternoonTime))
        }
        
        // Sort the settings before displaying them
        if settingsList.count > 1 {
            
            settingsList.sortInPlace({(setting1, setting2) in
                
                setting1.sequence < setting2.sequence
            })
        }
        
        // Lay out the table cells from left to right
        for var i = 0; i < settingsList.count; i++ {
            
            let reminderTimeTableViewCellItem : ReminderTimeTableViewCellItem = ReminderTimeTableViewCellItem()
            reminderTimeTableViewCellItem.settingOne = settingsList[i]
            
            if i+1 < settingsList.count {
                
                reminderTimeTableViewCellItem.settingTwo = settingsList[i+1]
                
                i++
            }
            
            reminderTimeTableViewCellItems.append(reminderTimeTableViewCellItem)
        }
        
        if let reminderTimeListTable = self.tableView {
            
            reminderTimeListTable.reloadData()
        }
    }
    
    // Function to clear all the setting buttons
    func deselectSettingTimeButtons() {
        
        reminderTitleTextViewResignFirstResponder()
        
        for var i = 0; i < tableView.visibleCells.count; i++ {
            
            if let reminderTimeTableViewCell : ReminderTimeTableViewCell = tableView.visibleCells[i] as? ReminderTimeTableViewCell {
                
                if let leftButton = reminderTimeTableViewCell.leftButton {
                    
                    leftButton.selected = false
                }
                
                if let rightButton = reminderTimeTableViewCell.rightButton {
                    
                    rightButton.selected = false
                }
            }
         }
    }
    
    func reminderTitleTextViewResignFirstResponder() {
        
        if remindMeEditViewController != nil && remindMeEditViewController!.reminderTitleTextView != nil {
            
            remindMeEditViewController!.reminderTitleTextView!.resignFirstResponder()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reminderTimeTableViewCellItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : ReminderTimeTableViewCell = tableView.dequeueReusableCellWithIdentifier("ReminderTimeCell")! as! ReminderTimeTableViewCell
        
        cell.settings = reminderTimeTableViewCellItems[indexPath.row]
        cell.reminderTimeTableViewController = self
        
        return cell
    }

    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return false
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        reminderTitleTextViewResignFirstResponder()
    }
}
