//
//  SettingsViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 26/11/2015.
//  Copyright © 2015 Stephen Haxby. All rights reserved.
//

import UIKit

class SettingsViewController : UIViewController {
    
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
        
        loadMorningAlertTime()

        loadAfternoonAlertTime()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(animated : Bool){
        
        defaults.setObject(morningAlertTimeDatePicker.date, forKey: Constants.MorningAlertTime)
        
        defaults.setObject(afternoonAlertTimeDatePicker.date, forKey: Constants.AfternoonAlertTime)
    }
    
    func loadMorningAlertTime() {
        
        if let storedMorningDate: AnyObject = defaults.objectForKey(Constants.MorningAlertTime) {
            
            if let morningDate : NSDate = storedMorningDate as? NSDate {
                
                morningAlertTimeDatePicker.date = morningDate
            }
        }
        else{
            
            morningAlertTimeDatePicker.date = NSDateManager.currentDateWithHour(7, minute: 0, second: 0)
        }
    }
    
    func loadAfternoonAlertTime() {
        
        if let storedAfternoonDate: AnyObject = defaults.objectForKey(Constants.AfternoonAlertTime) {
            
            if let afternoonDate : NSDate = storedAfternoonDate as? NSDate {
                
                afternoonAlertTimeDatePicker.date = afternoonDate
            }
        }
        else{

            afternoonAlertTimeDatePicker.date = NSDateManager.currentDateWithHour(18, minute: 0, second: 0)
        }
    }
}
