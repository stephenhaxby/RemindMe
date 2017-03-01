//
//  SettingFacadeFactory.swift
//  RemindMe
//
//  Created by Stephen Haxby on 13/2/17.
//  Copyright © 2017 Stephen Haxby. All rights reserved.
//

import CoreData
import Foundation

class SettingFacadeFactory {
    
    static func getSettingFacade(storageType : Constants.StorageType, managedObjectContext : NSManagedObjectContext?) -> SettingFacadeProtocol {
        
        switch storageType {
            
            case Constants.StorageType.local:
                return SettingFacade(settingRepository: SettingRepository(managedObjectContext : managedObjectContext!))
        }
    }
}
