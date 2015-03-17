//
//  ViewController.swift
//  DailyFocus
//
//  Created by Marcus Smith on 3/14/15.
//  Copyright (c) 2015 Marcus Smith. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dailyContent: UITextField!
    @IBOutlet weak var stepperLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    var stepperDelay: Double = 8
    var focusText: String = ""
    var updatedToday: Bool = false
    var focuses = [DailyItem]()
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        } else {
            return nil
        }
    } ()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLog()
        self.dailyContent.delegate = self
        var mostRecent = focuses[0]
        stepperDelay = mostRecent.itemReminder
        focusText = "Your daily focus here"
        
        let calendar = NSCalendar.currentCalendar()
        var timer = calendar.components(.CalendarUnitDay, fromDate: NSDate(), toDate: mostRecent.itemDate, options: nil).day
        if (timer == 0) { //Save day
            titleLabel.text = "Your Focus For Today Is:"
            focusText = mostRecent.itemText
            
        } else { //Another day
            titleLabel.text = "What is your focus today?"
        }
        dailyContent.text = focusText
        
        stepperLabel.text = String(Int(stepperDelay).description)
        stepper.wraps = false
        stepper.minimumValue = 1
        stepper.maximumValue = 48
        stepper.autorepeat = true
        stepper.value = stepperDelay
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dailyContent.resignFirstResponder()
        focusText = textField.text
        saveNewItem(focusText, reminders: stepperDelay)
        scheduleNotification()
        return true
    }
    
    @IBAction func stepperValueChange(sender: AnyObject) {
        stepperLabel.text = String(Int(stepper.value).description)
        stepperDelay = stepper.value
        saveNewItem(focusText, reminders: stepperDelay)
        scheduleNotification()
    }
    
    func fetchLog() {
        
        let fetchRequest = NSFetchRequest(entityName: "DailyItem")
        let sortDescriptor = NSSortDescriptor(key: "itemDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [DailyItem] {
            focuses = fetchResults
            //REMOVE Duplicates
            var filter = Dictionary<NSDate,Int>()
            var len = focuses.count
            for var index = 0; index < len  ;++index {
                var value = focuses[index].itemDate
                if (filter[value] != nil) {
                    focuses.removeAtIndex(index--)
                    len--
                }else{
                    filter[value] = 1
                }
            }
            for element in focuses {
                //println("TEXT:  \(element.itemText)   Date: \(element.itemDate)  reminders: \(element.itemReminder)")
            }
        }
    }
    
    func saveNewItem(text : NSString, reminders : Double) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI:", name: "ScheduleReminder", object: nil)
        var newLogItem = DailyItem.createInManagedObjectContext(self.managedObjectContext!, text: text, reminders: reminders, date: NSDate())
        fetchLog()
        if let newItemIndex = find(focuses, newLogItem) {
            let newLogItemPath = NSIndexPath(forRow: newItemIndex, inSection: 0)
            var error : NSError?
            // printing nil for some reason
            if(managedObjectContext!.save(&error)){
                println(error?.localizedDescription)
            }
        }
    }
    
    func scheduleNotification() {
        var date = NSDate()
        var offGMT = NSTimeZone.localTimeZone().secondsFromGMT
        date = date.dateByAddingTimeInterval(Double(offGMT))
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: NSDate())
        let hour = components.hour
        let minutes = components.minute
        date = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: 2, toDate: date, options: nil)!
        date = date.dateByAddingTimeInterval(60 * ( Double(60-minutes)))
        date = date.dateByAddingTimeInterval(60 * 60 * Double(-hour))
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        var notificationDate = date
        var not: Double = Double(hour + 1)
        while (not < 24) {
            notificationDate = notificationDate.dateByAddingTimeInterval(60 * 60 * Double(stepperDelay))
            let notification = UILocalNotification()
            notification.alertBody = focusText
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.fireDate = notificationDate
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            not += stepperDelay
        }
    }
}

