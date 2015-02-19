//
//  VerticalScrollSwitchView.swift
//  Remolet
//
//  Created by Liwei Zhang on 2015-02-02.
//  Copyright (c) 2015 Liwei Zhang. All rights reserved.
//

import Foundation
import UIKit


class VerticalScrollSwitchView: UIScrollView, UIScrollViewDelegate {
    var userTriggered = true
    // basePositionY is always the second upper stop.
    var basePositionY: CGFloat = 0 {
        didSet {
            if userTriggered {
                NSNotificationCenter.defaultCenter().postNotificationName("verticalStopChangedByUserScrolling", object: self)
            }
        }
    }
    var targetPositionY: CGFloat = 0
    var dragStartPointY: CGFloat = 0
    var stops = [CGFloat]()
    // All subviews between any two adjacent stops are attached on a master UIView, called viewSet. All master UIViews are in the viewSets.
    
    var allStops: [CGFloat] {
        get {
            return getAllStops(stops, 0, contentSize.height)
        }
    }
    var viewToForwardTouch: UIView!
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        dragStartPointY = scrollView.contentOffset.y
    }
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetPositionY = targetContentOffset.memory.y
        targetContentOffset.memory.y = getNextStop(allStops, dragStartPointY, scrollView.contentOffset.y, targetPositionY, basePositionY)
        println("target: \(targetContentOffset.memory.y)")
        userTriggered = true
        basePositionY = targetContentOffset.memory.y
        println("base: \(basePositionY)")
    }
}


class ViewSet: UIView, UITextViewDelegate {
    var input: TextInput!
    var inputPlaceholder: UILabel!
    var highlightColor: UIColor = UIColor.grayColor()
    var dehighlightColor: UIColor = UIColor.blueColor()
    var characterLimit: Int = 0
    var characterCount: Int {
        get {
            return count(input!.text)
        }
    }
    var characterAvailable: Int {
        get {
            return characterCount >= characterLimit ? 0 : characterLimit - characterCount
        }
    }
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                inputPlaceholder.hidden = true
                input.backgroundColor = highlightColor
                if self.input.isFirstResponder() {
                    NSNotificationCenter.defaultCenter().postNotificationName("viewSetSelected", object: self)
                } else {
                    self.input.becomeFirstResponder()
                }
                
            } else {
                self.endEditing(true)
                inputPlaceholder.hidden = false
                input.backgroundColor = dehighlightColor
            }
        }
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        input = TextInput(frame: CGRectMake(gapM, gapM, self.frame.width - gapM * twoCGFloat, self.frame.height - gapM * twoCGFloat))
        input.delegate = self
        inputPlaceholder = UILabel(frame: input!.frame)
        self.addSubview(input!)
        self.addSubview(inputPlaceholder!)
    }
    // <UITextViewDelegate>
    func textViewDidBeginEditing(textView: UITextView) {
        // Show character count / hide placeholder / highlight view
        isSelected = true
        NSNotificationCenter.defaultCenter().postNotificationName("updateTextCount", object: self)
    }
    func textViewDidChange(textView: UITextView) {
        NSNotificationCenter.defaultCenter().postNotificationName("updateTextCount", object: self)
    }
    func textViewDidEndEditing(textView: UITextView) {
        isSelected = false
    }
}

class TextInput: UITextView {
    var lengthThreshold: Int = 999999
    var normalTextColor = UIColor.blackColor()
    var cutTextColor = UIColor.grayColor()
    override var attributedText: NSAttributedString! {
        didSet {
            var a = NSMutableAttributedString(string: attributedText.string)
            if attributedText.length <= lengthThreshold {
                a.addAttribute(NSForegroundColorAttributeName, value: normalTextColor, range: NSMakeRange(0, attributedText.length))
            } else {
                a.addAttribute(NSForegroundColorAttributeName, value: normalTextColor, range: NSMakeRange(0, lengthThreshold - 1))
                a.addAttribute(NSForegroundColorAttributeName, value: cutTextColor, range: NSMakeRange(lengthThreshold, attributedText.length - lengthThreshold))
            }
            attributedText = a
        }
    }
}

class textCounterDisplay: UILabel {
    var textLimit: Int = 0
    var textLength: Int = 0
    var normalTextColor = UIColor.grayColor()
    var exceededTextColor = UIColor.blackColor()
    override var attributedText: NSAttributedString! {
        didSet {
            var a = NSMutableAttributedString(string: attributedText.string)
            if textLength <= textLimit {
                a.addAttribute(NSForegroundColorAttributeName, value: normalTextColor, range: NSMakeRange(0, attributedText.length))
            } else {
                let p = 3 + Int(floor(Double(textLimit) / Double(100)))
                a.addAttribute(NSForegroundColorAttributeName, value: normalTextColor, range: NSMakeRange(0, attributedText.length - p))
                a.addAttribute(NSForegroundColorAttributeName, value: exceededTextColor, range: NSMakeRange(attributedText.length - p, p))
            }
            attributedText = a
        }
    }
}

// MARK: - Stops operation

/*
two senarioes:
1. drag and stop at a precise point: the moving direction is just the stop point from the start point, and just to determine if the position is beyond 1/2 of the distance. If yes, go to the next stop. If no, bo back to the starting point.
2. drag and stop with momentum, such as swipe: we could take the deceleration distance into account. Then the dragging distance with part of deceleration distance will be the best metric to determine which stop to go, starting one or the next one.
*/

// 1. initial "page" position for determining the two potential adjacent pages
// 2. point to determine which direction to go
// the 2nd point
// direction is determined by drag end point and initial target deceleration point
// If targetPosition == startPosition, which means no decelaration, set start as the startPositoin
func getNextStop(allStops: [CGFloat], dragStartOffsetY: CGFloat, dragEndOffsetY: CGFloat, targetOffsetY: CGFloat, baseOffsetY: CGFloat) -> CGFloat {
    let r = getUpDownStops(allStops, baseOffsetY)
    var upDistance: CGFloat = -1
    var downDistance: CGFloat = -1
    if r.up >= 0 {
        upDistance = baseOffsetY - r.up
    }
    if r.down >= 0 {
        downDistance = r.down - baseOffsetY
    }
    var detectedDistance: CGFloat
    println("dragEndOffsetY: \(dragEndOffsetY)")
    // Use targetOffsetY - dragEndOffsetY as indicator for swipe direction and distance is good untill there is no further place to swipe, such as both vertical ends, which lead back to the edge points instead of going further. To resolve this, we provide extra space on both ends to let the targetOffsetY / dragEndOffsetY detection work again for direction indication.
    if targetOffsetY != dragEndOffsetY {
        detectedDistance = targetOffsetY - dragEndOffsetY
    } else {
        detectedDistance = dragEndOffsetY - baseOffsetY
    }
    if detectedDistance >= downDistance / 2 && downDistance >= 0 && allStops[allStops.count - 3] != baseOffsetY {
        // ContentOffset becomes larger, view moves upwards, go to stop below
        return r.down
    }
    if detectedDistance < -upDistance / 2 && upDistance >= 0 && allStops[1] != baseOffsetY {
        // ContentOffset becomes smaller, view moves downwards, go to stop above
        return r.up
    }
    return baseOffsetY
}

func getUpDownStops(allStops: [CGFloat], basePositionY: CGFloat) -> (up: CGFloat, down: CGFloat) {
    var up: CGFloat = -1
    var down: CGFloat = -1
    if let f = find(allStops, basePositionY) {
        if f == 0 {
            down = allStops[f + 1]
        } else if f == allStops.count - 1 {
            up = allStops[f - 1]
        } else {
            down = allStops[f + 1]
            up = allStops[f - 1]
        }
    }
    return (up, down)
}

func getAllStops(stops: [CGFloat], topStop: CGFloat, bottomStop: CGFloat) -> [CGFloat] {
    var allStops = [topStop]
    for f in stops {
        allStops.append(f)
    }
    allStops.append(bottomStop)
    return allStops
}

func getViewSetBetweenStops(allStops: [CGFloat], baseY: CGFloat, viewSets: [UIView]) -> UIView? {
    let r = getUpDownStops(allStops, baseY)
    for u in viewSets {
        if u.frame.origin.y >= baseY && CGRectGetMaxY(u.frame) >= r.down {
            return u
        }
    }
    return nil
}