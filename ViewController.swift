//
//  ViewController.swift
//  HabitTrack
//
//  Created by Jacob Kim on 7/10/17.
//  Copyright © 2017 Jacob Kim. All rights reserved.
//

import UIKit
import JTAppleCalendar
import CoreData
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var goForwardButton: UIButton!
    @IBOutlet weak var goBackwardButton: UIButton!
    @IBOutlet weak var todayButton: UIBarButtonItem!

    
    let formatter = DateFormatter()
    static var goals = [Goal]()
    static var tableGoals = [Goal]()
    
    var today = Date()
    var todayGoals = [Goal]()
    static var selectedDate = Date()
    var currentSection = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        calendarView.scrollToDate(today)
        monthLabel.text = today.monthAsString()
        todayButton.setTitleTextAttributes([NSFontAttributeName : UIFont(name: "November", size: 17)], for: UIControlState.normal)
        
        setupCalendarView()

        ViewController.goals = CoreDataHelper.retrieveGoals()
//        for i in ViewController.goals {
//            print(i.title)
//            print(i.group)
//            print(i.rerun)
//            print(i.startDate)
//            print(i.endDate)
//            print(i.completionStatus)
//            print(i.reminders)
//        }
        today = Date()

        print("view loaded")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        todayGoals = []
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
        calendarView.reloadData()
        todayGoals = []
    }
    @IBAction func previousMonthClicked(_ sender: UIButton) {
        calendarView.scrollToSegment(.previous)
    }
    @IBAction func nextMonthClicked(_ sender: UIButton) {
        calendarView.scrollToSegment(.next)
    }
    
    @IBAction func toToday(_ sender: UIBarButtonItem) {
        print(todayGoals)
        ViewController.selectedDate = today
        ViewController.tableGoals = todayGoals
        
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        
        performSegue(withIdentifier: "dateClicked", sender: nil)
    }
    
    @IBAction func addClicked(_ sender: UIBarButtonItem) {
        
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        
        performSegue(withIdentifier: "addClicked", sender: nil)
    }
    
    func dayClicked() {
        
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        
        performSegue(withIdentifier: "dateClicked", sender: nil)
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
        
//        cell.transform = CGAffineTransform(scaleX: 0, y: 0)
//        let delay = Double(indexPath.row) * 0.015
//        UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: .curveEaseInOut ,animations: {
//            cell.transform = CGAffineTransform.identity
//        }, completion: nil)
        
        
        cell.selectedView.isHidden = false
        // Setup Cell text
        cell.dateLabel.text = cellState.text
        
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
        cell.lineView.colors = []
        cell.lineView.values = []
        
        cell.lineView.frame.origin.x = cell.selectedView.frame.origin.x
        cell.lineView.frame.origin.y = cell.selectedView.frame.origin.y + 41
        
        let dateNoTime = Calendar.current.startOfDay(for: date)
        let todayNoTime = Calendar.current.startOfDay(for: today)
        
        var count = 0
        for goal in ViewController.goals {
            if date.isBetween(date: goal.startDate!, andDate: goal.endDate! ) {
                cell.dayGoals.append(goal)
                //cell.initializeLineView()
                    cell.lineView.isHidden = false
            
                    if let color = goal.groupColor {
                        cell.lineView.colors.append(UIColor(hex: color))
                    } else {
                        cell.lineView.colors.append(UIColor.black)
                    }
                count += 1
            }
        }
        
        if currentDateString == cellStateDateString {
            todayGoals = []
            todayGoals = cell.dayGoals
        }
        
        
        if count == 0 {
            cell.lineView.isHidden = true
            cell.lineView.colors = []
            cell.lineView.values = []
        } else {
            cell.lineView.isHidden = false
            if dateNoTime < todayNoTime {
                var passedDayStatus = true

                for goal in cell.dayGoals {
                    if goal.completionStatus == "Not Done" {
                        passedDayStatus = false
                    }
                }
                
                if passedDayStatus == false {
                    cell.lineView.colors = [UIColor.red]
                    cell.lineView.values = [1]
                } else {
                    cell.lineView.colors = [UIColor.green]
                    cell.lineView.values = [1]
                }
            } else {
                let value = CGFloat(1 / Double(cell.lineView.colors.count))
                for _ in 0..<count {
                    cell.lineView.values.append(value)
                }
                
                var passedDayStatus = true
                
                for goal in cell.dayGoals {
                    if goal.completionStatus == "Not Done" {
                        passedDayStatus = false
                    }
                }
                if passedDayStatus == true {
                    cell.lineView.colors = [UIColor.green]
                    cell.lineView.values = [1]
                }
            }
        }
        cell.addSubview(cell.lineView)
        
        //scheduleReminders()

        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        guard let validCell = cell as? CustomCell else { return }
        //print(validCell.dayGoals)
        
        ViewController.tableGoals = []
        
        if validCell.dayGoals.count != 0 {
            for goal in validCell.dayGoals {
                if date.isBetween(date: goal.startDate!, andDate: goal.endDate! ) {
                    ViewController.tableGoals.append(goal)
                }
            }
            ViewController.selectedDate = date
            dayClicked()
        }
        print(validCell.dayGoals)
        
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: (visibleDates.monthDates.first?.date)!)
        calendarView.reloadData()
    }
    
    
}
