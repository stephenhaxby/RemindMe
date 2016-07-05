//
//  SettingsTableViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit
import CoreData

class SettingsTableViewController : UITableViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var settingsTableView: UITableView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    var settingsList : [Setting] = [Setting]()
    
    var newSettingIndexPath : NSIndexPath?
    
    // Create an instance of our repository
    var settingRepository : SettingRepository = SettingRepository(appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = UIColor.orangeColor();
        
        loadUserSettings()
        
        setDoneButtonTitleText()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let backgroundImage = UIImage(named: "old-white-background")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .ScaleAspectFill //.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.center = view.center
        self.tableView.backgroundView = imageView
    }
    
    // Load up the settings from Core Data
    func loadUserSettings() {
        
        settingsList = settingRepository.getSettings()
        
        // Create default values for morning and afternoon if none exist...
        if settingsList.count == 0 {
            
            settingsList.append(settingRepository.createNewSetting(Constants.DefaultMorningTimeText, time: Constants.DefaultMorningTime))
            
            settingsList.append(settingRepository.createNewSetting(Constants.DefaultAfternoonTimeText, time: Constants.DefaultAfternoonTime))
        }
        
        if settingsList.count > 1 {
            
            settingsList.sortInPlace({(setting1, setting2) in
                
                setting1.sequence < setting2.sequence
            })
        }
        
        reloadSettingsListTable()
    }
    
    func reloadSettingsListTable() {
        
        if let settingsListTable = self.tableView {
            
            settingsListTable.reloadData()
        }
    }
    
    @IBAction func doneButtonTouchUpInside(sender: UIButton) {
        
        self.editing = !self.editing
        
        setDoneButtonTitleText()
    }
    
    // When the user navigates away form this page, save all the settings (another way of doing an unwind segue)
    override func viewWillDisappear(animated : Bool){
        
        //Need to resign first responder on any text fields before doing anything, otherwise the setting will be updated
        //in it's setter after it's been deleted and committed
        for i in 0 ..< settingsTableView.visibleCells.count {
            
            if let cell : SettingsTableViewCell = settingsTableView.visibleCells[i] as? SettingsTableViewCell {
                
                if cell.nameTextField!.isFirstResponder() {
                    
                    cell.nameTextField.resignFirstResponder()
                }
            }
        }
        
        if settingsList[settingsList.count-1].name == "" {
            
            settingRepository.removeSetting(settingsList[settingsList.count-1])
            
            settingsList.removeAtIndex(settingsList.count-1)
        }
        
        for i in 0 ..< settingsList.count {
            
            settingsList[i].sequence = i
        }
        
        settingRepository.commit()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return settingsList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     
        let cell : SettingsTableViewCell = tableView.dequeueReusableCellWithIdentifier("SettingsCell")! as! SettingsTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        // Setup a long press gesture recognizer to call the cellLongPressed method
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SettingsTableViewController.cellLongPressed(_:)))
        longPress.delegate = self
        longPress.minimumPressDuration = 1
        longPress.numberOfTouchesRequired = 1
        
        cell.addGestureRecognizer(longPress)
        
        cell.setting = settingsList[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let newIndexPath : NSIndexPath = newSettingIndexPath where newIndexPath.section == indexPath.section && newIndexPath.row == indexPath.row
        {
            if let settingTableViewCell : SettingsTableViewCell = cell as? SettingsTableViewCell {
    
                settingTableViewCell.nameTextField.becomeFirstResponder()
                
                newSettingIndexPath = nil
            }
        }
        
        cell.backgroundColor = .clearColor() //UIColor(red:0.95, green:0.95, blue:0.95, alpha:0.6)
    }
    
    //This method is setting which cells can be edited
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    //This method is for the swipe left to delete
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        settingRepository.removeSetting(settingsList[indexPath.row])
        
        settingsList.removeAtIndex(indexPath.row)
        
        reloadSettingsListTable()
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
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let  footerRow = tableView.dequeueReusableCellWithIdentifier("FooterCell") as! TableRowSettingsFooterAddNew
        
        // Set up properties on the Footer so we can call methods from the controller
        footerRow.settingsTableViewController = self
        
        // Set the background color of the footer cell
        footerRow.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:0.8)
        
        return footerRow
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        // Set the height of the footer cell
        return CGFloat(64)
    }
    
    // Add a new setting row to the user defaults. Need to use the keyed archiver to save our custom Settings object to make it compatable with NSData
    func addNewSettingRow() {
        
        let setting : Setting = settingRepository.createNewSetting("", time: NSDate())
        
        settingsList.append(setting)
        
        reloadSettingsListTable()
        
        // Scroll to the last item in the list
        let indexPath = NSIndexPath(forRow: settingsList.count-1, inSection: 0)
        settingsTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        
        newSettingIndexPath = indexPath
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
            
            setDoneButtonTitleText()
        }
    }
    
    func setDoneButtonTitleText() {
        
        let titleText : String = self.editing ? "Done" : "Edit"
        
        doneButton.setTitle(titleText, forState: UIControlState.Normal)
    }
}
