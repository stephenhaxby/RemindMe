//
//  StorageFacadeFactory.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import CoreData
import Foundation

class StorageFacadeFactory {
    
    static func getStorageFacade(_ storageType : Constants.StorageType, managedObjectContext : NSManagedObjectContext?) -> StorageFacadeProtocol {
        
        return ReminderFacade(reminderRepository: ReminderRepository(managedObjectContext : managedObjectContext!))
        
//        switch storageType {
//            
//            case Constants.StorageType.iCloudReminders:
//                return iCloudReminderFacade(icloudReminderManager : iCloudReminderManager())
//            case Constants.StorageType.local:
//                return ReminderFacade(reminderRepository: ReminderRepository(managedObjectContext : managedObjectContext!))
//        }
   }
}



    

