//
//  SettingFacade.swift
//  RemindMe
//
//  Created by Stephen Haxby on 12/2/17.
//  Copyright © 2017 Stephen Haxby. All rights reserved.
//

import Foundation

class SettingFacade : SettingFacadeProtocol {
    
    var settingRepository : SettingRepository
    
    init (settingRepository : SettingRepository) {
        
        self.settingRepository = settingRepository
    }
    
    func createNewSetting() -> SettingItem {
        
        return getSettingItemFrom(setting: settingRepository.createNewSetting())
    }
    
    func getSettingItemFrom(setting : Setting) -> SettingItem {
        
        let settingItem = SettingItem()
        
        settingItem.id = setting.id
        settingItem.name = setting.name
        settingItem.sequence = setting.sequence
        
        switch setting.type {
            case Constants.ReminderType.dateTime.rawValue:
            
                if let date = setting.time {
                    
                    settingItem.set(date: date)
                }
            
            case Constants.ReminderType.location.rawValue:
            
                if let latitude = setting.latitude,
                    let longitude = setting.longitude {
                    
                    settingItem.set(latitude: latitude, longitude: longitude)
                }
            
            default:
                break
        }
        
        return settingItem
    }
    
    func remove(settingItem: SettingItem) {
        
        if let setting : Setting = settingRepository.getSettingBy(id: settingItem.id) {
            
            settingRepository.remove(setting: setting)
        }
    }
    
    func getSettings() -> [SettingItem] {
        
        return settingRepository.getSettings().map({
            
            (setting : Setting) -> SettingItem in
            
            return getSettingItemFrom(setting: setting)
        })
    }
    
    func commit() -> Bool {
        
        return settingRepository.commit()
    }
}
