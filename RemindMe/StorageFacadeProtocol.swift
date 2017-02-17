//
//  StorageFacadeProtocol.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation

protocol StorageFacadeProtocol {
    
    func createOrUpdateReminder(_ remindMeItem : RemindMeItem) -> Bool
    
    func removeReminder(_ remindMeItem : RemindMeItem) -> Bool
    
    func removeReminder(_ Id : String) -> Bool
    
    //Expects a function that has a parameter that's an array of RemindMeItem
    func getReminders(_ returnReminders : @escaping ([RemindMeItem]) -> ())
    
    func commit() -> Bool
}
