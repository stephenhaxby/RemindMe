//
//  SettingsTableViewCell.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var timeDatePicker: UIDatePicker!
    
    @IBOutlet weak var addNewButton: UIButton!
    
    weak var settingsTableViewController: SettingsTableViewController!
    
    var setting: Setting? {
        didSet {
            
            if setting != nil {

                setupCellVisibilityFor(setting!)
                    
                nameTextField.text = setting!.name
                
                timeDatePicker.date = setting!.time
                
                nameTextField.delegate = self
            }
        }
    }
    
    @IBAction func timeValueChanged(sender: AnyObject) {
        
        nameTextField.resignFirstResponder()
        
        setting!.time = timeDatePicker.date
    }
    
    @IBAction func addNewButtonTouchUpInside(sender: AnyObject) {
        
        settingsTableViewController.addNewSettingRow()
    }
        
    //Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        setting!.name = textField.text!
    }
    
    func setupCellVisibilityFor(setting : Setting) {
        
        let isNewCell : Bool = setting.name == Constants.ReminderItemTableViewCell.NewItemCell
        
        nameTextField.hidden = isNewCell
        timeDatePicker.hidden = isNewCell
        addNewButton.hidden = !isNewCell
        
        
    }
}
