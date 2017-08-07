//
//  GoalCell.swift
//  HabitTrack
//
//  Created by Jacob Kim on 7/13/17.
//  Copyright © 2017 Jacob Kim. All rights reserved.
//

import Foundation
import UIKit
import SwipeCellKit

class GoalCell: SwipeTableViewCell {
    
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var groupColorBox: UIView!
    @IBOutlet weak var divisionLine: UIView!
    @IBOutlet weak var arrowPicture: UIImageView!
}
