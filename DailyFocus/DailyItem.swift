//
//  DailyItem.swift
//  DailyFocus
//
//  Created by Marcus Smith on 3/14/15.
//  Copyright (c) 2015 Marcus Smith. All rights reserved.
//

import Foundation
import CoreData

class DailyItem: NSManagedObject {

    @NSManaged var itemText: String
    @NSManaged var itemDate: NSDate
    @NSManaged var itemReminder: Double

    class func createInManagedObjectContext(moc: NSManagedObjectContext, text: NSString, reminders: Double, date: NSDate) -> DailyItem {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("DailyItem", inManagedObjectContext: moc) as DailyItem
        newItem.itemDate = date
        newItem.itemText = text
        newItem.itemReminder = reminders
        return newItem
    }
}
