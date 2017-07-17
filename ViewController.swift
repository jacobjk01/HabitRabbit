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
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let formatter = DateFormatter()
    var goals = [Goal]() {
        didSet {
            //calendarView.reloadData()
        }
    }
    var tableGoals = [Goal]() {
        didSet {
            //tableView.reloadData()
        }
    }
    var today = Date()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ViewController.goals = CoreDataHelper.retrieveGoals()
        //tableView.reloadData()
        
        monthLabel.text = today.monthAsString()
        goalInfoView.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
//        for i in goals {
//            print(i.title)
//            print(i.group)
//            print(i.rerun)
//            print(i.startDate)
//            print(i.endDate)
//            print(i.count)
//        }
        setupCalendarView()
        //reloadCalendar()

        goals = CoreDataHelper.retrieveGoals()
    }
    
    func reloadCalendar() {
        //goals = CoreDataHelper.retrieveGoals()
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        self.calendarView.reloadData()
        self.tableView.reloadData()
    }
    
    func configureCalendar() {
        refreshControl.addTarget(self, action: #selector(reloadCalendar), for: .valueChanged)
        calendarView.addSubview(refreshControl)
    
    }
    override func viewDidAppear(_ animated: Bool) {
//        ViewController.goals = CoreDataHelper.retrieveGoals()
//        
//        goalInfoView.isHidden = true
//        reloadCalendar()
        calendarView.reloadData()
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
        goals = CoreDataHelper.retrieveGoals()
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
        var count = 0
        for goal in goals {
            if date.isBetween(date: goal.startDate! as Date, andDate: goal.endDate! as Date) {
                cell.dayGoals.append(goal)
                cell.goalDurationLine.isHidden = false
                cell.goalDurationLine.backgroundColor = UIColor(hex: goal.groupColor!)
                //cell.setNeedsDisplay()
                count += 1
            }
        }
        
        if count == 0 {
            cell.goalDurationLine.isHidden = true
            cell.goalDurationLine.backgroundColor = UIColor.black
        }
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCell else { return }
        
        validCell.selectedView.isHidden = false
        
        goalInfoView.isHidden = false
        tableGoals = []
        
        if validCell.dayGoals.count == 0 {
            goalInfoView.isHidden = true
        } else {
            for goal in validCell.dayGoals {
                if date.isBetween(date: goal.startDate! as Date, andDate: goal.endDate! as Date) {
                    tableGoals.append(goal)
                }
            }
        }
        
        tableView.reloadData()
        //print(validCell.dayGoals)
        }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCell else { return }
        validCell.selectedView.isHidden = true
        tableGoals = []
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableGoals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell") as! GoalCell
        
        //print(ViewController.tableGoals)
        
        let row = indexPath.row
        let goal = tableGoals[row]
        
        cell.goalLabel.text = goal.title
        cell.descriptionLabel.text = "Complete your task \(goal.count) more times to reach your goal"
        cell.groupLabel.text = goal.group
        cell.groupColorBox.backgroundColor = UIColor(hex: goal.groupColor!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // 2
        if editingStyle == .delete {
            // 3
            let deletedGoal = tableGoals[indexPath.row]
            tableGoals.remove(at: indexPath.row)
            CoreDataHelper.delete(goal: deletedGoal)
            tableView.reloadData()
            goals = CoreDataHelper.retrieveGoals()
            calendarView.reloadData()
        }
    }
}


