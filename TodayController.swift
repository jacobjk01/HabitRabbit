//
//  TodayController.swift
//  HabitTrack
//
//  Created by Jacob Kim on 7/26/17.
//  Copyright © 2017 Jacob Kim. All rights reserved.
//

import Foundation
import UIKit
import SwipeCellKit
import CoreData
import UserNotifications

class TodayController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGoalsLabel: UILabel!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var infoView: UIView!
    
    var formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = false
        noGoalsLabel.isHidden = true
        doneButton.setTitleTextAttributes([NSFontAttributeName : UIFont(name: "November", size: 17)], for: UIControlState.normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        let date = formatter.string(from: ViewController.selectedDate)
        self.navigationItem.title = date
        
        if ViewController.tableGoals.count == 0 {
            tableView.isHidden = true
            noGoalsLabel.isHidden = false
        }
        
        if ViewController.tableGoals.count < 2 {
            infoView.isHidden = false
            infoView.alpha = 0.3
        } else {
            infoView.isHidden = true
        }
    }
    
    
    
    @IBAction func unwindToToday(_ segue: UIStoryboardSegue) {
        
    }
    
    func deleteAll(deletedGoal: Goal) {
        for goal in ViewController.goals.reversed() {
            if (goal.repeatID == deletedGoal.repeatID) {
                self.deleteReminders(goal: goal)
                CoreDataHelper.delete(goal: goal)
            }
        }
    }
    
    func deleteReminders(goal: Goal) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Reminder")
        
        var identifiers: [String] = []
        do {
            let result = try managedContext?.fetch(fetchRequest)
            
            
            var index = 0
            for currentGoal in ViewController.goals {
                if currentGoal != goal {
                    index += Int(currentGoal.reminderCount)
                } else if goal.reminderCount > 0 {
                    for _ in 1...goal.reminderCount {
                        let reminderID = result?[index].value(forKey: "reminderID") as! String
                        identifiers.append("HabitRabbit Message \(reminderID)")
                        print("deleted \(reminderID)")
                        managedContext?.delete((result?[index])!)
                        index += 1
                    }
                }
            }
            do {
                try managedContext?.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
            print(identifiers.count)
            _ = UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            })
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func updateGoalStreaks(changedGoal: Goal) {
        for goal in ViewController.goals {
            if goal.title == changedGoal.title {
                goal.streak += 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewController.tableGoals.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell") as! GoalCell
        let row = indexPath.row
        let goal = ViewController.tableGoals[row]
        
        if goal.completionStatus == "Done" {
            return 120
        }
        return cell.frame.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell") as! GoalCell
        
        cell.delegate = self
        
        cell.backgroundColor = UIColor.white
        
        if ViewController.tableGoals.count == 0 {
            tableView.isHidden = true
            noGoalsLabel.isHidden = false
        }
        
        let row = indexPath.row
        let goal = ViewController.tableGoals[row]
        
        cell.goalLabel.text = goal.title
        if ViewController.tableGoals[row].completionStatus == "Done" {
            cell.descriptionLabel.text = "Great! You've successfully finished this \(ViewController.tableGoals[row].streak) times in a row!"
            cell.divisionLine.isHidden = true
            cell.groupLabel.isHidden = true
            cell.arrowPicture.isHidden = true
        } else {
            cell.descriptionLabel.text = "Complete This!"
            cell.divisionLine.isHidden = false
            cell.groupLabel.isHidden = false
            cell.arrowPicture.isHidden = false
        }
//        cell.streakLabel
        cell.groupLabel.text = goal.group
        if let color = goal.groupColor {
            cell.groupColorBox.backgroundColor = UIColor(hex: color)
        } else {
            cell.groupColorBox.backgroundColor = UIColor.black
        }
        
        let dateNoTime = Calendar.current.startOfDay(for: ViewController.selectedDate)
        let todayNoTime = Calendar.current.startOfDay(for: Date())
        
        if goal.completionStatus == "Done" {
            cell.backgroundColor = UIColor(hex: "E7FFE7")
            cell.isUserInteractionEnabled = false
        } else if dateNoTime < todayNoTime {
            cell.backgroundColor = UIColor(hex: "FFB2B2")
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .right {
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                let deletedGoal = ViewController.tableGoals[indexPath.row]
                
                    let alertController = UIAlertController(title: "Are you sure?", message: "\n", preferredStyle: .actionSheet)
                
                    let deleteAction = UIAlertAction(title: "Delete This Only", style: .default, handler: { (_) in
                        self.deleteReminders(goal: deletedGoal)
                        CoreDataHelper.delete(goal: deletedGoal)
                        
                        ViewController.tableGoals.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    })
                    let deleteAllAction = UIAlertAction(title: "Delete All", style: .destructive, handler: { (_) in
                        self.deleteAll(deletedGoal: deletedGoal)
                        
                        ViewController.tableGoals.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in })
                
                    alertController.addAction(deleteAction)
                    alertController.addAction(deleteAllAction)
                    alertController.addAction(cancelAction)
                
                    self.present(alertController, animated: true, completion: {
                    })
                
                    ViewController.goals = CoreDataHelper.retrieveGoals()
                    tableView.reloadData()
            }
        
            // customize the action appearance
            deleteAction.image = UIImage(named: "delete")
        
            return [deleteAction]
        }
        else if orientation == .left {
            
            let checkAction = SwipeAction(style: .destructive, title: "Complete", handler: { (action, indexPath) in
                
                let changedGoal = ViewController.tableGoals[indexPath.row]
                for goal in ViewController.goals {
                    if goal == changedGoal {
                        goal.completionStatus = "Done"
                    }
                }
                let cell = tableView.cellForRow(at: indexPath) as! GoalCell
                cell.backgroundColor = UIColor(hex: "E7FFE7")
                self.updateGoalStreaks(changedGoal: changedGoal)
                
                cell.divisionLine.isHidden = true
                cell.groupLabel.isHidden = true
                cell.arrowPicture.isHidden = true
                cell.descriptionLabel.text = "Great! You've successfully finished this \(changedGoal.streak) times in a row!"
                cell.isUserInteractionEnabled = false
                
                tableView.beginUpdates()
                tableView.endUpdates()
                
                
                CoreDataHelper.saveGoal()
            })
            
            checkAction.backgroundColor = UIColor.green
            checkAction.image = UIImage(named: "complete")
            
            return [checkAction]
        }
        return nil
    }
    
    var shownIndexes : [IndexPath] = []
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (shownIndexes.contains(indexPath) == false) {
            shownIndexes.append(indexPath)
            
            let delay = Double(indexPath.row) * 0.1
            UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut ,animations: {
                cell.transform = CGAffineTransform(translationX: 500, y: 0)
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOffset = CGSize(width: 10, height: 10)
                cell.alpha = 0
                
                UIView.beginAnimations("rotation", context: nil)
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
                cell.layer.shadowOffset = CGSize(width: 0, height: 0)
                UIView.commitAnimations()
            }, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = SwipeExpansionStyle.selection
        options.transitionStyle = SwipeTransitionStyle.border
        return options
    }
    
    @IBAction func finishGoals(_ sender: Any) {
        performSegue(withIdentifier: "unwindToHome", sender: nil)
        ViewController.tableGoals = []
        ViewController.selectedDate = Date()
    }
    
}
