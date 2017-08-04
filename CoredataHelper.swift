//
//  CoredataHelper.swift
//  HabitTrack
//
//  Created by Jacob Kim on 7/10/17.
//  Copyright © 2017 Jacob Kim. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataHelper {
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let persistentContainer = appDelegate.persistentContainer
    static let managedContext = persistentContainer.viewContext
    
    var devices = [NSManagedObject]()
    
    static func newGoal() -> Goal{
        let goal = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: managedContext) as! Goal
        return goal
    }
    
    static func saveGoal() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save \(error)")
        }
    }
    
    static func delete(goal: Goal) {
        managedContext.delete(goal)
        saveGoal()
    }
    
    static func retrieveGoals() -> [Goal] {
        let fetchRequest = NSFetchRequest<Goal>(entityName: "Goal")
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        return []
    }
    
    static func retrieveGroupDict() -> [String:String] {
        let fetchRequest = NSFetchRequest<Goal>(entityName: "Goal")
        do {
            let results = try managedContext.fetch(fetchRequest)
            var groupResults: [String:String] = [:]
                for goal in results {
                    if (goal.group != nil) {
                        groupResults[goal.group!] = goal.groupColor
                    }
                }
            return groupResults
        } catch let error as NSError {
        print("Could not fetch \(error)")
        }
        return [:]
    }
    
    static func retrieveGroups() -> [String] {
        let fetchRequest = NSFetchRequest<Goal>(entityName: "Goal")
        do {
            let results = try managedContext.fetch(fetchRequest)
            let groupResults = results.flatMap { (goal: Goal) in
                return goal.group
            }
            return groupResults
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        return []
    }
    
    static func retrieveReminders() -> [Date] {
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
        
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            
            if results.count != 0 {
                var array: [Date] = []
                for result in results {
                    
                    let data = (result as AnyObject).value(forKey: "reminders") as! NSData
                    let unarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: data as Data)
                    let arrayObject = unarchiveObject as AnyObject! as! [Date]
                    array = arrayObject
                }
                return array
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return []
    }
}

