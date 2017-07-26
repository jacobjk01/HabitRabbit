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

class NewGoalController:  FormViewController {
    
    var newGoal = CoreDataHelper.newGoal()
    var groupDict = CoreDataHelper.retrieveGroupDict()
    var groups = Array(Set(CoreDataHelper.retrieveGroups()))

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
        +++ Section("Date")
            <<< DateInlineRow("Start Date") {
                $0.title = $0.tag
                $0.value = Date()
            }.onChange({ (DateInlineRow) in
                let endDateRow: DateInlineRow = self.form.rowBy(tag: "End Date")!
                if endDateRow.value?.compare(DateInlineRow.value!) == ComparisonResult.orderedAscending {
                    DateInlineRow.value = endDateRow.value
                    DateInlineRow.updateCell()
                }
            })
            <<< DateInlineRow("End Date") {
                $0.title = $0.tag
                $0.value = Date()
            }.onChange({ (DateInlineRow) in
                let startDateRow: DateInlineRow = self.form.rowBy(tag: "Start Date")!
                if startDateRow.value?.compare(DateInlineRow.value!) == ComparisonResult.orderedDescending {
                    DateInlineRow.value = startDateRow.value
                    DateInlineRow.updateCell()
                }
            })
        +++ Section(header: "Count", footer: "Count refers to how many times you want to complete your goal in your selected duration. For example, you could indicate that you want to work out three times in this week")
            <<< PushRow<String>("Count Duration") {
                $0.title = $0.tag
                $0.value = "Total"
                $0.selectorTitle = "Select a Duration"
                $0.options = ["Daily", "Weekly", "Monthly", "Total"]
                let ruleRequiredViaClosure = RuleClosure<String> { rowValue in
                    return (rowValue == nil || rowValue!.isEmpty) ? ValidationError(msg: "Field required!") : nil
                }
                $0.add(rule: ruleRequiredViaClosure)
                $0.validationOptions = .validatesOnChange
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .red
                }
            }
            <<< IntRow("Count") {
                $0.title = $0.tag
                $0.value = 1
            }
        +++ Section("Repeat")
            <<< PushRow<String>("Repeat Interval") {
                $0.title = $0.tag
                $0.value = "None"
                $0.selectorTitle = "Select a Repeat Interval"
                $0.options = ["None", "Daily", "Weekdays", "Weekends", "Weekly", "Every Other Week", "Monthly"]
                let ruleRequiredViaClosure = RuleClosure<String> { rowValue in
                    return (rowValue == nil || rowValue!.isEmpty) ? ValidationError(msg: "Field required!") : nil
                }
                $0.add(rule: ruleRequiredViaClosure)
                $0.validationOptions = .validatesOnChange
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .red
                }
            }
            <<< PushRow<String>("Repeat End Date") {
                $0.title = $0.tag
                $0.value = "One Week Later"
                $0.selectorTitle = "Select a Repeat End"
                $0.options = ["One Week Later", "One Month Later", "Six Months Later", "One Year Later", "Custom..."]
                $0.hidden = Condition.function(["Repeat Interval"], { form in
                    return !((form.rowBy(tag: "Repeat Interval") as? PushRow)?.value != "None")
                })
            }
            <<< DateInlineRow("Custom Repeat End Date") {
                $0.title = $0.tag
                $0.value = Date()
                $0.hidden = Condition.function(["Repeat End Date"], { form in
                    return !((form.rowBy(tag: "Repeat End Date") as? PushRow)?.value == "Custom...")
                })
            }
        +++ Section("Groups")
            <<< PushRow<String> ("Group"){
                $0.title = $0.tag
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
            }
            
            <<< TextRow("New Group Name") { row in
                row.title = "New Group Name"
                row.value = ""
                row.placeholder = "Goal Category"
                row.hidden = Condition.function(["Group"], { form in
                    return !((form.rowBy(tag: "Group") as? PushRow)?.value == "New...")
                })
                
            }
            
            <<< ColorPickerRow("New Group Color") { row in
                row.title = "New Group Color"
                row.value = UIColor.blue
                row.isCircular = true
                row.showsPaletteNames = false
                row.showsCurrentSwatch = true
                row.hidden = Condition.function(["Group"], { form in
                    return !((form.rowBy(tag: "Group") as? PushRow)?.value == "New...")
                })
            }
            
            +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], header: "Reminders") {
                $0.addButtonProvider = { section in
                    return ButtonRow(){
                        $0.title = "Add New Reminder"
                    }
                }
                $0.multivaluedRowToInsertAt = { index in
                    return TimeRow() {
                        let gregorian = Calendar(identifier: .gregorian)
                        let now = Date()
                        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
                        
                        components.hour = 12
                        components.minute = 00
                        components.second = 00
                        
                        let defaultTime = gregorian.date(from: components)!
                        $0.value = defaultTime
                        $0.title = "Reminder:"
                    }
                }
            }

        +++ Section("Submit")
            <<< ButtonRow ("Save") {
                $0.title = $0.tag
            }.onCellSelection({ (cell, row) in
                let formValues = self.form.values()
                
                self.newGoal.title = formValues["Title"] as? String
                
                self.newGoal.startDate = formValues["Start Date"] as? NSDate
                self.newGoal.endDate = formValues["End Date"] as? NSDate
                
                self.newGoal.countDuration = formValues["Count Duration"] as? String
                self.newGoal.count = Int64(formValues["Count"] as! Int)
                
                self.newGoal.repeatStatus = "original"
                
                let group = formValues["Group"] as? String
                if group != "New..." {
                    self.newGoal.group = group
                    self.newGoal.groupColor = self.groupDict[group!]
                } else {
                    self.newGoal.group = formValues["New Group Name"] as? String
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
                self.performSegue(withIdentifier: "unwindToCalendar", sender: nil)
                CoreDataHelper.saveGoal()
            })
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
        newGoal.countDuration = goal.countDuration
        newGoal.count = goal.count
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        newGoal.repeatStatus = "copy"
        // insert reminders initialization here
        return newGoal
    }
    
    func goalWeekendLater (goal: Goal) -> Goal {
        let newGoal = CoreDataHelper.newGoal()
        newGoal.title = goal.title
        newGoal.startDate = goal.startDate?.addingTimeInterval(60*60*24*3)
        newGoal.endDate = goal.endDate?.addingTimeInterval(60*60*24*3)
        newGoal.countDuration = goal.countDuration
        newGoal.count = goal.count
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        newGoal.repeatStatus = "copy"
        // insert reminders initialization here
        return newGoal
    }
    
    func goalWeekdaysLater (goal: Goal) -> Goal {
        let newGoal = CoreDataHelper.newGoal()
        newGoal.title = goal.title
        newGoal.startDate = goal.startDate?.addingTimeInterval(60*60*24*6)
        newGoal.endDate = goal.endDate?.addingTimeInterval(60*60*24*6)
        newGoal.countDuration = goal.countDuration
        newGoal.count = goal.count
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        newGoal.repeatStatus = "copy"
        // insert reminders initialization here
        return newGoal
    }
    
    func goalWeekLater (goal: Goal) -> Goal{
        let newGoal = CoreDataHelper.newGoal()
        newGoal.title = goal.title
        newGoal.startDate = goal.startDate?.addingTimeInterval(60*60*24*7)
        newGoal.endDate = goal.endDate?.addingTimeInterval(60*60*24*7)
        newGoal.countDuration = goal.countDuration
        newGoal.count = goal.count
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        newGoal.repeatStatus = "copy"
        // insert reminders initialization here
        return newGoal
    }
    
    func goalTwoWeekLater (goal: Goal) -> Goal{
        let newGoal = CoreDataHelper.newGoal()
        newGoal.title = goal.title
        newGoal.startDate = goal.startDate?.addingTimeInterval(60*60*24*7*2)
        newGoal.endDate = goal.endDate?.addingTimeInterval(60*60*24*7*2)
        newGoal.countDuration = goal.countDuration
        newGoal.count = goal.count
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        newGoal.repeatStatus = "copy"
        // insert reminders initialization here
        return newGoal
    }
    
    func goalMonthLater (goal: Goal) -> Goal {
        let newGoal = CoreDataHelper.newGoal()
        newGoal.title = goal.title
        newGoal.startDate = Calendar.current.date(byAdding: .month, value: 1, to: (goal.startDate as Date?)!) as NSDate?
        newGoal.endDate = Calendar.current.date(byAdding: .month, value: 1, to: (goal.endDate as Date?)!) as NSDate?
        newGoal.countDuration = goal.countDuration
        newGoal.count = goal.count
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        newGoal.repeatStatus = "copy"
        // insert reminders initialization here
        return newGoal
    }
    
    func goalAtWeekday (goal: Goal) -> Goal {
        let newGoal = CoreDataHelper.newGoal()
        newGoal.title = goal.title
        newGoal.startDate = goal.startDate
        newGoal.endDate = goal.endDate
        newGoal.countDuration = goal.countDuration
        newGoal.count = goal.count
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        newGoal.repeatStatus = "copy"
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
        newGoal.countDuration = goal.countDuration
        newGoal.count = goal.count
        newGoal.group = goal.group
        newGoal.groupColor = goal.groupColor
        newGoal.repeatStatus = "copy"
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
    }
    
}
