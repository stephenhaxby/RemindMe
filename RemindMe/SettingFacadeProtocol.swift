//
//  SettingFacadeProtocol.swift
//  RemindMe
//
//  Created by Stephen Haxby on 12/2/17.
//  Copyright © 2017 Stephen Haxby. All rights reserved.
//

import Foundation

protocol SettingFacadeProtocol {

    func createNewSetting() -> SettingItem
    
    func remove(settingItem : SettingItem)
    
    func getSettings() -> [SettingItem]
        
    func commit() -> Bool
}
