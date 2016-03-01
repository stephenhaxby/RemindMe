//
//  SettingsViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 26/11/2015.
//  Copyright © 2015 Stephen Haxby. All rights reserved.
//

import UIKit

class SettingsViewController : UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var morningTimeTextField: UITextField!    
    
    @IBOutlet weak var afternoonTimeTextField: UITextField!
    
    @IBOutlet weak var morningAlertTimeDatePicker: UIDatePicker!
    
    @IBOutlet weak var afternoonAlertTimeDatePicker: UIDatePicker!
    
    var defaults : NSUserDefaults {
        
        get {
            
            return NSUserDefaults.standardUserDefaults()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadMorningTimeTextField()
        
        loadMorningAlertTime()

        loadAfternoonTimeTextField()
        
        loadAfternoonAlertTime()
    }
    
    override func viewWillDisappear(animated : Bool){
        
        defaults.setObject(morningTimeTextField.text, forKey: Constants.MorningTimeText)
        
        defaults.setObject(afternoonTimeTextField.text, forKey: Constants.AfternoonTimeText)
        
        defaults.setObject(morningAlertTimeDatePicker.date, forKey: Constants.MorningAlertTime)
        
        defaults.setObject(afternoonAlertTimeDatePicker.date, forKey: Constants.AfternoonAlertTime)
    }
    
    
    @IBAction func timeValueChanged(sender: AnyObject) {
        
        morningTimeTextField.resignFirstResponder()
        afternoonTimeTextField.resignFirstResponder()
    }
    
    //Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func loadMorningTimeTextField() {
        
        morningTimeTextField.delegate = self
        
        if let storedMorningTimeText: AnyObject = defaults.objectForKey(Constants.MorningTimeText) {
            
            if let morningTimeText : String = storedMorningTimeText as? String {
                
                morningTimeTextField.text = morningTimeText
                return
            }
        }
        
        if morningTimeTextField.text == nil || morningTimeTextField.text! == "" {
            
            morningTimeTextField.text = Constants.DefaultMorningTimeText
        }
    }
    
    func loadMorningAlertTime() {
        
        if let storedMorningDate: AnyObject = defaults.objectForKey(Constants.MorningAlertTime) {
            
            if let morningDate : NSDate = storedMorningDate as? NSDate {
                
                morningAlertTimeDatePicker.date = morningDate
            }
            else {
                
                morningAlertTimeDatePicker.date = Constants.DefaultMorningTime
            }
        }
        else{
            
            morningAlertTimeDatePicker.date = Constants.DefaultMorningTime
        }
    }
    
    func loadAfternoonTimeTextField() {
        
        afternoonTimeTextField.delegate = self
        
        if let storedAfternoonTimeText: AnyObject = defaults.objectForKey(Constants.AfternoonTimeText) {
            
            if let afternoonTimeText : String = storedAfternoonTimeText as? String {
                
                afternoonTimeTextField.text = afternoonTimeText
                return
            }
        }
        
        if afternoonTimeTextField.text == nil || afternoonTimeTextField.text! == "" {
            
            afternoonTimeTextField.text = Constants.DefaultAfternoonTimeText
        }
    }
    
    func loadAfternoonAlertTime() {
        
        if let storedAfternoonDate: AnyObject = defaults.objectForKey(Constants.AfternoonAlertTime) {
            
            if let afternoonDate : NSDate = storedAfternoonDate as? NSDate {
                
                afternoonAlertTimeDatePicker.date = afternoonDate
            }
            else {
                
                afternoonAlertTimeDatePicker.date = Constants.DefaultAfternoonTime
            }
        }
        else{

            afternoonAlertTimeDatePicker.date = Constants.DefaultAfternoonTime
        }
    }
}
