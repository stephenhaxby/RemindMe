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
    //let coreDataContext = CoreDataManager.context()
    
    var managedObjectContext : NSManagedObjectContext
    
    init(managedObjectContext : NSManagedObjectContext){
        
        self.managedObjectContext = managedObjectContext
    }

    func createNewSetting() -> Setting {
        
        let entity = NSEntityDescription.entity(forEntityName: "Setting", in:managedObjectContext)
        
        let settingManagedObject = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
        
        let setting = Setting(managedObject: settingManagedObject)
        setting.id = UUID().uuidString
        setting.name = ""
        setting.sequence = 0
        
        return setting
    }
    
    func remove(setting : Setting) {
        
        managedObjectContext.delete(setting.setting)
    }
    
    func getSettingBy(id : String) -> Setting? {
        
        let settingFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Setting")
        
        settingFetch.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            
            let settings : [Setting] = (try managedObjectContext.fetch(settingFetch) as! [NSManagedObject]).map({
                
                (managedObject : NSManagedObject) -> Setting in
                
                return Setting(managedObject: managedObject)
            })
            
            if settings.count == 1 {
                
                return settings.first!
            }
        }
        catch {
            
            fatalError("Failed to fetch settings: \(error)")
        }
        
        return nil

    }
    
    func getSettings() -> [Setting] {
        
        do {
        
        return
            (try managedObjectContext.fetch(NSFetchRequest(entityName: "Setting")) ).map({
                
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
            
            if managedObjectContext.hasChanges {
            
                try managedObjectContext.save()
            }

        } catch let error as NSError  {
            
              print("Could not save \(error), \(error.userInfo)")
            
            return false
        }
        
        return true
    }
}
