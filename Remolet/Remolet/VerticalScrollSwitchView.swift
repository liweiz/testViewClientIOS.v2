//
//  VerticalScrollSwitchView.swift
//  Remolet
//
//  Created by Liwei Zhang on 2015-02-02.
//  Copyright (c) 2015 Liwei Zhang. All rights reserved.
//

import Foundation
import UIKit

class inputViewCtl: UIViewController {
    var base: VerticalScrollSwitchView!
    var target, translation, detail, context: ViewSet!
    var fontUsed: UIFont!
    override func loadView() {
        view = UIView(frame: appRectZero)
        base = VerticalScrollSwitchView(frame: view.frame)
        let w = view.frame.width
        let h = view.frame.height
        target = ViewSet(frame: CGRectMake(zeroCGFloat, zeroCGFloat, w, getViewSetHeight(1)))
        translation = ViewSet(frame: CGRectMake(zeroCGFloat, CGRectGetMaxY(target.frame), w, getViewSetHeight(1)))
        context = ViewSet(frame: CGRectMake(zeroCGFloat, CGRectGetMaxY(translation.frame), w, getViewSetHeight(3)))
        detail = ViewSet(frame: CGRectMake(zeroCGFloat, CGRectGetMaxY(context.frame), w, getViewSetHeight(3)))
        // Make sure the height is tall enough to show last input on top of the screen.
        base.contentSize = CGSizeMake(base.frame.width, CGRectGetMinY(detail.frame) + appRect.height)
        base.stops = [CGRectGetMaxY(target.frame), CGRectGetMaxY(translation.frame), CGRectGetMaxY(context.frame)]
        base.viewSets = [target, translation, context, detail]
        base.addSubview(target)
        base.addSubview(translation)
        base.addSubview(context)
        base.addSubview(detail)
        view.addSubview(base)
        target.inputPlaceholder.text = "Word(s)"
        translation.inputPlaceholder.text = "Translation"
        context.inputPlaceholder.text = "Example"
        detail.inputPlaceholder.text = "Detailed explanation"
    }
    func getViewSetHeight(lineNo: CGFloat) -> CGFloat {
        return gapM * twoCGFloat + fontUsed.lineHeight * lineNo
    }
}

class VerticalScrollSwitchView: UIScrollView, UIScrollViewDelegate {
    // basePositionY is always the upper stop.
    var basePositionY: CGFloat = 0
    var targetPositionY: CGFloat = 0
    var dragStartPointY: CGFloat = 0
    var stops = [CGFloat]()
    // All subviews between any two adjacent stops are attached on a master UIView, called viewSet. All master UIViews are in the viewSets.
    var viewSets = [UIView]()
    var allStops: [CGFloat] {
        get {
            return getAllStops(stops, 0, contentSize.height)
        }
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        dragStartPointY = scrollView.contentOffset.y
    }
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetPositionY = targetContentOffset.memory.y
        targetContentOffset.memory.y = getNextStop(allStops, dragStartPointY, scrollView.contentOffset.y, targetPositionY, basePositionY)
        basePositionY = targetContentOffset.memory.y
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if let u = getViewSetBetweenStops(allStops, basePositionY, viewSets) {
            
        }
    }
}

class ViewSet: UIView, UITextViewDelegate {
    var input: TextInput!
    var inputPlaceholder: UILabel!
    var highlightColor: UIColor = UIColor.blackColor()
    var dehighlightColor: UIColor = UIColor.blackColor()
    var characterLimit: Int = 0
    var characterCount: Int {
        get {
            return countElements(input!.text)
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
                NSNotificationCenter.defaultCenter().postNotificationName("viewSetSelected", object: self)
            } else {
                inputPlaceholder.hidden = false
                input.backgroundColor = dehighlightColor
                NSNotificationCenter.defaultCenter().postNotificationName("viewSetDeselected", object: self)
            }
        }
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        input = TextInput(frame: CGRectMake(gapM, gapM, self.frame.width - gapM * twoCGFloat, self.frame.height - gapM * twoCGFloat))
        inputPlaceholder = UILabel(frame: input!.frame)
        self.addSubview(inputPlaceholder!)
        self.addSubview(input!)
    }
    // <UITextViewDelegate>
    func textViewDidBeginEditing(textView: UITextView) {
        // Show character count / hide placeholder / highlight view
        NSNotificationCenter.defaultCenter().postNotificationName("editBegin", object: self)
        NSNotificationCenter.defaultCenter().postNotificationName("updateTextCount", object: self)
    }
    func textViewDidChange(textView: UITextView) {
        NSNotificationCenter.defaultCenter().postNotificationName("updateTextCount", object: self)
    }
    func textViewDidEndEditing(textView: UITextView) {
        NSNotificationCenter.defaultCenter().postNotificationName("editEnd", object: self)
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
func getNextStop(allStops: [CGFloat], dragStartY: CGFloat, dragEndY: CGFloat, targetY: CGFloat, baseY: CGFloat) -> CGFloat {
    let r = getUpDownStops(allStops, baseY)
    var upDistance: CGFloat = -1
    var downDistance: CGFloat = -1
    if r.up >= 0 {
        upDistance = baseY - r.up
    }
    if r.down >= 0 {
        downDistance = r.down - baseY
    }
    var detectedDistance: CGFloat
    if targetY != dragEndY {
        detectedDistance = targetY - dragEndY
    } else {
        detectedDistance = dragEndY - dragStartY
    }
    if detectedDistance >= upDistance / 2 && upDistance >= 0 && allStops[allStops.count - 2] != baseY {
        // ContentOffset becomes larger, view moves upwards, go to stop below
        return r.down
    }
    if detectedDistance <= -downDistance / 2 && downDistance >= 0 && allStops[0] != baseY {
        // ContentOffset becomes smaller, view moves downwards, go to stop above
        return r.up
    }
    return baseY
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