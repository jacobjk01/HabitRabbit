//
//  NewGoalController.swift
//  HabitTrack
//
//  Created by Jacob Kim on 7/10/17.
//  Copyright © 2017 Jacob Kim. All rights reserved.
//

import Foundation
import UIKit

class NewGoalController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIPopoverPresentationControllerDelegate, ColorPickerDelegate {

    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var repeatPicker: UIPickerView!
    @IBOutlet weak var groupPicker: UIPickerView!
    @IBOutlet weak var specifyStackView: UIStackView!
    @IBOutlet weak var specifyTextField: UITextField!
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var changeColorButton: UIButton!
    @IBOutlet weak var colorChangeStackView: UIStackView!
    @IBOutlet weak var repeatEndDatePicker: UIDatePicker!
    
    
    var newGoal = CoreDataHelper.newGoal()
    var pickerData = ["none", "daily", "weekly", "monthly"]
    var groupDict = CoreDataHelper.retrieveGroupDict()
    var groups = Array(Set(CoreDataHelper.retrieveGroups()))
//    var groupColors = Array(Set(CoreDataHelper.retrieveGroupColors()))
    
    var selectedColor = UIColor.black
    var selectedColorHex = "FF0000"

    override func viewDidLoad() {
        super.viewDidLoad()
        if (groups.count) == 0 {
            groupDict = [:]
        }
        helpView.isHidden = true
        specifyStackView.isHidden = true
        colorChangeStackView.isHidden = true
        if (groups.count == 0) {
            groups.append("other")
            specifyStackView.isHidden = false
            colorChangeStackView.isHidden = false
        } else if groups[groups.count - 1] != "other" {
            groups.append("other")
        }
        startTimePicker.addTarget(self, action: #selector(NewGoalController.datePickerChanged), for: UIControlEvents.valueChanged)
        groupPicker.selectRow(0, inComponent:0, animated:true)
    }
    
    func datePickerChanged() {
        
        repeatPicker.selectRow(0, inComponent: 0, animated: true)
        endTimePicker.minimumDate = startTimePicker.date
        repeatEndDatePicker.minimumDate = endTimePicker.date
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 0) {
            return pickerData[row]
        } else {
            return groups[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 0) {
            return pickerData.count
        } else {
            return groups.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 0) {
            let calendar = NSCalendar.current
            
            // Replace the hour (time) of both dates with 00:00
            let date1 = calendar.startOfDay(for: startTimePicker.date)
            let date2 = calendar.startOfDay(for: endTimePicker.date)
            
            let day: Double = 60*60*24
            let timeLength = DateInterval(start: date1, end: date2)
            if timeLength.duration >= day && pickerData[row] == "daily" {
                pickerView.selectRow(0, inComponent: 0, animated: true)
            } else if timeLength.duration > (day * 7) && timeLength.duration <= day * 31 && pickerData[row] == "weekly" {
                pickerView.selectRow(0, inComponent: 0, animated: true)
            } else if timeLength.duration > (day*31) && pickerData[row] == "monthly"{
                pickerView.selectRow(0, inComponent: 0, animated: true)
            } else {
                newGoal.rerun = pickerData[row]
            }
            
        } else if groups[row] == "other" {
            specifyStackView.isHidden = false
            colorChangeStackView.isHidden = false
        } else {
            specifyStackView.isHidden = true
            colorChangeStackView.isHidden = true
            newGoal.group = groups[row]
            newGoal.groupColor = groupDict[newGoal.group!]
        }
    }
    
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        guard let title = titleTextField.text else { return }
        newGoal.title = titleTextField.text!
        
        newGoal.startDate = startTimePicker.date as NSDate
        newGoal.endDate = endTimePicker.date as NSDate
        
        if (!(countTextField.text?.isEmpty)!) {
            newGoal.count = Int32(countTextField.text!)!
        }
        
        if (!(specifyTextField.text!.isEmpty) && specifyStackView.isHidden == false) {
            newGoal.group = specifyTextField.text!
            newGoal.groupColor = selectedColorHex
            groupDict[newGoal.group!] = newGoal.groupColor
        }
        
        newGoal.repeatStatus = "original"
        
        // if the repeat is weekly add seven to each and continually create goals with same parameters until end of year
        // will also have to change delete to delete all of these events.
        
        var tempStart = newGoal.startDate
        var tempEnd = newGoal.endDate
        
        if (newGoal.rerun == "weekly") {
            while (tempStart?.compare(repeatEndDatePicker.date) == ComparisonResult.orderedAscending) {
                let repeatGoal = CoreDataHelper.newGoal()
                repeatGoal.startDate = tempStart?.addingTimeInterval(Double(60*60*24*7))
                repeatGoal.endDate = tempEnd?.addingTimeInterval(Double(60*60*24*7))
                repeatGoal.group = newGoal.group
                repeatGoal.count = newGoal.count
                repeatGoal.groupColor = newGoal.groupColor
                repeatGoal.repeatStatus = "copy"
                repeatGoal.title = newGoal.title
                tempStart = repeatGoal.startDate
                tempEnd = repeatGoal.endDate
                CoreDataHelper.saveGoal()
            }
        } else if (newGoal.rerun == "daily") {
            while (tempStart?.compare(repeatEndDatePicker.date) == ComparisonResult.orderedAscending) {
                let repeatGoal = CoreDataHelper.newGoal()
                repeatGoal.startDate = tempStart?.addingTimeInterval(Double(60*60*24))
                repeatGoal.endDate = tempEnd?.addingTimeInterval(Double(60*60*24))
                repeatGoal.group = newGoal.group
                repeatGoal.count = newGoal.count
                repeatGoal.groupColor = newGoal.groupColor
                repeatGoal.repeatStatus = "copy"
                repeatGoal.title = newGoal.title
                tempStart = repeatGoal.startDate
                tempEnd = repeatGoal.endDate
                CoreDataHelper.saveGoal()
            }
        } else if (newGoal.rerun == "monthly") {
            while (tempStart?.compare(repeatEndDatePicker.date) == ComparisonResult.orderedAscending) {
                let repeatGoal = CoreDataHelper.newGoal()
                
                //sketchy casting
                let startNextMonth = Calendar.current.date(byAdding: .month, value: 1, to: tempStart! as Date)
                let endNextMonth = Calendar.current.date(byAdding: .month, value: 1, to: tempEnd! as Date)
                
                repeatGoal.startDate = startNextMonth as NSDate?
                repeatGoal.endDate = endNextMonth! as NSDate
                repeatGoal.group = newGoal.group
                repeatGoal.count = newGoal.count
                repeatGoal.groupColor = newGoal.groupColor
                repeatGoal.repeatStatus = "copy"
                repeatGoal.title = newGoal.title
                tempStart = repeatGoal.startDate
                tempEnd = repeatGoal.endDate
                CoreDataHelper.saveGoal()
            }
        }
        
        CoreDataHelper.saveGoal()
    }
    @IBAction func infoButton(_ sender: UIButton) {
        helpView.layer.borderColor = UIColor.lightGray.cgColor
        helpView.layer.borderWidth = 1.5
        helpView.layer.cornerRadius = 6
        helpView.isHidden = false
    }
    
    @IBAction func helpViewResolved(_ sender: UIButton) {
        helpView.isHidden = true
    }
    
    @IBAction func cancelGoal(_ sender: UIButton) {
        CoreDataHelper.delete(goal: newGoal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Cancel" {
                print("Cancel button tapped")
            } else if identifier == "save" {
                print("Save button tapped")
            }
        }
    }
    
    // colorSelection Popover
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // show popover box for iPhone and iPad both
        return UIModalPresentationStyle.none
    }
    
    func colorPickerDidColorSelected(selectedUIColor: UIColor, selectedHexColor: String) {
        
        // update color value within class variable
        self.selectedColor = selectedUIColor
        self.selectedColorHex = selectedHexColor
        
        
        // set preview background to selected color
        changeColorButton.backgroundColor = selectedUIColor
    }
    
    private func showColorPicker(){
        
        // initialise color picker view controller
        let colorPickerVc = storyboard?.instantiateViewController(withIdentifier: "sbColorPicker") as! ColorPickerViewController
        
        // set modal presentation style
        colorPickerVc.modalPresentationStyle = .popover
        
        // set max. size
        colorPickerVc.preferredContentSize = CGSize(width:265, height: 400)
        
        // set color picker deleagate to current view controller
        // must write delegate method to handle selected color
        colorPickerVc.colorPickerDelegate = self
        
        // show popover
        if let popoverController = colorPickerVc.popoverPresentationController {
            
            // set source view
            popoverController.sourceView = changeColorButton
            
            // show popover form button
            popoverController.sourceRect = self.changeColorButton.bounds
            
            // show popover arrow at feasible direction
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.down
            
            // set popover delegate self
            popoverController.delegate = self
        }
        
        //show color popover
        present(colorPickerVc, animated: true, completion: nil)
    }
    
    @IBAction func changeColorButtonClicked(sender: UIButton) {
        self.showColorPicker()
    }
}
