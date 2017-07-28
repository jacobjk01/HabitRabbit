//
//  TestViewController.swift
//  JTAppleCalendar iOS
//
//  Created by Jeron Thomas on 2017-07-11.
//

import UIKit
import JTAppleCalendar

class TestViewController: UIViewController {
    @IBOutlet var calendarView: JTAppleCalendarView!
    @IBOutlet var theView: UIView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func reloadData(_ sender:UIButton) {
        
        for _ in 0...100000 {
            calendarView.reloadData()
        }
        print("DONE")
    }
    @IBAction func zeroHeight(_ sender: UIButton) {
        let frame = calendarView.frame
        calendarView.frame = CGRect(x: frame.origin.x,
                                    y: frame.origin.y,
                                    width: frame.width,
                                    height: 0)
        calendarView.reloadData()
    }
    @IBAction func twoHeight(_ sender: UIButton) {
        let frame = calendarView.frame
        calendarView.frame = CGRect(x: frame.origin.x,
                                    y: frame.origin.y,
                                    width: frame.width,
                                    height: 50)
        calendarView.reloadData()
    }
    @IBAction func twoHundredHeight(_ sender: UIButton) {
        let frame = calendarView.frame
        calendarView.frame = CGRect(x: frame.origin.x,
                                    y: frame.origin.y,
                                    width: frame.width,
                                    height: 200)
        calendarView.reloadData()
    }
    
    @IBAction func zeroHeightView(_ sender: UIButton) {
        viewHeightConstraint.constant = 0
        runThis()

    }
    @IBAction func twoHeightView(_ sender: UIButton) {
        viewHeightConstraint.constant = 50
        runThis()
    }
    @IBAction func twoHundredHeightView(_ sender: UIButton) {
        viewHeightConstraint.constant = 200
        runThis()
    }
    
    func runThis() {
        calendarView.reloadData()
    }
}


extension TestViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "cell", for: indexPath) as! CellView
        cell.dayLabel .text = cellState.text
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2018 02 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate,endDate: endDate)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        print(date)
    }
}

