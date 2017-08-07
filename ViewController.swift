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
    
    static var isGrantedNotificationAccess:Bool = false
    
    
    static var todayReminders: [Date] = []
    
    
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        ViewController.goals = CoreDataHelper.retrieveGoals()
        todayGoals = []
        print("today's reminders: \(ViewController.todayReminders)")
        printReminders()
        print("view appeared")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        calendarView.reloadData()
        print ("view will appear")
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
        todayGoals = []
        
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
    
    func addReminders(goal: Goal, reminders:[Date]) {
        var index = 0
        for currentGoal in ViewController.goals {
            if currentGoal != goal {
                index += Int(currentGoal.reminderCount)
            } else if goal.reminderCount > 0 {
                for _ in 1...goal.reminderCount {
                    ViewController.todayReminders.append(reminders[index])
                    index += 1
                }
                
            }
        }
    }
    
    func printReminders() {
        formatter.timeStyle = .short
        for reminder in ViewController.todayReminders {
            print("today's Reminder: \(formatter.string(from: reminder))")
        }
    }
    
    func printFetchedReminders(reminders: [Date]) {
        formatter.timeStyle = .short
        
        for reminder in reminders {
            print("fetched: \(formatter.string(from: reminder))")
        }
    }
    
    func scheduleReminders() {
        for reminder in ViewController.todayReminders {
            print("schedule: \(reminder)")
            //LocalNotification.dispatchlocalNotification(with: "Don't Forget!", body: "insertgoalname", at: reminder)
        }
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
        
        cell.selectedView.isHidden = true
        // Setup Cell text
        cell.dateLabel.text = cellState.text
        //cell.selectedView.layer.cornerRadius = cell.selectedView.frame.width/2
        
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
        
        let dateNoTime = Calendar.current.startOfDay(for: date)
        let todayNoTime = Calendar.current.startOfDay(for: today)
        
        var count = 0
        for goal in ViewController.goals {
            if date.isBetween(date: goal.startDate!, andDate: goal.endDate! ) {
                cell.dayGoals.append(goal)
                    cell.lineView.isHidden = false
            
                    if let color = goal.groupColor {
                        cell.lineView.colors.append(UIColor(hex: color))
                    } else {
                        cell.lineView.colors.append(UIColor.black)
                    }
            
                if currentDateString == cellStateDateString {
                    todayGoals.append(goal)
                    
                    //setup reminders
                    
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let managedContext = appDelegate?.persistentContainer.viewContext
                    
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Reminder")
                    
                    formatter.timeStyle = .short
                    
                    do {
                        let result = try managedContext?.fetch(fetchRequest)
                        print(result?.count)
                        var reminders: [Date] = []
                        for r in result! {
                            
                            reminders.append(r.value(forKey: "time") as! Date)
                        }
                        printFetchedReminders(reminders: reminders)
                        addReminders(goal: goal, reminders: reminders)

                    } catch {
                        let fetchError = error as NSError
                        print(fetchError)
                    }
                    
                }
                count += 1
            } 
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
        
        cell.selectedView.isHidden = false
        
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
        
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: (visibleDates.monthDates.first?.date)!)
        calendarView.reloadData()
    }
    
    
}

//class LocalNotification: NSObject, UNUserNotificationCenterDelegate {
//    
//    class func registerForLocalNotification(on application:UIApplication) {
//        if (UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:)))) {
////            let notificationCategory: UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
////            notificationCategory.identifier = "NOTIFICATION_CATEGORY"
//            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
//                (granted, error) in
//                if !granted {
//                    print("Something went wrong")
//                }
//            }
//            UNUserNotificationCenter.current().delegate = LocalNotification()
//
//            
//            //registering for the notification.
//            application.registerUserNotificationSettings(UIUserNotificationSettings(types:[.sound, .alert, .badge], categories: nil))
//        }
//    }
//    
//    class func dispatchlocalNotification(with title: String, body: String, userInfo: [AnyHashable: Any]? = nil, at date:Date) {
//        
//        if #available(iOS 10.0, *) {
//            
//            let center = UNUserNotificationCenter.current()
//            let content = UNMutableNotificationContent()
//            content.title = title
//            content.body = body
//            content.sound = UNNotificationSound.default()
//            //content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
//            
//            if let info = userInfo {
//                content.userInfo = info
//            }
//            
//            let comp = Calendar.current.dateComponents([.day, .hour, .minute], from: date)
//            
//            let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)
//            
//            let request = UNNotificationRequest(identifier: "com.jacobkim.HabitRabbit", content: content, trigger: trigger)
//
//            center.add(request)
//            
//        } else {
//            
//            let notification = UILocalNotification()
//            notification.fireDate = date
//            notification.alertTitle = title
//            notification.alertBody = body
//            notification.soundName = UILocalNotificationDefaultSoundName
//            
//            if let info = userInfo {
//                notification.userInfo = info
//            }
//            
//            UIApplication.shared.scheduleLocalNotification(notification)
//            
//        }
//        
//        print("WILL DISPATCH LOCAL NOTIFICATION AT ", date)
//        
//    }
//}
