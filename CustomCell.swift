//
//  ViewCell.swift
//  HabitTrack
//
//  Created by Jacob Kim on 7/10/17.
//  Copyright © 2017 Jacob Kim. All rights reserved.
//

import Foundation
import UIKit
import JTAppleCalendar

class CustomCell: JTAppleCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
  
    var dayGoals = [Goal]()
    var lineView = LineView(frame: CGRect(x: 3, y: 48, width: 48, height: 7))

}
