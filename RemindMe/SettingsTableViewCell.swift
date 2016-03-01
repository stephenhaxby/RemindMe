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
    
    weak var settingsTableViewController: SettingsTableViewController!
    
    var setting: Setting? {
        didSet {
            
            if setting != nil {

                nameTextField.text = setting!.name
                
                timeDatePicker.date = setting!.time
                
                nameTextField.delegate = self
            }
        }
    }
    
    // Resign first responder on the text field if the time value changes
    @IBAction func timeValueChanged(sender: AnyObject) {
        
        nameTextField.resignFirstResponder()
        
        setting!.time = timeDatePicker.date
    }
        
    // Delegate method to resign first reponder on the text field when the user hits return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    // Delegate method to set the setting name
    func textFieldDidEndEditing(textField: UITextField) {
        
        setting!.name = textField.text!
    }
}
