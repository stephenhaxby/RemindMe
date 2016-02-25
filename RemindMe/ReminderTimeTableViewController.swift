//
//  ReminderTimeTableViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 11/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit

class ReminderTimeTableViewController: UITableViewController {
    
    var reminderTimeTableViewCellItems : [ReminderTimeTableViewCellItem] = [ReminderTimeTableViewCellItem]()
    
    weak var remindMeEditViewController : RemindMeEditViewController?
    
    var defaults : NSUserDefaults {
        
        get {
            
            return NSUserDefaults.standardUserDefaults()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = UIColor.clearColor();
        
        if let userDefaultSettingsObject: AnyObject = defaults.objectForKey(Constants.Setting) {
            
            if let userDefaultSettings : [NSData] = userDefaultSettingsObject as? [NSData] {
                
                reminderTimeTableViewCellItems.removeAll()
                
                var settingsList : [Setting] = [Setting]()
                
                for defaultSetting in userDefaultSettings {
                    
                    if let unarchivedSetting = NSKeyedUnarchiver.unarchiveObjectWithData(defaultSetting) as? Setting {
                        
                        settingsList.append(unarchivedSetting)
                    }
                }
                
                for var i = 0; i < settingsList.count; i++ {
                    
                    let reminderTimeTableViewCellItem : ReminderTimeTableViewCellItem = ReminderTimeTableViewCellItem()
                    reminderTimeTableViewCellItem.settingOne = settingsList[i]
                    
                    if i+1 < settingsList.count {
                        
                        reminderTimeTableViewCellItem.settingTwo = settingsList[i+1]
                        
                        i++
                    }
                    
                    reminderTimeTableViewCellItems.append(reminderTimeTableViewCellItem)
                }
            }
        }
        
        if let reminderTimeListTable = self.tableView {
            
            reminderTimeListTable.reloadData()
        }
    }
    
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
