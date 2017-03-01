//
//  ReminderItemSequenceRepository.swift
//  RemindMe
//
//  Created by Stephen Haxby on 11/2/17.
//  Copyright © 2017 Stephen Haxby. All rights reserved.
//

import Foundation

// Repository class to save a list of ReminderItemSequence objects to disk
class ReminderItemSequenceRepository {
    
    private let ArchiveURL : URL
    
    init() {
        
        // Get the path to save our list too; the apps document directory in it's sandbox
        let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        
        ArchiveURL = DocumentsDirectory.appendingPathComponent(Constants.ArchivePath)
    }
    
    // Save the list to the file system
    func Archive(reminderItemSequenceList : [ReminderItemSequence]) -> Bool {
        
        return NSKeyedArchiver.archiveRootObject(reminderItemSequenceList, toFile: ArchiveURL.path)
    }
    
    // Load up the list from the file system
    func UnArchive() -> [ReminderItemSequence] {
        
        if let archive = NSKeyedUnarchiver.unarchiveObject(withFile: ArchiveURL.path) as? [ReminderItemSequence] {
            
            return archive
        }
        
        return [ReminderItemSequence]()
    }
}

