//
//  NewGoalController.swift
//  HabitTrack
//
//  Created by Jacob Kim on 7/10/17.
//  Copyright © 2017 Jacob Kim. All rights reserved.
//

import Foundation
import UIKit

class NewGoalController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var repeatPicker: UIPickerView!
    @IBOutlet weak var groupPicker: UIPickerView!
    @IBOutlet weak var specifyStackView: UIStackView!
    @IBOutlet weak var specifyTextField: UITextField!
    
    var newGoal = CoreDataHelper.newGoal()
    let pickerData = ["none", "daily", "weekly", "monthly"]
    var groups = CoreDataHelper.retrieveGroups()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (groups.count == 0) {
            groups.append("other")
        } else if (groups[groups.count - 1] != "other") {
                groups.append("other")
        }
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
            newGoal.rerun = pickerData[row]
        } else if (groups[row] == "other") {
            specifyStackView.isHidden = false
            newGoal.group = specifyTextField.text
        } else {
            specifyStackView.isHidden = true
            newGoal.group = groups[row]
        }
        
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        if titleTextField.text != nil {
            newGoal.title = titleTextField.text
        }
        
        newGoal.startDate = startTimePicker.date as NSDate
        newGoal.endDate = endTimePicker.date as NSDate
        
        
        
        
        
    }
    @IBAction func infoButton(_ sender: Any) {
        
    }
    
    @IBAction func unwindToCalendar(_ segue: UIStoryboardSegue) {
        
    }
}
