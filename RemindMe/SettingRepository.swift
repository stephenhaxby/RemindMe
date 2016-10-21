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
    
    let context : NSManagedObjectContext
    
    init(appDelegate : AppDelegate){
        
        self.context = appDelegate.managedObjectContext
    }

    func createNewSetting() -> Setting {
        
        let entity = NSEntityDescription.entity(forEntityName: "Setting", in:context)
        
        let settingManagedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        return Setting(managedObject: settingManagedObject)
    }
    
    func createNewSetting(_ name : String, time : Date) -> Setting {
        
        let setting : Setting = createNewSetting()
        
        setting.name = name
        setting.time = time
        setting.latitude = nil
        setting.longitude = nil
        
        return setting
    }
    
    func createNewSetting(_ name : String, time : Date, sequence : Int) -> Setting {
        
        let setting : Setting = createNewSetting(name, time: time)
        setting.sequence = sequence
        
        return setting
    }
    
    func removeSetting(_ setting : Setting) {
        
        context.delete(setting.setting)
    }
    
    func getSettings() -> [Setting] {
        
        do {
        
        return
            (try context.fetch(NSFetchRequest(entityName: "Setting")) ).map({
                
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
            
            try context.save()

        } catch let error as NSError  {
            
              print("Could not save \(error), \(error.userInfo)")
            
            return false
        }
        
        return true
    }
}
