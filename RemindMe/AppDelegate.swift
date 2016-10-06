//
//  AppDelegate.swift
//  RemindMe
//
//  Created by Stephen Haxby on 26/11/2015.
//  Copyright © 2015 Stephen Haxby. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var storageType : Constants.StorageType = Constants.StorageType.local
    
    var window: UIWindow?
    
    var storageFacade : StorageFacadeProtocol?
    
    func setStorageType() {
        
        storageType = (SettingsUserDefaults.useICloudReminders) ? Constants.StorageType.iCloudReminders : Constants.StorageType.local
        
        storageFacade = StorageFacadeFactory.getStorageFacade(storageType, managedObjectContext: managedObjectContext)
        
        if let navigationController = window?.rootViewController as? UINavigationController,
            let remindMeViewController = navigationController.viewControllers.first as? RemindMeViewController {
            
            remindMeViewController.storageFacade = storageFacade
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Register the app for Badge update notifications
        //application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        let currentNotificationCenter = UNUserNotificationCenter.current()
        
        currentNotificationCenter.delegate = self
        
        currentNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) {
            (granted, error) in
            // Enable or disable features based on authorization.
            
            if granted {
                
                //Create Edit action for notification center
                let notificationActionOpen : UNNotificationAction = UNNotificationAction(identifier: Constants.NotificationActionEdit, title: "Edit", options: [UNNotificationActionOptions.foreground])
                
                //Create Remove action for notification center
                let notificationActionRemove : UNNotificationAction = UNNotificationAction(identifier: Constants.NotificationActionRemove, title: "Remove", options: [UNNotificationActionOptions.destructive])
                
                let notificationCategory = UNNotificationCategory(identifier: Constants.NotificationCategory, actions: [notificationActionOpen, notificationActionRemove], intentIdentifiers: [], options: UNNotificationCategoryOptions.customDismissAction)
                
                currentNotificationCenter.setNotificationCategories([notificationCategory])
            }
        }
        
        setStorageType()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if storageType == Constants.StorageType.local {
            
            saveContext()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.RefreshNotification), object: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.MyCompany.RemindMe" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Setting", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    func getManagedObjectContext() -> NSManagedObjectContext {
        
        return managedObjectContext
    }
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    // MARK: - Notification Center
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == Constants.NotificationActionEdit {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationActionEdit), object: response.notification.request.identifier)
        }
        
        if response.actionIdentifier == Constants.NotificationActionRemove {
            
            if (storageFacade!.removeReminder(response.notification.request.identifier)){
                
                UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - 1
            }
        }
        
        completionHandler()
    }
}

