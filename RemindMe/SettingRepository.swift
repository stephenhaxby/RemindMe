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
        
        let entity = NSEntityDescription.entityForName("Setting", inManagedObjectContext:context)
        
        let settingManagedObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
        
        return Setting(managedObject: settingManagedObject)
    }
    
    func createNewSetting(name : String, time : NSDate) -> Setting {
        
        let setting : Setting = createNewSetting()
        
        setting.name = name
        setting.time = time
        
        return setting
    }
    
    func createNewSetting(name : String, time : NSDate, sequence : Int) -> Setting {
        
        let setting : Setting = createNewSetting(name, time: time)
        setting.sequence = sequence
        
        return setting
    }
    
    func removeSetting(setting : Setting) {
        
        context.deleteObject(setting.setting)
    }
    
    func getSettings() -> [Setting] {
        
        do {
        
        return
            (try context.executeFetchRequest(NSFetchRequest(entityName: "Setting")) as! [NSManagedObject]).map({
                
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
