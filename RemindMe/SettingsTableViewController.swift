//
//  SettingsTableViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit

class SettingsTableViewController : UITableViewController {

    @IBOutlet weak var settingsTableView: UITableView!
    
    var settingsList : [Setting] = [Setting]()
    
    var defaults : NSUserDefaults {
        
        get {
            
            return NSUserDefaults.standardUserDefaults()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = UIColor.orangeColor();
        
        loadUserDefaultSettings()
    }
    
    func loadUserDefaultSettings() {
        
        if defaults.objectForKey(Constants.Setting) == nil{
            
            createDefaultSettings()
        }
        
        if let userDefaultSettingsObject: AnyObject = defaults.objectForKey(Constants.Setting) {
            
            if let userDefaultSettings : [NSData] = userDefaultSettingsObject as? [NSData] {
                
                settingsList.removeAll()
                
                for defaultSetting in userDefaultSettings {
                    
                    if let unarchivedSetting = NSKeyedUnarchiver.unarchiveObjectWithData(defaultSetting) as? Setting {
                        
                        settingsList.append(unarchivedSetting)
                    }
                }
            }
        }
        
        if let settingsListTable = self.tableView {
        
            settingsListTable.reloadData()
        }
    }
    
    override func viewWillDisappear(animated : Bool){
        
        var settingsArray : [NSData] = []
        
        for setting in settingsList {
            
            let settingData = NSKeyedArchiver.archivedDataWithRootObject(setting)
            
            settingsArray.append(settingData)
        }

        defaults.setObject(settingsArray, forKey: Constants.Setting)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return settingsList.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     
        let cell : SettingsTableViewCell = tableView.dequeueReusableCellWithIdentifier("SettingsCell")! as! SettingsTableViewCell
        
        if indexPath.row < settingsList.count {
            
//            cell.layer.borderWidth = 0.5
//            cell.layer.borderColor = UIColor.grayColor().CGColor
            
            cell.setting = settingsList[indexPath.row]
        }
        else{
            
            cell.setting = Setting(name: Constants.ReminderItemTableViewCell.NewItemCell, time: NSDate())
            cell.settingsTableViewController = self
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == settingsList.count {
            
            return CGFloat(40)
        }
        
        return tableView.rowHeight
    }
    
    //This method is setting which cells can be edited
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        //Don't allow delete of the last blank row...
        if(indexPath.row < settingsList.count){
            return true
        }
        
        return false
    }
    
    //This method is for the swipe left to delete
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.row < settingsList.count){
        
            //TODO: Find the setting in the user defaults
            //TODO: Update SettingUserDefaultCount
            
            //getSettingForKeyIndex
            
            if let userDefaultSettingsObject: AnyObject = defaults.objectForKey(Constants.Setting) {
                
                if var userDefaultSettings : [NSData] = userDefaultSettingsObject as? [NSData] {
                    
                    userDefaultSettings.removeAtIndex(indexPath.row)
                    
                    defaults.setObject(userDefaultSettings, forKey: Constants.Setting)
                }
            }
            
            loadUserDefaultSettings()
        }
    }
    
    //This method is for when an item is selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row == settingsList.count {
        
            addNewSettingRow()
        }
    }
    
    func addNewSettingRow() {
        
        let newSetting : Setting = Setting(name: "", time : NSDate())
        
        let newSettingData = NSKeyedArchiver.archivedDataWithRootObject(newSetting)
        
        if let defaultSetting : AnyObject = defaults.objectForKey(Constants.Setting) {
            
            if var defaultSettingObject : [NSData] = defaultSetting as? [NSData] {
                
                defaultSettingObject.append(newSettingData)
                
                defaults.setObject(defaultSettingObject, forKey: Constants.Setting)
            }
        }
        
        loadUserDefaultSettings()
    }
    
    func createDefaultSettings() {
        
        var settingsArray : [NSData] = []
        
        let defaultMorningSetting : Setting = Setting(name: Constants.DefaultMorningTimeText, time : Constants.DefaultMorningTime)
        let defaultAfternoonSetting : Setting = Setting(name : Constants.DefaultAfternoonTimeText, time : Constants.DefaultAfternoonTime)
        
        let defaultMorningSettingData = NSKeyedArchiver.archivedDataWithRootObject(defaultMorningSetting)
        let defaultAfternoonSettingData = NSKeyedArchiver.archivedDataWithRootObject(defaultAfternoonSetting)
        
        settingsArray.append(defaultMorningSettingData)
        settingsArray.append(defaultAfternoonSettingData)
        
        defaults.setObject(settingsArray, forKey: Constants.Setting)
    }
}
