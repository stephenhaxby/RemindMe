//
//  StorageFacadeProtocol.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation

protocol StorageFacadeProtocol {
    
    func createNewReminder() -> RemindMeItem
    
    func createNewReminder(name : String, time : NSDate) -> RemindMeItem
    
    func updateReminder(remindMeItem : RemindMeItem)
    
    func removeReminder(remindMeItem : RemindMeItem)
    
    //Expects a function that has a parameter that's an array of RemindMeItem
    func getReminders(returnReminders : [RemindMeItem] -> ())
    
    func commit() -> Bool
}