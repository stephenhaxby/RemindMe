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
    
    func createNewDefaultMorningSetting() -> SettingItem {
        
        let defaultMorningSetting = createNewSetting()
        defaultMorningSetting.name = Constants.DefaultMorningTimeText
        defaultMorningSetting.set(date: Constants.DefaultMorningTime)
        defaultMorningSetting.sequence = 0
        
        return defaultMorningSetting
    }
    
    func createNewDefaultAfternoonSetting() -> SettingItem {
        
        let defaultAfternoonSetting = createNewSetting()
        defaultAfternoonSetting.name = Constants.DefaultAfternoonTimeText
        defaultAfternoonSetting.set(date: Constants.DefaultAfternoonTime)
        defaultAfternoonSetting.sequence = 1
        
        return defaultAfternoonSetting
    }
    
    func updateSetting(settingItem : SettingItem) {
        
        if let setting = settingRepository.getSettingBy(id: settingItem.id) {
            
            setting.name = settingItem.name
            setting.sequence = settingItem.sequence
            setting.type = settingItem.type.rawValue
            setting.time = settingItem.time
            setting.longitude = settingItem.longitude
            setting.latitude = settingItem.latitude
        }
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
