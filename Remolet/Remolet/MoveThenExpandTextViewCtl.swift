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
    var base: MoveThenExpandTextView!
    var rectToShowOn: CGRect!
    var textStartFromLeft = true
    override func loadView() {
        view = UIView(frame: rectToShowOn)
        base = MoveThenExpandTextView(frame: rectToShowOn)
        base.contentSize = CGSizeMake(base.frame.width * 2, base.frame.height * 3)
        var initialOffset: CGPoint
        textStartFromLeft ? (initialOffset = CGPointMake(base.frame.width, base.frame.height)) : (initialOffset = CGPointMake(0, base.frame.height))
        base.contentOffset = initialOffset
//        base.userInteractionEnabled = false
        view.addSubview(base)
        base.test()
    }
    
}

class MoveThenExpandTextView: UIScrollView {
    var textViews = [MoveThenExpandComponentTextView]()
    func addText(text: String, startOrigin: CGPoint, fullContent: String) {
        var on = true
        var s: String? = text
        var y: CGFloat? = startOrigin.y
        while s != nil && y != nil {
            let r = addOneViewForText(s!, origin: CGPointMake(startOrigin.x, y!), fullContent: fullContent)
            if r.text == nil {
                println()
            }
            s = r.text
            y = r.y
            print("s: \(s), y: \(y)")
        }
    }
    func addOneViewForText(text: String, origin: CGPoint, fullContent: String) -> (text: String?, y: CGFloat?) {
        if let x = fullContent.rangeOfString(text) {
            // To avoid potential firstRectForRange's constant change after resizing, always keep the firstRectForRange in the first line.
            var textView = MoveThenExpandComponentTextView(rect: CGRectMake(frame.width, frame.height, 1700, 500))
            textView.text = fullContent
            self.addSubview(textView)
            textView.tag = 700 + textViews.count
            textViews.append(textView)
            return textView.refreshFrame(text, originOnParent: origin, inSize: frame.size)
        }
        return (nil, nil)
    }
    override func layoutSubviews() {
        if contentOffset.x < frame.width {
            for v in textViews {
                v.frame = CGRectMake(v.frame.origin.x, v.frame.origin.y, min(contentSize.width - v.frame.origin.x - (frame.width - contentOffset.x), v.frame.width), v.frame.height)
            }
        }
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    func test() {
        addText("Some system views, like table views, help you by scrolling the first responder into view automatically. If the first responder is at the bottom of the scrolling region, however, you may still need to resize or reposition the scroll view itself to ensure the first responder is visible.", startOrigin: CGPointMake(10, 10), fullContent: "When the user taps in an editable text view, that text view becomes the first responder and automatically asks the system to display the associated keyboard. Because the appearance of the keyboard has the potential to obscure portions of your user interface, it is up to you to make sure that does not happen by repositioning any views that might be obscured. Some system views, like table views, help you by scrolling the first responder into view automatically. If the first responder is at the bottom of the scrolling region, however, you may still need to resize or reposition the scroll view itself to ensure the first responder is visible.")
        
    }
}

// NEW WAY

class TwoColumnLayoutMgr: NSLayoutManager {
    var textContainerToShow = NSTextContainer()
    var textContainerHidden = NSTextContainer()
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
    func configTextContainers() {
        textContainerHidden.maximumNumberOfLines = 1
        textContainerHidden.size =
    }
    override func setTextContainer(container: NSTextContainer?, forGlyphRange glyphRange: NSRange) {
        // Assuming text must be in the fullContent
        var containerToUse: NSTextContainer
        if let t = textGlyphRange {
            containerToUse = NSIntersectionRange(glyphRange, t).length == t.length ? textContainerToShow : textContainerHidden
        } else {
            containerToUse = textContainerToShow
        }
        super.setTextContainer(containerToUse, forGlyphRange: glyphRange)
    }
}

class MoveThenExpandTextContainerHidden: NSTextContainer {
    override init() {
        super.init(size: CGSizeMake(1700, 70))
        maximumNumberOfLines = 1
    }
    override func lineFragmentRectForProposedRect(proposedRect: CGRect, atIndex characterIndex: Int, writingDirection baseWritingDirection: NSWritingDirection, remainingRect: UnsafeMutablePointer<CGRect>) -> CGRect {
        var r = super.lineFragmentRectForProposedRect(proposedRect, atIndex: characterIndex, writingDirection: baseWritingDirection, remainingRect: remainingRect)
        var firstLineRect = super.lineFragmentRectForProposedRect(proposedRect, atIndex: 0, writingDirection: baseWritingDirection, remainingRect: remainingRect)
    }
    
}



func getTextViewInitialRect(view: UITextView, lineFragmentRect: CGRect, lineFragmentShownWidth: CGFloat, pointToMatch: CGPoint) -> CGRect {
    let size = CGSizeMake(getTextViewInitialWidth(view, lineFragmentRect, lineFragmentShownWidth), view.frame.height)
    let point = updateTextViewOriginToMatchLineFragmentOrigin(pointToMatch, view, lineFragmentRect.origin)
    return CGRectMake(point.x, point.y, size.width, size.height)
}

// Make it wider to have room to squeeze text to next line by shrinking the width.
func getTextViewInitialWidth(view: UITextView, lineFragmentRect: CGRect, lineFragmentShownWidth: CGFloat) -> CGFloat {
    return view.textContainerInset.left + view.textContainerInset.right + lineFragmentRect.origin.x + max(lineFragmentRect.width * 2, lineFragmentShownWidth + lineFragmentRect.width)
}

func updateTextViewOriginToMatchLineFragmentOrigin(pointSetInTextViewParentView: CGPoint, view: UITextView, lineFragmentOrigin: CGPoint) -> CGPoint {
    let lineFragmentOriginInParentView = CGPointMake(view.frame.origin.x + view.contentInset.left + lineFragmentOrigin.x, view.frame.origin.y + view.contentInset.top + lineFragmentOrigin.y)
    let distanceFromPointSetX = lineFragmentOriginInParentView.x - pointSetInTextViewParentView.x
    let distanceFromPointSetY = lineFragmentOriginInParentView.y - pointSetInTextViewParentView.y
    return CGPointMake(view.frame.origin.x - distanceFromPointSetX, view.frame.origin.y - distanceFromPointSetY)
}

func convertOriginTextViewParentViewCoordinateToTextContainerCoordinate(view: UITextView, originOfLineFragment: CGPoint) -> CGPoint {
    return CGPointMake(0 - view.frame.origin.x - view.textContainerInset.left - originOfLineFragment.x, 0 - view.frame.origin.y - view.textContainerInset.top - originOfLineFragment.y)
}


