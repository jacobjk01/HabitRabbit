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
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var goForwardButton: UIButton!
    @IBOutlet weak var goBackwardButton: UIButton!

    
    let formatter = DateFormatter()
    static var goals = [Goal]()
    static var tableGoals = [Goal]()
    
    var today = Date()
    var todayGoals = [Goal]()
    let refreshControl = UIRefreshControl()
    var currentSection = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.scrollToDate(today)
        monthLabel.text = today.monthAsString()

        setupCalendarView()

        ViewController.goals = CoreDataHelper.retrieveGoals()
        for i in ViewController.goals {
            print(i.title)
            print(i.group)
            print(i.rerun)
            print(i.startDate)
            print(i.endDate)
            print(i.count)
        }
        
//        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
//        self.tableView.addGestureRecognizer(gestureRecognizer)
    }
    
//    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
//        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
//            
//            let translation = gestureRecognizer.translation(in: self.view)
//            // note: 'view' is optional and need to be unwrapped
//            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
//            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
//        }
//    }
    
    func reloadCalendar() {
        //goals = CoreDataHelper.retrieveGoals()
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        self.calendarView.reloadData()
        currentSection = calendarView.currentSection()!
    }
    
    func configureCalendar() {
        refreshControl.addTarget(self, action: #selector(reloadCalendar), for: .valueChanged)
        calendarView.addSubview(refreshControl)
    
    }
    override func viewDidAppear(_ animated: Bool) {
        ViewController.goals = CoreDataHelper.retrieveGoals()
        calendarView.reloadData()
     }
    
    func setupCalendarView() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.scrollingMode = .stopAtEachCalendarFrameWidth
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToCalendar(_ segue: UIStoryboardSegue) {
        ViewController.goals = CoreDataHelper.retrieveGoals()
        calendarView.deselectAllDates()
    }
    @IBAction func previousMonthClicked(_ sender: UIButton) {
        calendarView.scrollToSegment(.previous)
    }
    @IBAction func nextMonthClicked(_ sender: UIButton) {
        calendarView.scrollToSegment(.next)
    }
    
    @IBAction func toToday(_ sender: UIBarButtonItem) {
        print(todayGoals)
        ViewController.tableGoals = todayGoals
    }
}

extension ViewController: JTAppleCalendarViewDataSource{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {

        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = today // You can use date generated from a formatter
        let endDate = Calendar.current.date(byAdding: .month, value: 12, to: Date())
                        // You can also use dates created from this function
//        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        
            let parameters = ConfigurationParameters(startDate: startDate,
                                                         endDate: endDate!,
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
        
        cell.selectedView.isHidden = true
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
        
        cell.dayGoals = []
        
        var count = 0
        for goal in ViewController.goals {
            if date.isBetween(date: goal.startDate!, andDate: goal.endDate! ) {
                cell.dayGoals.append(goal)
                cell.goalDurationLine.isHidden = false
                count += 1
                
                if let color = goal.groupColor {
                    cell.goalDurationLine.backgroundColor = UIColor(hex: color)
                } else {
                    cell.goalDurationLine.backgroundColor = UIColor.black
                }
                if currentDateString == cellStateDateString {
                    todayGoals.append(goal)
                }
            }
        }

        
        if count == 0 {
            cell.goalDurationLine.isHidden = true
            cell.goalDurationLine.backgroundColor = UIColor.black
        }
        
        print(date)
        print(cell.dayGoals)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        guard let validCell = cell as? CustomCell else { return }
        print(validCell.dayGoals)
        validCell.selectedView.isHidden = false
        
        ViewController.tableGoals = []
        
        if validCell.dayGoals.count != 0 {
            for goal in validCell.dayGoals {
                if date.isBetween(date: goal.startDate!, andDate: goal.endDate! ) {
                    ViewController.tableGoals.append(goal)
                }
            }
        }
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCell else { return }
        validCell.selectedView.isHidden = true
        ViewController.tableGoals = []
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: (visibleDates.monthDates.first?.date)!)
        calendarView.reloadData()
    }
    
    
}

//extension ViewController: UITableViewDataSource, UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return ViewController.tableGoals.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell") as! GoalCell
//        
//        //print(ViewController.tableGoals)
//        
//        let row = indexPath.row
//        let goal = ViewController.tableGoals[row]
//        
//        cell.goalLabel.text = goal.title
//        cell.descriptionLabel.text = "Complete your task \(goal.count) more times to reach your goal"
//        cell.groupLabel.text = goal.group
//        if let color = goal.groupColor {
//            cell.groupColorBox.backgroundColor = UIColor(hex: color)
//        } else {
//            cell.groupColorBox.backgroundColor = UIColor.black
//        }
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        // 2
//        if editingStyle == .delete {
//            // 3
//            let deletedGoal = ViewController.tableGoals[indexPath.row]
//            ViewController.tableGoals.remove(at: indexPath.row)
//            if (deletedGoal.repeatStatus == "original") {
//                for goal in goals {
//                    // need a better if statement here
//                    if (goal.repeatStatus == "copy" && goal.title == deletedGoal.title) {
//                        CoreDataHelper.delete(goal: goal)
//                    }
//                }
//            }
//            CoreDataHelper.delete(goal: deletedGoal)
//            
//            tableView.reloadData()
//            goals = CoreDataHelper.retrieveGoals()
//            calendarView.reloadData()
//            
//            print(goals)
//        }
//    }
//}
//
//
