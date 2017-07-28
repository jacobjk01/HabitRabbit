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

class TodayController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGoalsLabel: UILabel!
    
    var formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = false
        noGoalsLabel.isHidden = true
        
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewController.tableGoals.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell") as! GoalCell
        let row = indexPath.row
        let goal = ViewController.tableGoals[row]
        
        if goal.count == 0 {
            return 100
        }
        return cell.frame.height
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let row = indexPath.row
        let goal = ViewController.tableGoals[row]
        
        if goal.count == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell") as! GoalCell
        
        cell.delegate = self as? SwipeTableViewCellDelegate
        
        //print(ViewController.tableGoals)
        
        if ViewController.tableGoals.count == 0 {
            tableView.isHidden = true
            noGoalsLabel.isHidden = false
        }
        
        let row = indexPath.row
        let goal = ViewController.tableGoals[row]
        
        cell.goalLabel.text = goal.title
        cell.descriptionLabel.text = "Complete your task \(goal.count) more times to reach your goal"
        cell.groupLabel.text = goal.group
        if let color = goal.groupColor {
            cell.groupColorBox.backgroundColor = UIColor(hex: color)
        } else {
            cell.groupColorBox.backgroundColor = UIColor.black
        }
        
        if goal.count == 0 {
            cell.backgroundColor = UIColor(hex: "E7FFE7")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right {
        
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                let deletedGoal = ViewController.tableGoals[indexPath.row]
                    ViewController.tableGoals.remove(at: indexPath.row)
                    if (deletedGoal.repeatStatus == "original") {
                        for goal in ViewController.goals {
                            // need a better if statement here
                            if (goal.repeatStatus == "copy" && goal.title == deletedGoal.title) {
                                CoreDataHelper.delete(goal: goal)
                            }
                        }
                    }
                    CoreDataHelper.delete(goal: deletedGoal)
                
                    tableView.reloadData()
                    ViewController.goals = CoreDataHelper.retrieveGoals()
            }
        
            // customize the action appearance
            deleteAction.image = UIImage(named: "delete")
        
            return [deleteAction]
        }
        else if orientation == .left {
            
            let checkAction = SwipeAction(style: .destructive, title: "Edit", handler: { (action, indexPath) in
                let alertController = UIAlertController(title: "Completed Goals", message: "How many times have you completed this goal?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                    
                }
                alertController.addAction(cancelAction)
                
                alertController.addTextField { textField in
                    textField.placeholder = "Email"
                    textField.keyboardType = .numberPad
                }
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                    let changedGoal = ViewController.tableGoals[indexPath.row]
                    for goal in ViewController.goals {
                        if goal == changedGoal {
                            let num = Int((alertController.textFields?[0].text)!)!
                            for _ in 1...num {
                                if goal.count != 0 {
                                    goal.count = goal.count - 1
                                }
                            }
                        }
                    }
                    tableView.reloadData()
                    CoreDataHelper.saveGoal()
                }
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true) {
                    // ...
                }
            })
            
            checkAction.backgroundColor = UIColor.green
            
            //deleteAction.image =
            
            return [checkAction]
        }
        return nil
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
