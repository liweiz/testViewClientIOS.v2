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
    var textStartFromLeft = true
    var noOfTextViews = 0
    var textViews = [UITextView]()
    func addText(origin: CGPoint, fullContent: String, t: String) {
        var textView = UITextView(frame: CGRectMake(0, 0, 700, 1000))
        textView.textAlignment = NSTextAlignment.Left
        textView.text = fullContent
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.lineBreakMode = NSLineBreakMode.ByWordWrapping
        textView.backgroundColor = UIColor.brownColor()
        if let r = getAlignedTextViewRect(textView, CGPointMake(origin.x + contentOffset.x, origin.y + contentOffset.y), t, frame) {
            textView.frame = r
            self.addSubview(textView)
            textView.tag = 970 + noOfTextViews
            noOfTextViews++
        }
    }
    override func layoutSubviews() {
        for v in textViews {
            v.frame = CGRectMake(v.frame.origin.x, v.frame.origin.y, min(contentSize.width - v.frame.origin.x - contentOffset.x, v.frame.width), v.frame.height)
        }
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    func test() {
        addText(CGPointMake(10, 10), fullContent: "When the user taps in an editable text view, that text view becomes the first responder and automatically asks the system to display the associated keyboard. Because the appearance of the keyboard has the potential to obscure portions of your user interface, it is up to you to make sure that does not happen by repositioning any views that might be obscured. Some system views, like table views, help you by scrolling the first responder into view automatically. If the first responder is at the bottom of the scrolling region, however, you may still need to resize or reposition the scroll view itself to ensure the first responder is visible.", t: "Some system views, like table views, help you by scrolling the first responder into view automatically. If the first responder is at the bottom of the scrolling region, however, you may still need to resize or reposition the scroll view itself to ensure the first responder is visible.")
    }
}

func getAlignedTextViewRect(textView: UITextView, textOriginOnParent: CGPoint, text: String, inRect: CGRect) -> CGRect? {
    if let origin = getAlignedTextViewOrigin(textView, textOriginOnParent, text) {
        return CGRectMake(origin.x, origin.y, inRect.width - origin.x, inRect.height)
    }
    return nil
}

// Get textView origin
func getAlignedTextViewOrigin(textView: UITextView, textOriginOnParent: CGPoint, text: String) -> CGPoint? {
    if let p = getTextOriginInTextView(textView, text) {
        return CGPointMake(textOriginOnParent.x - p.x, textOriginOnParent.y - p.y)
    }
    return nil
}

// MARK: - Target origin
func getTextOriginInTextView(v: UITextView, text: String) -> CGPoint? {
    if let r = v.text.rangeOfString(text) {
        return v.firstRectForRange(rangeToUITextRange(r, v)).origin
    }
    return nil
}

func rangeToUITextRange(range: Range<String.Index>, textView: UITextView) -> UITextRange {
    let beginning = textView.beginningOfDocument
    var l0 = 0
    for _ in 0...count(textView.text) - 1 {
        if advance(textView.text.startIndex, l0) == range.startIndex {
            break
        }
        l0++
    }
//    l0++
    var l1 = 0
    for _ in range {
        l1++
    }
    let start = textView.positionFromPosition(beginning, offset: l0)
    let end = textView.positionFromPosition(start!, offset: l1)
    return textView.textRangeFromPosition(start!, toPosition: end!)
}

func nsrangeToUITextRange(range: NSRange, textView: UITextView) -> UITextRange {
    let beginning = textView.beginningOfDocument
    let start = textView.positionFromPosition(beginning, offset: range.location)
    let end = textView.positionFromPosition(start!, offset: range.length)
    return textView.textRangeFromPosition(start!, toPosition: end!)
}