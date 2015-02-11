//
//  TapToActView.swift
//  Remolet
//
//  Created by Liwei Zhang on 2015-02-11.
//  Copyright (c) 2015 Liwei Zhang. All rights reserved.
//

import Foundation
import UIKit

class TapToActView: UIView {
    var tapToActIsOn = true
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if let v = super.hitTest(point, withEvent: event) {
            if !self.hidden {
                if tapToActIsOn {
                    if !v.isKindOfClass(UITextView) {
                        self.endEditing(true)
                    }
                }
            }
            return v
        }
        return nil
    }
}