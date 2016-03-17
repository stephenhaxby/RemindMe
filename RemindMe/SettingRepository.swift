//
//  SettingManager.swift
//  RemindMe
//
//  Created by Stephen Haxby on 15/03/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import Foundation
import CoreData

class SettingRepository {
    
    var appDelegate : AppDelegate
    
    init(appDelegate : AppDelegate){
        
        self.appDelegate = appDelegate
    }
    
    func getManagedContext() -> NSManagedObjectContext {
        
        return appDelegate.managedObjectContext
    }
    
    func createNewSetting() -> Setting {
        
        let entity = NSEntityDescription.entityForName("Setting", inManagedObjectContext:getManagedContext())
        
        let settingManagedObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: getManagedContext())
        
        return Setting(managedObject: settingManagedObject)
    }
    
    func createNewSetting(name : String, time : NSDate) -> Setting {
        
        let setting : Setting = createNewSetting()
        
        setting.name = name
        setting.time = time
        
        return setting
    }
    
    func removeSetting(setting : Setting) {
        
        getManagedContext().deleteObject(setting.setting)
    }
    
    func getSettings() -> [Setting]? {
        
        do {
        
        return
            (try getManagedContext().executeFetchRequest(NSFetchRequest(entityName: "Setting")) as! [NSManagedObject]).map({
                
                (managedObject : NSManagedObject) -> Setting in
                
                return Setting(managedObject: managedObject)
            })
            
        }
        catch let error as NSError {
            
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    func commit() -> Bool {
        
        do {
            
            try getManagedContext().save()

        } catch let error as NSError  {
            
            //TODO: A better error...
            print("Could not save \(error), \(error.userInfo)")
            
            return false
        }
        
        return true
    }
}
