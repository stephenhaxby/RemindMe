//
//  RemindMeItem.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation

class RemindMeItem {
    
    var id = String()
    
    var title = String()
    
    var label = String()
    
    private(set) var date : Date?
    
    private(set) var latitude : Double?
    
    private(set) var longitude : Double?
    
    private(set) var type = Constants.ReminderType.notSpecified
    
    func set(latitude : Double, longitude : Double) {
        
        self.latitude = latitude
        self.longitude = longitude
        
        date = nil
        
        type = Constants.ReminderType.location
    }
    
    func set(date : Date) {
        
        self.date = date
        
        latitude = nil
        longitude = nil
        
        type = Constants.ReminderType.dateTime
    }
}
