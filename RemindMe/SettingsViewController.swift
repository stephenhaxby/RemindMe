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
            
            morningAlertTimeDatePicker.date = newDate(7, minute: 0)
        }
    }
    
    func loadAfternoonAlertTime() {
        
        if let storedAfternoonDate: AnyObject = defaults.objectForKey(Constants.AfternoonAlertTime) {
            
            if let afternoonDate : NSDate = storedAfternoonDate as? NSDate {
                
                afternoonAlertTimeDatePicker.date = afternoonDate
            }
        }
        else{

            afternoonAlertTimeDatePicker.date = newDate(18, minute: 0)
        }
    }
    
    func newDateFrom(components : NSDateComponents) -> NSDate {
        
        let gregorian = NSCalendar(identifier:NSCalendarIdentifierGregorian)
        let date = gregorian!.dateFromComponents(components)
        
        return date!
    }
    
    func newDate(hour : Int, minute : Int) -> NSDate {
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        
        let dateComponents : NSDateComponents = NSDateComponents()
        dateComponents.year = calendar.component(NSCalendarUnit.Year, fromDate: date)
        dateComponents.month = calendar.component(NSCalendarUnit.Month, fromDate: date)
        dateComponents.day = calendar.component(NSCalendarUnit.Day, fromDate: date)
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0
        
        return newDateFrom(dateComponents)
    }
}
