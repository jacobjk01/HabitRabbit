//
//  ViewController.swift
//  HabitTrack
//
//  Created by Jacob Kim on 7/10/17.
//  Copyright © 2017 Jacob Kim. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var goalInfoView: UIView!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var groupColorBox: UIView!
    
    let formatter = DateFormatter()
    static var goals = CoreDataHelper.retrieveGoals()
    var today =
        Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewController.goals = CoreDataHelper.retrieveGoals()
        
        monthLabel.text = today.monthAsString()
        goalInfoView.isHidden = true
        
        for i in ViewController.goals {
            print(i.title)
            print(i.group)
            print(i.rerun)
            print(i.startDate)
            print(i.endDate)
            print(i.count)
        }
        
        setupCalendarView()
    }
    
    func setupCalendarView() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToCalendar(_ segue: UIStoryboardSegue) {
        
    }

    @IBAction func deleteGoalButtonPressed(_ sender: UIButton) {
    }
    
    func updateGoalInfo (goal: Goal) {
        goalLabel.text = goal.title
        let count = goal.count
        descriptionLabel.text = "Complete \(String(describing: count)) more to reach your goal"
        groupLabel.text = goal.group
    }
}

extension ViewController: JTAppleCalendarViewDataSource{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {

        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 07 01")! // You can use date generated from a formatter
        let endDate = Date()                                // You can also use dates created from this function
//        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        
                let parameters = ConfigurationParameters(startDate: startDate,
                                                         endDate: endDate,
                                                 numberOfRows: 6, // Only 1, 2, 3, & 6 are allowed
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid,
            firstDayOfWeek: .sunday)
        return parameters
    }
}


extension ViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
            
        // Setup Cell text
        cell.dateLabel.text = cellState.text
        cell.selectedView.layer.cornerRadius = cell.selectedView.frame.width/2
        
        // Setup text color
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.black
        } else {
            cell.dateLabel.textColor = UIColor.gray
        }
        let currentDateString = formatter.string(from: Date())
        let cellStateDateString = formatter.string(from: cellState.date)
        
        if  currentDateString ==  cellStateDateString {
            cell.dateLabel.textColor = UIColor.red
        }
        
        // Setup Goals
        _ = ViewController.goals.map{ (goal: Goal) -> Bool in
            if date.isBetween(date: goal.startDate!, andDate: goal.endDate!) {
                cell.dayGoals.append(goal)
                cell.goalDurationLine.isHidden = false
                return true
            }
            return false
        }
        if cell.dayGoals.count == 0 {
            cell.goalDurationLine.isHidden = true
        }
        
        //gives me an array but i need to find out how many goals there are for this day and mark them all.
        //later i need to implement colors of the groups.
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCell else { return }
        
        validCell.selectedView.isHidden = false
        
        goalInfoView.isHidden = false
        
        if validCell.dayGoals.count == 0 {
            validCell.goalDurationLine.isHidden = true
            goalInfoView.isHidden = true
        }
        
        //changes the goal info for the specific day
        for dayGoal in validCell.dayGoals {
            updateGoalInfo(goal: dayGoal)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCell else { return }
        validCell.selectedView.isHidden = true
    }
}


