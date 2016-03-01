//
//  SettingsTableViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit

class SettingsTableViewController : UITableViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var settingsTableView: UITableView!
    
    @IBOutlet weak var doneButton: UIButton!
    
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
        
        // Load up the saved user default settings for reminder alarm times (with names)
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
    
    @IBAction func doneButtonTouchUpInside(sender: UIButton) {
        
        self.editing = false
        
        sender.hidden = true
    }
    
    // When the user navigates away form this page, save all the settings (another way of doing an unwind segue)
    override func viewWillDisappear(animated : Bool){
        
        var settingsArray : [NSData] = []
        
        for setting in settingsList {
            
            let settingData = NSKeyedArchiver.archivedDataWithRootObject(setting)
            
            settingsArray.append(settingData)
        }

        defaults.setObject(settingsArray, forKey: Constants.Setting)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return settingsList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     
        let cell : SettingsTableViewCell = tableView.dequeueReusableCellWithIdentifier("SettingsCell")! as! SettingsTableViewCell
        
        // Setup a long press gesture recognizer to call the cellLongPressed method
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellLongPressed:")
        longPress.delegate = self
        longPress.minimumPressDuration = 1
        longPress.numberOfTouchesRequired = 1
        
        cell.addGestureRecognizer(longPress)
        
        cell.setting = settingsList[indexPath.row]
        
        return cell
    }
    
    //This method is setting which cells can be edited
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    //This method is for the swipe left to delete
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let userDefaultSettingsObject: AnyObject = defaults.objectForKey(Constants.Setting) {
            
            if var userDefaultSettings : [NSData] = userDefaultSettingsObject as? [NSData] {
                
                userDefaultSettings.removeAtIndex(indexPath.row)
                
                defaults.setObject(userDefaultSettings, forKey: Constants.Setting)
            }
        }
        
        loadUserDefaultSettings()
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
        
        let itemToMove = settingsList[sourceIndexPath.row]
        
        settingsList.removeAtIndex(sourceIndexPath.row)
        
        settingsList.insert(itemToMove, atIndex: destinationIndexPath.row)
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerRow = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! TableRowHeaderSpacer
        
        //        headerRow.layer.borderWidth = 0.5
        //        headerRow.layer.borderColor = UIColor.orangeColor().CGColor
        
        //        cell.layer.borderWidth = 2.0
        //        cell.layer.borderColor = UIColor.grayColor().CGColor
        
        // Set the background color of the Header cell
        headerRow.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        
        return headerRow
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        // Set the height for the Header cell
        return CGFloat(12)
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let  footerRow = tableView.dequeueReusableCellWithIdentifier("FooterCell") as! TableRowSettingsFooterAddNew
        
        // Set up properties on the Footer so we can call methods from the controller
        footerRow.settingsTableViewController = self
        
        // Set the background color of the footer cell
        footerRow.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        
        return footerRow
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        // Set the height of the footer cell
        return CGFloat(64)
    }
    
    // Add a new setting row to the user defaults. Need to use the keyed archiver to save our custom Settings object to make it compatable with NSData
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
        
        // Scroll to the last item in the list
        let indexPath = NSIndexPath(forRow: settingsList.count-1, inSection: 0)
        settingsTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    // Create a new setting using some default values
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
    
    // Resign first responder on the text field if the user starts to scroll
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        for cell in tableView.visibleCells {
            
            if let settingTableViewCell : SettingsTableViewCell = cell as? SettingsTableViewCell {
                
                settingTableViewCell.nameTextField.resignFirstResponder()
            }
        }
    }
    
    // Method for the long press gesture recognizer 
    func cellLongPressed(gestureRecognizer:UIGestureRecognizer) {

        if (gestureRecognizer.state == UIGestureRecognizerState.Began){
            
            self.editing = true
            
            doneButton.hidden = false
        }
    }
}
