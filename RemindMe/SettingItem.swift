//
//  SettingItem.swift
//  RemindMe
//
//  Created by Stephen Haxby on 12/2/17.
//  Copyright © 2017 Stephen Haxby. All rights reserved.
//

import Foundation

class SettingItem {
    
    var id : String = String()
    
    var name : String = String()
    
    var sequence : Int = 0
    
    private(set) var time : Date?
    
    private(set) var latitude : Double?
    
    private(set) var longitude : Double?
    
    private(set) var type = Constants.ReminderType.notSpecified
    
    func set(latitude : Double, longitude : Double) {
        
        self.latitude = latitude
        self.longitude = longitude
        
        time = nil
        
        type = Constants.ReminderType.location
    }
    
    func set(date : Date) {
        
        self.time = date
        
        latitude = nil
        longitude = nil
        
        type = Constants.ReminderType.location
    }
}
