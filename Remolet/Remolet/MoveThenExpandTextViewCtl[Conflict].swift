//
//  MoveThenExpandTextViewCtl.swift
//  Remolet
//
//  Created by Liwei Zhang on 2015-02-23.
//  Copyright (c) 2015 Liwei Zhang. All rights reserved.
//

import Foundation
import UIKit

/*

Config and animation steps:
1. Initialize a singleLine textView to hold all the text.
2. Assign calculated origin to have the text we need aligned with a given point.
3.
*/

var s: NSLayoutManager? = nil


class MoveThenExpandTextViewCtl: UIViewController {
    var fullContent: NSString!
    var fullContentStorage: NSTextStorage {
        get {
            return NSTextStorage(string: fullContent as String)
        }
    }
    var text: NSString! // Mismatched text (text not in fullContent), should be handled before use this ctl.
    var base: MoveThenExpandTextView!
    var rectToShowOn: CGRect!
    var textStartFromLeft = true
    
    var textViewToShow: TextView!
    var textViewHidden: TextView!
    // Process to position textViewToShow: initialGlyphBeginPointInRect => initialGlyphBeginPointInBase => adjustTextViewOriginToMatch
    var initialGlyphBeginPointInRect: CGPoint!
    var initialViewOriginInBase: CGPoint!
    var initialBaseContentOffset: CGPoint!
    var initialGlyphBeginPointInBase: CGPoint {
        get {
            return CGPointMake(initialBaseContentOffset.x + initialGlyphBeginPointInRect.x, initialBaseContentOffset.y + initialGlyphBeginPointInRect.y)
        }
    }
    var shownGap = CGFloat(10)
    var verticalRatio = CGFloat(0.4)
    var shownPoint: CGPoint {
        get {
            // Have to be the same as the textViewToShow since difference in its padding and inset would change the size.
            var tempView = TextView(gap: shownGap, inParentRect: CGRectMake(0, 0, base.frame.width, base.frame.height), noInset: true, container: MoveThenExpandTextContainer(isHidden: false, size: CGSizeMake(base.frame.width, base.frame.height)))
            tempView.textContainer.heightTracksTextView = true
            tempView.text = fullContent as String
            tempView.textAlignment = NSTextAlignment.Natural
            return CGPointMake(shownGap, base.frame.size.height * verticalRatio - tempView.frame.height / 2)
        }
    }
    var layoutMgr: TwoColumnLayoutMgr!
    override func loadView() {
        initialBaseContentOffset = CGPointMake(rectToShowOn.width, rectToShowOn.height)
        layoutMgr = TwoColumnLayoutMgr(showSize: CGSizeMake(rectToShowOn.width, rectToShowOn.height), hiddenSize: CGSizeMake(1700, rectToShowOn.height), textToBeShown: text)
        fullContentStorage.addLayoutManager(layoutMgr)
        view = UIView(frame: rectToShowOn)
        view.backgroundColor = UIColor.purpleColor()
        base = MoveThenExpandTextView(frame: CGRectMake(0, 0, rectToShowOn.width, rectToShowOn.height))
        // Make it large enough in all directions to
        base.contentSize = CGSizeMake(base.frame.width * 3, base.frame.height * 3)
        base.contentOffset = CGPointMake(base.frame.width, base.frame.height)
        base.backgroundColor = UIColor.grayColor()
        // textViews
        if let preceedingText = layoutMgr.preceedingText {
            base.initialTextHiddenWidth = fittedTextViewWidth(preceedingText, CGRectMake(0, 0, 1700, base.frame.height), layoutMgr.textContainerHidden)
        } else {
            base.initialTextHiddenWidth = 0
        }
        textViewHidden = TextView(gap: 0, inParentRect: CGRectMake(0, 0, base.initialTextHiddenWidth, base.frame.height), noInset: true, container: layoutMgr.textContainerHidden)
        textViewToShow = TextView(gap: shownGap, inParentRect: CGRectMake(base.frame.width, base.frame.height, base.frame.width, base.frame.height), noInset: true, container: layoutMgr.textContainerToShow)
        textViewToShow.backgroundColor = UIColor.clearColor()
        adjustTextViewOriginToMatch(initialGlyphBeginPointInBase, view: textViewToShow)
        initialViewOriginInBase = textViewToShow.frame.origin
//        base.userInteractionEnabled = false
        view.addSubview(base)
        base.addSubview(textViewHidden)
        base.addSubview(textViewToShow)
        base.initialContentOffset = initialBaseContentOffset
        base.contentOffset = initialBaseContentOffset
        base.textViewToShow = textViewToShow
        base.textViewHidden = textViewHidden
        base.initialViewOrigin = textViewToShow.frame.origin
        base.shownViewOrigin = shownPoint
        base.initialTextHiddenWidth = textViewHidden.frame.width
//        self.view.setNeedsDisplay()
//        base.moveAwayFromInitialPoint()
    }
    func adjustTextViewOriginToMatch(glyphPointInBase: CGPoint, view: TextView) {
        view.frame = CGRectMake(glyphPointInBase.x - (view.textContainerInset.left + view.textContainer.lineFragmentPadding), glyphPointInBase.y - view.textContainerInset.top, view.frame.width, view.frame.height)
    }
}

class MoveThenExpandTextView: UIScrollView {
    var initialContentOffset: CGPoint! // Given by ctl
    var textViewToShow: UITextView! // Given by ctl
    var textViewHidden: UITextView! // Given by ctl
    
    var initialViewOrigin: CGPoint! // Given by ctl
    var shownViewOrigin: CGPoint! // Given by ctl
    
    var initialTextHiddenWidth: CGFloat! // Given by ctl
    var xDistance: CGFloat {
        get {
            return abs(initialViewOrigin.x - shownViewOrigin.x)
        }
    }
    var yDistance: CGFloat {
        get {
            return abs(initialViewOrigin.y - shownViewOrigin.y)
        }
    }
    var targetContentOffset:CGPoint {
        get {
            return CGPointMake(initialContentOffset.x + shownViewOrigin.x - initialViewOrigin.x, initialContentOffset.y + shownViewOrigin.y - initialViewOrigin.y)
        }
    }
    override func layoutSubviews() {
        textViewHidden.frame = CGRectMake(textViewHidden.frame.origin.x, textViewHidden.frame.origin.y, abs(contentOffset.y - initialContentOffset.y) / yDistance * initialTextHiddenWidth, textViewHidden.frame.height)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    func moveAwayFromInitialPoint() {
        setContentOffset(targetContentOffset, animated: true)
    }
    func moveBackToInitialPoint() {
        setContentOffset(initialContentOffset, animated: true)
    }
}



class TwoColumnLayoutMgr: NSLayoutManager {
    var textContainerToShow: MoveThenExpandTextContainer!
    var textContainerHidden: MoveThenExpandTextContainer!
    convenience init(showSize: CGSize, hiddenSize: CGSize, textToBeShown: NSString) {
        self.init()
        textContainerHidden = MoveThenExpandTextContainer(isHidden: true, size: hiddenSize)
        textContainerToShow = MoveThenExpandTextContainer(isHidden: false, size: showSize)
        self.addTextContainer(textContainerToShow)
        self.addTextContainer(textContainerHidden)
        textToShow = textToBeShown
    }
    var textToShow: NSString! // NSLayoutManager works only with NSRange. It's easier to get NSRange from NSString instead of Range<String.Index> (http://stackoverflow.com/questions/27040924/nsrange-from-swift-range)
    var textRange: NSRange? {
        get {
            if let t = textStorage { return (t.string as NSString).rangeOfString(textToShow as! String) }
            return nil
        }
    }
    var textGlyphRange: NSRange? {
        get {
            if let r = textRange {
                return glyphRangeForCharacterRange(r, actualCharacterRange: nil)
            }
            return nil
        }
    }
    var preceedingTextRange: NSRange? {
        get {
            if let r = textRange {
                return r.location == 0 ? nil : NSMakeRange(0, r.location - 1)
            }
            return nil
        }
    }
    var preceedingText: NSString? {
        get {
            if let t = textStorage {
                if let r = preceedingTextRange {
                    return (t.string as NSString).substringWithRange(r)
                }
            }
            return nil
        }
    }
    var preceedingTextGlyphRange: NSRange? {
        get {
            if let r = preceedingTextRange {
                return glyphRangeForCharacterRange(r, actualCharacterRange: nil)
            }
            return nil
        }
    }
    var counter = 0
    // Triggered by func addLayoutManager(_ aLayoutManager: NSLayoutManager) from NSTextStorage. This method sends setTextStorage: to aLayoutManager with the receiver(NSTextStorage).
    override func setTextContainer(container: NSTextContainer?, forGlyphRange glyphRange: NSRange) {
        // Assuming text must be in the fullContent
        printContainer(container, stage: 0)
        println("\(0) GlyphRange: Location: \(glyphRange.location) Length: \(glyphRange.length)")
        println("\(0) textInRange: \((textStorage!.string as NSString).substringWithRange(glyphRange))")
        counter++
        println("\(0) Counter: \(counter)")
        println("\(0) textGlyphRange: Location: \(textGlyphRange?.location) Length: \(textGlyphRange?.length)")
        var containerToUse: NSTextContainer
        if let t = textGlyphRange {
            containerToUse = NSIntersectionRange(glyphRange, t).length == t.length ? textContainerToShow : textContainerHidden
        } else {
            containerToUse = textContainerToShow
        }
        printContainer(container, stage: 1)
        super.setTextContainer(containerToUse, forGlyphRange: glyphRange)
    }
    func printContainer(c: NSTextContainer?, stage: Int) {
        if let cc = c {
            if cc.isEqual(textContainerToShow) {
                println("\(stage): textContainerToShow")
            } else if cc.isEqual(textContainerHidden) {
                println("\(stage): textContainerHidden")
            } else {
                println("\(stage): textContainer Unknown")
            }
        } else {
            println("\(stage): textContainer None")
        }
    }
}

class TextView: UITextView {
    convenience init(gap: CGFloat, inParentRect: CGRect, noInset: Bool, container: NSTextContainer) {
        self.init(frame: CGRectMake(inParentRect.origin.x + gap, inParentRect.origin.y, inParentRect.width - gap * 2, inParentRect.height), textContainer: container)
        if noInset {
            contentInset = UIEdgeInsetsZero
        }
        userInteractionEnabled = false
    }
}

class MoveThenExpandTextContainer: NSTextContainer {
    convenience init(isHidden: Bool, size: CGSize) {
        self.init(size: size)
        if isHidden {
            lineFragmentPadding = 0
            maximumNumberOfLines = 1
        }
    }
}

func fittedTextViewWidth(text: NSString, initialRect: CGRect, container: NSTextContainer) -> CGFloat {
    var v = UITextView(frame: initialRect, textContainer: container)
    v.sizeToFit()
    return v.frame.width
}

//func getTextViewInitialRect(view: UITextView, lineFragmentRect: CGRect, lineFragmentShownWidth: CGFloat, pointToMatch: CGPoint) -> CGRect {
//    let size = CGSizeMake(getTextViewInitialWidth(view, lineFragmentRect, lineFragmentShownWidth), view.frame.height)
//    let point = updateTextViewOriginToMatchLineFragmentOrigin(pointToMatch, view, lineFragmentRect.origin)
//    return CGRectMake(point.x, point.y, size.width, size.height)
//}

func updateTextViewOriginToMatchLineFragmentOrigin(pointSetInTextViewParentView: CGPoint, view: UITextView, lineFragmentOrigin: CGPoint) -> CGPoint {
    let lineFragmentOriginInParentView = CGPointMake(view.frame.origin.x + view.contentInset.left + lineFragmentOrigin.x, view.frame.origin.y + view.contentInset.top + lineFragmentOrigin.y)
    let distanceFromPointSetX = lineFragmentOriginInParentView.x - pointSetInTextViewParentView.x
    let distanceFromPointSetY = lineFragmentOriginInParentView.y - pointSetInTextViewParentView.y
    return CGPointMake(view.frame.origin.x - distanceFromPointSetX, view.frame.origin.y - distanceFromPointSetY)
}

func convertOriginTextViewParentViewCoordinateToTextContainerCoordinate(view: UITextView, originOfLineFragment: CGPoint) -> CGPoint {
    return CGPointMake(0 - view.frame.origin.x - view.textContainerInset.left - originOfLineFragment.x, 0 - view.frame.origin.y - view.textContainerInset.top - originOfLineFragment.y)
}


