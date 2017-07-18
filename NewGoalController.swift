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
    
    var newGoal = CoreDataHelper.newGoal()
    let pickerData = ["none", "daily", "weekly", "monthly"]
    var groupDict = CoreDataHelper.retrieveGroupDict()
    var groups = CoreDataHelper.retrieveGroups()
//    var groupColors = Array(Set(CoreDataHelper.retrieveGroupColors()))
    
    var currentGroup = ""
    var currentGroupColor = ""
    
    var selectedColor = UIColor.red
    var selectedColorHex = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        helpView.isHidden = true
        specifyStackView.isHidden = true
        colorChangeStackView.isHidden = true
        if (groupDict.count == 0) {
            groupDict["other"] = ""
            specifyStackView.isHidden = false
            colorChangeStackView.isHidden = false
        } else if groupDict["other"] == nil {
            groupDict["other"] = ""
        }
        startTimePicker.addTarget(self, action: #selector(NewGoalController.datePickerChanged), for: UIControlEvents.valueChanged)
        groupPicker.selectRow(0, inComponent:0, animated:true)
    }
    
    func datePickerChanged() {
        endTimePicker.minimumDate = startTimePicker.date
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
        if titleTextField.text != nil {
            newGoal.title = titleTextField.text!
            //print(newGoal.title)
        }
       
        
        newGoal.startDate = startTimePicker.date as NSDate
        //print(newGoal.startDate)
        newGoal.endDate = endTimePicker.date as NSDate
        //print(newGoal.endDate)
        
        
        if (!(countTextField.text?.isEmpty)!) {
            newGoal.count = Int32(countTextField.text!)!
        }
        
        //print(newGoal.rerun)
        
        if (!(specifyTextField.text!.isEmpty) && specifyStackView.isHidden == false) {
            newGoal.group = specifyTextField.text!
            newGoal.groupColor = selectedColorHex
            groupDict[newGoal.group!] = newGoal.groupColor
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "cancel" {
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
