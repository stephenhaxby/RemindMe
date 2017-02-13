//
//  AppDelegate.swift
//  RemindMe
//
//  Created by Stephen Haxby on 26/11/2015.
//  Copyright © 2015 Stephen Haxby. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    //Gets the managed object context for core data (as a singleton)
    private let coreDataContext = CoreDataManager.context()
    
    private var storageType : Constants.StorageType = Constants.StorageType.local
    
    internal var window: UIWindow?
    
    private var storageFacade : StorageFacadeProtocol?
    private var settingFacade : SettingFacadeProtocol?
    
    var AppSettingFacade : SettingFacadeProtocol {
        
        get{
            
            return settingFacade!
        }
    }
    
    func setStorageType() {
                
        storageType = Constants.StorageType.local
        storageFacade = StorageFacadeFactory.getStorageFacade(storageType, managedObjectContext: coreDataContext)
        settingFacade = SettingFacadeFactory.getSettingFacade(storageType: storageType, managedObjectContext: coreDataContext)
        
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
            
            CoreDataManager.saveContext(context: coreDataContext)
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

