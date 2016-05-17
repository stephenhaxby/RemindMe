//
//  StorageFacadeFactory.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation

class StorageFacadeFactory {
    
    static func getStorageFacade(storageMethod : String, appDelegate : AppDelegate) -> StorageFacadeProtocol {
        
        switch storageMethod {
        case "iCloudReminders":
            return iCloudReminderFacade(icloudReminderManager : iCloudReminderManager())
//        case "iCloudData":
//            return nil
        case "local":
            return ReminderFacade(reminderRepository: ReminderRepository(appDelegate : appDelegate))
        default:
            return ReminderFacade(reminderRepository: ReminderRepository(appDelegate : appDelegate))
        }
   }
}



    

