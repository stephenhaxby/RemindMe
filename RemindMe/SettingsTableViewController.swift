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
    
    // Create an instance of our repository
    var settingRepository : SettingRepository = SettingRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "SettingsFooterView", bundle:nil)
        tableView.register(nibName, forHeaderFooterViewReuseIdentifier: "FooterCell")
        
        tableView.separatorColor = UIColor.orange;
        
        loadUserSettings()
        
        setDoneButtonTitleText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let backgroundImage = UIImage(named: "old-white-background")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill //.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.center = view.center
        self.tableView.backgroundView = imageView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mapSegue" {
            
            let mapViewController : MapViewController = segue.destination as! MapViewController
            
            if let settingsTableViewCell : SettingsTableViewCell = sender as? SettingsTableViewCell {
                
                mapViewController.settingsTableViewCell = settingsTableViewCell
            }
        }
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
            
            settingsList.sort(by: {(setting1, setting2) in
                
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
    
    @IBAction func doneButtonTouchUpInside(_ sender: UIButton) {
        
        self.isEditing = !self.isEditing
        
        setDoneButtonTitleText()
    }
    
    // When the user navigates away form this page, save all the settings (another way of doing an unwind segue)
    override func viewWillDisappear(_ animated : Bool){
        
        //Need to resign first responder on any text fields before doing anything, otherwise the setting will be updated
        //in it's setter after it's been deleted and committed
        for i in 0 ..< settingsTableView.visibleCells.count {
            
            if let cell : SettingsTableViewCell = settingsTableView.visibleCells[i] as? SettingsTableViewCell {
                
                if cell.nameTextField!.isFirstResponder {
                    
                    cell.nameTextField.resignFirstResponder()
                }
            }
        }
        
        for i in 0 ..< settingsList.count {
            
            settingsList[i].sequence = i
        }
        
        settingRepository.commit()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return settingsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell : SettingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell")! as! SettingsTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        // Setup a long press gesture recognizer to call the cellLongPressed method
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SettingsTableViewController.cellLongPressed(_:)))
        longPress.delegate = self
        longPress.minimumPressDuration = 1
        longPress.numberOfTouchesRequired = 1
        
        cell.addGestureRecognizer(longPress)
        
        cell.setting = settingsList[(indexPath as NSIndexPath).row]
        
        cell.settingsTableViewController = self
        
        return cell
    }
    
    //This method is setting which cells can be edited
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    //This method is for the swipe left to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        settingRepository.removeSetting(settingsList[(indexPath as NSIndexPath).row])
        
        settingsList.remove(at: (indexPath as NSIndexPath).row)
        
        settingsTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
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
        
        let itemToMove = settingsList[(sourceIndexPath as NSIndexPath).row]
        
        settingsList.remove(at: (sourceIndexPath as NSIndexPath).row)
        
        settingsList.insert(itemToMove, at: (destinationIndexPath as NSIndexPath).row)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerRow = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FooterCell") as! TableRowSettingsFooterAddNew
        
        // Set up properties on the Footer so we can call methods from the controller
        footerRow.settingsTableViewController = self
        
        // Set the background color of the footer cell
        footerRow.contentView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:0.8)
        
        return footerRow
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        // Set the height of the footer cell
        return CGFloat(64)
    }
    
    // Add a new setting row to the user defaults. Need to use the keyed archiver to save our custom Settings object to make it compatable with NSData
    func addNewSettingRow() {
        
        let setting : Setting = settingRepository.createNewSetting("", time: Date())
        
        settingsList.append(setting)

        let indexPath = IndexPath(row: settingsList.count-1, section: 0)
        
        settingsTableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        
        // Scroll to the last item in the list
        settingsTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
        
        delay(0.3){
            
            if let newRow : SettingsTableViewCell = self.settingsTableView.cellForRow(at: indexPath) as? SettingsTableViewCell {
                
                newRow.nameTextField.becomeFirstResponder()
                
            }
        }
    }
    
    // Resign first responder on the text field if the user starts to scroll
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        for cell in tableView.visibleCells {
            
            if let settingTableViewCell : SettingsTableViewCell = cell as? SettingsTableViewCell {
                
                settingTableViewCell.nameTextField.resignFirstResponder()
            }
        }
    }
    
    // Method for the long press gesture recognizer 
    func cellLongPressed(_ gestureRecognizer:UIGestureRecognizer) {

        if (gestureRecognizer.state == UIGestureRecognizerState.began){
            
            self.isEditing = true
            
            setDoneButtonTitleText()
        }
    }
    
    func setDoneButtonTitleText() {
        
        let titleText : String = self.isEditing ? "Done" : "Edit"
        
        doneButton.setTitle(titleText, for: UIControlState())
    }
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
}
