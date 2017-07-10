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
}
