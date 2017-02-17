//
//  ReminderTimeTableViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 11/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit
import EventKit

class ReminderTimeTableViewController: UITableViewController {
    
    let settingFacade : SettingFacadeProtocol = (UIApplication.shared.delegate as! AppDelegate).AppSettingFacade
    
    var reminderTimeTableViewCellItems : [ReminderTimeTableViewCellItem] = [ReminderTimeTableViewCellItem]()

    var selectedSetting : SettingItem?
    
    weak var remindMeEditViewController : RemindMeEditViewController?
    
    weak var reminder : RemindMeItem?
    
    deinit{
        remindMeEditViewController = nil
        reminder = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear the table separator color
        tableView.separatorColor = UIColor.clear;
        
        // Setup the table cells to display the user default alarm options (left and right)
        reminderTimeTableViewCellItems.removeAll()
        
        // Get the settings from CoreData
        var settingsList : [SettingItem] = settingFacade.getSettings()
        
        // Create default values for morning and afternoon if none exist...
        if settingsList.count == 0 {
            
            settingsList.append(settingFacade.createNewDefaultMorningSetting())
            settingsList.append(settingFacade.createNewDefaultAfternoonSetting())
            
            if !settingFacade.commit() {
                
                Utilities().diaplayError(message: "Unable to save settings!", inViewController: self)
            }
        }
        
        // Sort the settings before displaying them
        if settingsList.count > 1 {
            
            settingsList.sort(by: {(setting1, setting2) in
                
                setting1.sequence < setting2.sequence
            })
        }
        
        var index : Int = 0
        
        // Lay out the table cells from left to right
        while index < settingsList.count {
            
            let reminderTimeTableViewCellItem : ReminderTimeTableViewCellItem = ReminderTimeTableViewCellItem()
            reminderTimeTableViewCellItem.settingOne = settingsList[index]
            
            if index+1 < settingsList.count {
                
                reminderTimeTableViewCellItem.settingTwo = settingsList[index+1]
            }
            
            reminderTimeTableViewCellItems.append(reminderTimeTableViewCellItem)
            
            index += 2
        }
        
        if let reminderTimeListTable = self.tableView {
            
            reminderTimeListTable.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.backgroundColor = UIColor.clear
    }
    
    // Function to clear all the setting buttons
    func deselectSettingTimeButtons() {
        
        reminderTitleTextViewResignFirstResponder()
        
        for i in 0 ..< tableView.visibleCells.count {
            
            if let reminderTimeTableViewCell : ReminderTimeTableViewCell = tableView.visibleCells[i] as? ReminderTimeTableViewCell {
                
                if let leftButton = reminderTimeTableViewCell.leftButton {
                    
                    leftButton.isSelected = false
                }
                
                if let rightButton = reminderTimeTableViewCell.rightButton {
                    
                    rightButton.isSelected = false
                }
            }
         }
    }
    
    func reminderTitleTextViewResignFirstResponder() {
        
        if remindMeEditViewController != nil && remindMeEditViewController!.reminderTitleTextView != nil {
            
            remindMeEditViewController!.reminderTitleTextView!.resignFirstResponder()
        }
    }
    
    func selectSettingButtonFor(_ reminderTimeTableViewCell : ReminderTimeTableViewCell) {
        
        // Loop through each alarm time and set the button to selected when it finds a match (left or right button)
        if let reminderItem : RemindMeItem = reminder {
            
            if let leftButton = reminderTimeTableViewCell.leftButton {
                
                if reminderTimeTableViewCell.settings != nil && reminderTimeTableViewCell.settings!.settingOne != nil {
                    
                    switch reminderItem.type {
                        case Constants.ReminderType.dateTime:
                            
                            let itemReminderAlarmDateComponents : DateComponents = NSDateManager.getDateComponentsFromDate(reminderItem.date!)
                            
                            if reminderTimeTableViewCell.settings!.settingOne!.type == Constants.ReminderType.dateTime {
                            
                                leftButton.isSelected =
                                    NSDateManager.timeIsEqualToTime(reminderTimeTableViewCell.settings!.settingOne!.time!, date2Components : itemReminderAlarmDateComponents)
                            }
                            
                        case Constants.ReminderType.location:
                            
                            if reminderTimeTableViewCell.settings!.settingOne!.type == Constants.ReminderType.location {
                                
                                leftButton.isSelected =
                                    reminderTimeTableViewCell.settings!.settingOne!.latitude == reminderItem.latitude!
                                    && reminderTimeTableViewCell.settings!.settingOne!.longitude == reminderItem.longitude!
                            }

                        default:
                            Utilities().diaplayError(message: "No reminder type could be found for \(reminderItem.title)", inViewController: self)
                    }
                    
                    if leftButton.isSelected {
                    
                        leftButton.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                        selectedSetting = reminderTimeTableViewCell.settings!.settingOne
                    }
                }
            }
            
            if let rightButton = reminderTimeTableViewCell.rightButton {
                
                if reminderTimeTableViewCell.settings != nil && reminderTimeTableViewCell.settings!.settingTwo != nil {
                
                    switch reminderItem.type {
                        case Constants.ReminderType.dateTime:
                        
                            let itemReminderAlarmDateComponents : DateComponents = NSDateManager.getDateComponentsFromDate(reminderItem.date!)
                            
                            if reminderTimeTableViewCell.settings!.settingTwo!.type == Constants.ReminderType.dateTime {
                            
                                rightButton.isSelected =
                                    NSDateManager.timeIsEqualToTime(reminderTimeTableViewCell.settings!.settingTwo!.time!, date2Components : itemReminderAlarmDateComponents)
                            }
                        
                        case Constants.ReminderType.location:
                        
                            if reminderTimeTableViewCell.settings!.settingTwo!.type == Constants.ReminderType.location {
                            
                                rightButton.isSelected =
                                    reminderTimeTableViewCell.settings!.settingTwo!.latitude == reminderItem.latitude!
                                    && reminderTimeTableViewCell.settings!.settingTwo!.longitude == reminderItem.longitude!
                            }
                        
                        default:
                            Utilities().diaplayError(message: "No reminder type could be found for \(reminderItem.title)", inViewController: self)
                    }
                    
                    if rightButton.isSelected {
                    
                        rightButton.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                        selectedSetting = reminderTimeTableViewCell.settings!.settingTwo
                    }
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reminderTimeTableViewCellItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ReminderTimeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ReminderTimeCell")! as! ReminderTimeTableViewCell
        
        cell.settings = reminderTimeTableViewCellItems[(indexPath as NSIndexPath).row]
        cell.reminderTimeTableViewController = self
        
        selectSettingButtonFor(cell)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //cell.backgroundColor = .clearColor()
        //cell.backgroundColor = UIColor(white: 1, alpha: 0.5)
        cell.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerRow = tableView.dequeueReusableCell(withIdentifier: "FooterCell") as! TableRowSpacer
        
        // Set the background color of the footer cell
        footerRow.backgroundColor = UIColor.clear
        
        return footerRow
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        // Set's the height for the footer cell
        return CGFloat(64)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        reminderTitleTextViewResignFirstResponder()
    }

}
