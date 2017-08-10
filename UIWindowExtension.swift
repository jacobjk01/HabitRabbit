//
//  UIWindowExtension.swift
//  HabitTrack
//
//  Created by Jacob Kim on 8/9/17.
//  Copyright © 2017 Jacob Kim. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    
    static var mainWindow: UIWindow? {
        return UIApplication.shared.keyWindow
    }
    
    func fadeInViewChanges(viewChanges:(Void) -> (Void)) {
        
        // snapshot current window
        let snapshot = self.snapshotView(afterScreenUpdates: false)
        self.addSubview(snapshot!)
        
        // make underneath changes
        viewChanges()
        
        // fade out snapshot
        UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseInOut, animations: {
            snapshot?.alpha = 0.0;
        }, completion: { finished in
            snapshot?.removeFromSuperview()
        })
    }
    
}
