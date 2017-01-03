//
//  SettingREpository.swift
//  RemindMe
//
//  Created by Stephen Haxby on 15/03/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation
import CoreData

class SettingRepository {
    
    //Gets the managed object context for core data (as a singleton)
    let coreDataContext = CoreDataManager.context()

    func createNewSetting() -> Setting {
        
        let entity = NSEntityDescription.entity(forEntityName: "Setting", in:coreDataContext)
        
        let settingManagedObject = NSManagedObject(entity: entity!, insertInto: coreDataContext)
        
        return Setting(managedObject: settingManagedObject)
    }
    
    func createNewSetting(_ name : String, time : Date) -> Setting {
        
        let setting : Setting = createNewSetting()
        
        setting.name = name
        setting.time = time
        setting.latitude = 0
        setting.longitude = 0
        
        return setting
    }
    
    func createNewSetting(_ name : String, time : Date, sequence : Int) -> Setting {
        
        let setting : Setting = createNewSetting(name, time: time)
        setting.sequence = sequence
        
        return setting
    }
    
    func removeSetting(_ setting : Setting) {
        
        coreDataContext.delete(setting.setting)
    }
    
    func getSettings() -> [Setting] {
        
        do {
        
        return
            (try coreDataContext.fetch(NSFetchRequest(entityName: "Setting")) ).map({
                
                (managedObject : NSManagedObject) -> Setting in
                
                return Setting(managedObject: managedObject)
            })            
        }
        catch let error as NSError {
            
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return [Setting]()
    }
    
    func commit() -> Bool {
        
        do {
            
            try coreDataContext.save()

        } catch let error as NSError  {
            
              print("Could not save \(error), \(error.userInfo)")
            
            return false
        }
        
        return true
    }
}
