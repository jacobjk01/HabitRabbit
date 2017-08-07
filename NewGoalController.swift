//
//  NewGoalController.swift
//  HabitTrack
//
//  Created by Jacob Kim on 7/10/17.
//  Copyright © 2017 Jacob Kim. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import ColorPickerRow
import CoreData
import UserNotifications

class NewGoalController: FormViewController, UNUserNotificationCenterDelegate {
    
    var newGoal = CoreDataHelper.newGoal()
    var groupDict = CoreDataHelper.retrieveGroupDict()
    var groups = Array(Set(CoreDataHelper.retrieveGroups()))
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var reminders = [NSManagedObject]()
    var isGrantedNotificationAccess = false
    
    let colors = ["CD5C5C", "F08080", "FA8072", "E9967A", "FFA07A", "DC143C", "FF0000", "B22222", "8B0000", "FFC0CB", "FFB6C1", "FF69B4", "FF1493", "C71585", "DB7093", "FFA07A", "FF7F50", "FF6347", "FF4500", "FF8C00", "FFA500", "FFD700", "FFFF00", "FFE4B5", "FFDAB9", "F0E68C", "E6E6FA", "D8BFD8", "DDA0DD", "EE82EE", "DA70D6", "FF00FF", "BA55D3", "9370DB", "663399", "8A2BE2", "9400D3", "9932CC", "8B008B", "800080", "4B0082", "6A5ACD", "483D8B", "7B68EE", "191970", "00008B", "0000CD", "0000FF", "4169E1", "7B68EE", "6495ED", "1E90FF", "00BFFF", "87CEFA", "87CEEB", "B0E0E6", "B0C4DE", "4682B4", "5F9EA0", "00CED1", "40E0D0", "7FFFD4", "AFEEEE", "E0FFFF", "00FFFF", "008080", "008B8B", "20B2AA", "66CDAA", "6B8E23", "9ACD32", "006400", "228B22", "3CB371", "00FF7F", "00FA9A", "98FB98", "32CD32", "00FF00", "7FFF00", "ADFF2F"]
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //registerForLocalNotification(on: UIApplication.shared)
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isGrantedNotificationAccess = granted
        }
        )
        
        cancelButton.setTitleTextAttributes([NSFontAttributeName : UIFont(name: "November", size: 17)!], for: UIControlState.normal)
        
        
        if groups.count == 0 {
            groups.append("New...")
        }
        else if groups[groups.count - 1] != "New..." {
            groups.append("New...")
        }
        
        //setup
        form +++ Section("New Goal")
            <<< TextRow("Title") { row in
                row.title = "Title"
                row.placeholder = "Enter title here"
                let ruleRequiredViaClosure = RuleClosure<String> { rowValue in
                    return (rowValue == nil || rowValue!.isEmpty) ? ValidationError(msg: "Field required!") : nil
                }
                row.add(rule: ruleRequiredViaClosure)
                row.validationOptions = .validatesAlways
            }.cellSetup({ (cell, row) in
                cell.textLabel?.font = UIFont(name: "November", size: 17)
            })
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
        +++ Section("Date")
            <<< SwitchRow("One Day") {
                $0.title = $0.tag
                $0.value = false
            }.cellSetup({ (cell, row) in
                cell.textLabel?.font = UIFont(name: "November", size: 17)
            })
            <<< DateInlineRow("Start Date") {
                $0.title = $0.tag
                $0.value = Date()
                $0.hidden = Condition.function(["One Day"], { form in
                    return !((form.rowBy(tag: "One Day") as? SwitchRow)?.value != true)
                })
            }.onChange({ (DateInlineRow) in
                let endDateRow: DateInlineRow = self.form.rowBy(tag: "End Date")!
                if endDateRow.value?.compare(DateInlineRow.value!) == ComparisonResult.orderedAscending {
                    DateInlineRow.value = endDateRow.value
                    DateInlineRow.toggleInlineRow()
                    DateInlineRow.toggleInlineRow()
                }
            }).cellSetup({ (cell, row) in
                cell.textLabel?.font = UIFont(name: "November", size: 17)
            })
            <<< DateInlineRow("End Date") {
                $0.title = $0.tag
                $0.value = Date()
                $0.hidden = Condition.function(["One Day"], { form in
                    return !((form.rowBy(tag: "One Day") as? SwitchRow)?.value != true)
                })
            }.onChange({ (DateInlineRow) in
                let startDateRow: DateInlineRow = self.form.rowBy(tag: "Start Date")!
                if startDateRow.value?.compare(DateInlineRow.value!) == ComparisonResult.orderedDescending {
                    DateInlineRow.value = startDateRow.value
                    DateInlineRow.toggleInlineRow()
                    DateInlineRow.toggleInlineRow()
                }
            }).cellSetup({ (cell, row) in
                cell.textLabel?.font = UIFont(name: "November", size: 17)
            })
            <<< DateInlineRow("Date") {
                $0.title = $0.tag
                $0.value = Date()
                $0.hidden = Condition.function(["One Day"], { form in
                    return !((form.rowBy(tag: "One Day") as? SwitchRow)?.value == true)
                })
            }.cellSetup({ (cell, row) in
                cell.textLabel?.font = UIFont(name: "November", size: 17)
            })
            
        +++ Section("Repeat")
            <<< PushRow<String>("Repeat Interval") {
                $0.title = $0.tag
                $0.value = "None"
                $0.selectorTitle = "Select a Repeat Interval"
                $0.options = ["None", "Daily", "Weekdays", "Weekends", "Weekly", "Every Other Week", "Monthly"]
            }.cellSetup({ (cell, row) in
                cell.textLabel?.font = UIFont(name: "November", size: 17)
            })

            <<< PushRow<String>("Repeat End Date") {
                $0.title = $0.tag
                $0.value = "One Week Later"
                $0.selectorTitle = "Select a Repeat End"
                $0.options = ["One Week Later", "One Month Later", "Six Months Later", "One Year Later", "Custom..."]
                $0.hidden = Condition.function(["Repeat Interval"], { form in
                    return !((form.rowBy(tag: "Repeat Interval") as? PushRow)?.value != "None")
                })
            }.cellSetup({ (cell, row) in
                cell.textLabel?.font = UIFont(name: "November", size: 17)
            })
            <<< DateInlineRow("Custom Repeat End Date") {
                $0.title = $0.tag
                $0.value = Date()
                $0.hidden = Condition.function(["Repeat End Date"], { form in
                    return !((form.rowBy(tag: "Repeat End Date") as? PushRow)?.value == "Custom...")
                })
            }.cellSetup({ (cell, row) in
                cell.textLabel?.font = UIFont(name: "November", size: 17)
            })
        +++ Section("Category")
            <<< PushRow<String> ("Group"){
                $0.title = "Category"
                $0.value = ""
                $0.selectorTitle = "Select Your Goal's Category"
                $0.options = groups
                let ruleRequiredViaClosure = RuleClosure<String> { rowValue in
                    return (rowValue == nil || rowValue!.isEmpty) ? ValidationError(msg: "Field required!") : nil
                }
                $0.add(rule: ruleRequiredViaClosure)
                $0.validationOptions = .validatesOnChange
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .red
                    cell.layer.borderColor = UIColor.red.cgColor
                }
            }.cellSetup({ (cell, row) in
                cell.textLabel?.font = UIFont(name: "November", size: 17)
            })
            
            <<< TextRow("New Group Name") { row in
                row.title = "New Group Name"
                row.value = ""
                row.placeholder = "Goal Category"
                row.hidden = Condition.function(["Group"], { form in
                    return !((form.rowBy(tag: "Group") as? PushRow)?.value == "New...")
                })
                
            }.cellSetup({ (cell, row) in
                cell.textLabel?.font = UIFont(name: "November", size: 17)
            })
            
            <<< ColorPickerRow("New Group Color") { row in
                row.title = "New Group Color"
                row.value = UIColor.blue
                row.isCircular = true
                row.showsPaletteNames = false
                row.showsCurrentSwatch = true
                row.hidden = Condition.function(["Group"], { form in
                    return !((form.rowBy(tag: "Group") as? PushRow)?.value == "New...")
                })
            }.cellSetup({ (cell, row) in
                let palette = self.getColorPalette()
                cell.palettes = [palette]
                cell.textLabel?.font = UIFont(name: "November", size: 17)
            })
            
            +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], header: "Reminders") {
                $0.addButtonProvider = { section in
                    return ButtonRow(){
                        $0.title = "Add New Reminder"
                    }
                }
                $0.multivaluedRowToInsertAt = { index in
                    return TimeRow("tag_\(index+1)") {
                        let gregorian = Calendar(identifier: .gregorian)
                        let now = Date()
                        let components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
                        
                        let defaultTime = gregorian.date(from: components)!
                        $0.baseValue = defaultTime
                        $0.title = "Reminder:"
                    }
                }
            }

        +++ Section("Submit")
            <<< ButtonRow ("Save") {
                $0.title = $0.tag
            }.cellSetup({ (cell, row) in
                cell.textLabel?.font = UIFont(name: "November", size: 17)
            }).onCellSelection({ (cell, row) in
                let formValues = self.form.values()
                
                let alertController = UIAlertController(title: "Could not save", message: "\n", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                }
                alertController.addAction(OKAction)
                
                self.newGoal.title = formValues["Title"] as? String
                guard (self.newGoal.title != nil && self.newGoal.title != "") else {
                    alertController.message?.append("Title not valid \n")
                    self.present(alertController, animated: true)
                    return
                }
                
                if formValues["One Day"] as? Bool == false {
                    self.newGoal.startDate = formValues["Start Date"] as? NSDate
                    self.newGoal.endDate = formValues["End Date"] as? NSDate
                } else {
                    self.newGoal.startDate = formValues["Date"] as? NSDate
                    self.newGoal.endDate = formValues["Date"] as? NSDate
                }
                
                self.newGoal.completionStatus = "Not Done"
                
                let group = formValues["Group"] as? String
                if group != "New..." {
                    self.newGoal.group = group
                    self.newGoal.groupColor = self.groupDict[group!]
                } else {
                    self.newGoal.group = formValues["New Group Name"] as? String
                    
                    guard (self.newGoal.group != nil && self.newGoal.group != "") else {
                        alertController.message?.append("Group Name not valid \n")
                        self.present(alertController, animated: true)
                        return
                    }
                    
                    var groupColor = (formValues["New Group Color"] as! UIColor).toHexString()
                    groupColor.remove(at: groupColor.startIndex)
                    self.newGoal.groupColor = groupColor
                    self.groups.append(self.newGoal.group!)
                    self.groupDict[self.newGoal.group!] = self.newGoal.groupColor
                }
                
                self.newGoal.rerun = formValues["Repeat Interval"] as? String
                if formValues["Repeat End Date"] as? String != "Custom..." && formValues["Repeat Interval"] as? String != "None" {
                    let repeatEndDate = formValues["Repeat End Date"] as! String
                    
                    switch repeatEndDate {
                        case "One Week Later":
                            let endRepeat = self.newGoal.endDate?.addingTimeInterval(60*60*24*7)
                            self.newGoal.repeatEndDate = endRepeat
                            self.repeatCreateGoal(repeatInterval: self.newGoal.rerun!, repeatEndDate: endRepeat! as Date)
                        case "One Month Later":
                            let endRepeat = Calendar.current.date(byAdding: .month
                                , value: 1, to: self.newGoal.endDate! as Date)
                            self.newGoal.repeatEndDate = endRepeat! as NSDate
                            self.repeatCreateGoal(repeatInterval: self.newGoal.rerun!, repeatEndDate: endRepeat! as Date)
                        case "Six Months Later":
                            let endRepeat = Calendar.current.date(byAdding: .month, value: 6, to: self.newGoal.endDate! as Date)
                            self.newGoal.repeatEndDate = endRepeat as NSDate?
                            self.repeatCreateGoal(repeatInterval: self.newGoal.rerun!, repeatEndDate: endRepeat! as Date)
                        case "One Year Later":
                            let endRepeat = Calendar.current.date(byAdding: .year, value: 1, to: self.newGoal.endDate! as Date)
                            self.newGoal.repeatEndDate = endRepeat as NSDate?
                            self.repeatCreateGoal(repeatInterval: self.newGoal.rerun!, repeatEndDate: endRepeat! as Date)
                    default:
                            break
                    }
                } else if formValues["Repeat Interval"] as? String != "None" {
                    let endRepeat = formValues["Custom Repeat End Date"] as? NSDate
                    self.newGoal.repeatEndDate = endRepeat
                    self.repeatCreateGoal(repeatInterval: self.newGoal.rerun!, repeatEndDate: endRepeat! as Date)
                }
                
                //Reminders
                
                self.newGoal.reminderCount = 0
                
                let formatter = DateFormatter()
                formatter.timeZone = NSTimeZone.default
                formatter.timeStyle = .short
                
                
                var i: Int = 1
                while formValues["tag_\(i)"] != nil {
                    let time = formValues["tag_\(i)"] as! Date
                    let printDate = formatter.string(from: time)
                    print("saved \(printDate)")
                    print(time)
                    self.saveReminder(time: time, goal: self.newGoal)
                    self.newGoal.reminders?.adding(time)
                    i+=1
                    self.newGoal.reminderCount += 1
                }
                
                
                self.performSegue(withIdentifier: "unwindToCalendar", sender: nil)
                ViewController.todayReminders = []
                CoreDataHelper.saveGoal()
            })
    }

    
    func saveReminder(time: Date, goal: Goal) {
        
        if isGrantedNotificationAccess == true {
            let content = UNMutableNotificationContent()
            content.title = "Don't Forget!"
            content.body = goal.title!
            content.categoryIdentifier = "message"
            content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
            
            let triggerDate =
                Calendar.current.dateComponents([.day, .hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(identifier: "HabitRabbit Message \()", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            print("WILL DISPATCH LOCAL NOTIFICATION AT ", time)
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Reminder", in: managedContext)
        
        let reminder = NSManagedObject(entity: entity!, insertInto: managedContext)
        reminder.setValue(time, forKeyPath: "time")
        
        do {
            try managedContext.save()
            reminders.append(reminder)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func repeatCreateGoal (repeatInterval: String, repeatEndDate: Date) {
        var tempGoal = newGoal
        switch repeatInterval {
            case "Daily":
                while tempGoal.endDate?.compare(repeatEndDate) != ComparisonResult.orderedDescending {
                     let repeatGoal = goalDayLater(goal: tempGoal)
                    CoreDataHelper.saveGoal()
                    tempGoal = repeatGoal
                }
            case "Weekdays":
                while (tempGoal.endDate!.compare(repeatEndDate) != ComparisonResult.orderedDescending ) {
                    var repeatGoal = tempGoal
                    if  ((tempGoal.startDate! as Date).isWeekDay() == true) {
                        if (tempGoal.startDate! as Date).isFriday() == true {
                            repeatGoal = goalWeekendLater(goal: tempGoal)
                        } else {
                            repeatGoal = goalDayLater(goal: tempGoal)
                        }
                    } else {
                        repeatGoal = goalAtWeekday(goal: tempGoal)
                    }
                    CoreDataHelper.saveGoal()
                    tempGoal = repeatGoal
                }
            case "Weekends":
                while (tempGoal.endDate!.compare(repeatEndDate) != ComparisonResult.orderedDescending) {
                    var repeatGoal = tempGoal
                    if  ((tempGoal.startDate! as Date).isWeekend() == true) {
                        if (tempGoal.startDate! as Date).isSunday() == true {
                            repeatGoal = goalWeekdaysLater(goal: tempGoal)
                        } else {
                            repeatGoal = goalDayLater(goal: tempGoal)
                        }
                        
                    } else {
                        repeatGoal = goalAtWeekend(goal: tempGoal)
                    }
                    CoreDataHelper.saveGoal()
                    tempGoal = repeatGoal
                }
            case "Weekly":
                while tempGoal.endDate?.compare(repeatEndDate) != ComparisonResult.orderedDescending {
                    let repeatGoal = goalWeekLater(goal: tempGoal)
                    CoreDataHelper.saveGoal()
                    tempGoal = repeatGoal
                }
            case "Every Other Week":
                while tempGoal.endDate?.compare(repeatEndDate) != ComparisonResult.orderedDescending {
                    let repeatGoal = goalTwoWeekLater(goal: tempGoal)
                    CoreDataHelper.saveGoal()
                    tempGoal = repeatGoal
                }
            case "Monthly":
                while tempGoal.endDate?.compare(repeatEndDate) != ComparisonResult.orderedDescending {
                    let repeatGoal = goalMonthLater(goal: tempGoal)
                    CoreDataHelper.saveGoal()
                    tempGoal = repeatGoal
                }
                
        default:
            break
        }
    }
    
    func goalDayLater (goal: Goal) -> Goal {
        let newGoal = CoreDataHelper.newGoal()
        newGoal.title = goal.title
        newGoal.startDate = goal.startDate?.addingTimeInterval(60*60*24)
        newGoal.endDate = goal.endDate?.addingTimeInterval(60*60*24)
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        // insert reminders initialization here
        return newGoal
    }
    
    func goalWeekendLater (goal: Goal) -> Goal {
        let newGoal = CoreDataHelper.newGoal()
        newGoal.title = goal.title
        newGoal.startDate = goal.startDate?.addingTimeInterval(60*60*24*3)
        newGoal.endDate = goal.endDate?.addingTimeInterval(60*60*24*3)
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        // insert reminders initialization here
        return newGoal
    }
    
    func goalWeekdaysLater (goal: Goal) -> Goal {
        let newGoal = CoreDataHelper.newGoal()
        newGoal.title = goal.title
        newGoal.startDate = goal.startDate?.addingTimeInterval(60*60*24*6)
        newGoal.endDate = goal.endDate?.addingTimeInterval(60*60*24*6)
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        // insert reminders initialization here
        return newGoal
    }
    
    func goalWeekLater (goal: Goal) -> Goal{
        let newGoal = CoreDataHelper.newGoal()
        newGoal.title = goal.title
        newGoal.startDate = goal.startDate?.addingTimeInterval(60*60*24*7)
        newGoal.endDate = goal.endDate?.addingTimeInterval(60*60*24*7)
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        // insert reminders initialization here
        return newGoal
    }
    
    func goalTwoWeekLater (goal: Goal) -> Goal{
        let newGoal = CoreDataHelper.newGoal()
        newGoal.title = goal.title
        newGoal.startDate = goal.startDate?.addingTimeInterval(60*60*24*7*2)
        newGoal.endDate = goal.endDate?.addingTimeInterval(60*60*24*7*2)
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        // insert reminders initialization here
        return newGoal
    }
    
    func goalMonthLater (goal: Goal) -> Goal {
        let newGoal = CoreDataHelper.newGoal()
        newGoal.title = goal.title
        newGoal.startDate = Calendar.current.date(byAdding: .month, value: 1, to: (goal.startDate as Date?)!) as NSDate?
        newGoal.endDate = Calendar.current.date(byAdding: .month, value: 1, to: (goal.endDate as Date?)!) as NSDate?
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        // insert reminders initialization here
        return newGoal
    }
    
    func goalAtWeekday (goal: Goal) -> Goal {
        let newGoal = CoreDataHelper.newGoal()
        newGoal.title = goal.title
        newGoal.startDate = goal.startDate
        newGoal.endDate = goal.endDate
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        // insert reminders initialization here
        while (!((newGoal.startDate! as Date).isMonday())) {
            newGoal.startDate = newGoal.startDate!.addingTimeInterval(60*60*24)
            newGoal.endDate = newGoal.endDate!.addingTimeInterval(60*60*24)
        }
        return newGoal
    }
    
    func goalAtWeekend (goal:Goal) -> Goal {
        let newGoal = CoreDataHelper.newGoal()
        newGoal.title = goal.title
        newGoal.startDate = goal.startDate
        newGoal.endDate = goal.endDate
        newGoal.completionStatus = goal.completionStatus
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        // insert reminders initialization here
        while (!((newGoal.startDate! as Date).isSaturday())) {
            newGoal.startDate = newGoal.startDate!.addingTimeInterval(60*60*24)
            newGoal.endDate = newGoal.endDate!.addingTimeInterval(60*60*24)
        }
        return newGoal
    }
    
    @IBAction func cancelGoal(_ sender: UIBarButtonItem) {
        CoreDataHelper.delete(goal: newGoal)
        performSegue(withIdentifier: "unwindToCalendar", sender: nil)
        ViewController.todayReminders = []
    }
    
    func getColorPalette() -> ColorPalette {
        var colorSpecs: [ColorSpec] = []
        for color in colors {
            colorSpecs.append(ColorSpec(hex: "#\(color)", name: ""))
        }
        
        return ColorPalette(name: "rowColors", palette: colorSpecs)
    }
    
}

extension NewGoalController {
    func randomKeyGenerator() -> String {
        
        let letters : NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< 4 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
