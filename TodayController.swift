//
//  TodayController.swift
//  HabitTrack
//
//  Created by Jacob Kim on 7/26/17.
//  Copyright © 2017 Jacob Kim. All rights reserved.
//

import Foundation
import UIKit

class TodayController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        let date = formatter.string(from: ViewController.selectedDate)
        self.navigationItem.title = date
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewController.tableGoals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell") as! GoalCell
        
        //print(ViewController.tableGoals)
        
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // 2
        if editingStyle == .delete {
            // 3
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
    }
    @IBAction func finishGoals(_ sender: Any) {
        performSegue(withIdentifier: "unwindToHome", sender: nil)
        ViewController.tableGoals = []
        ViewController.selectedDate = Date()
    }
    
}
