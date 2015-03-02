//
//  UnusedFunctions.swift
//  Remolet
//
//  Created by Liwei Zhang on 2015-03-01.
//  Copyright (c) 2015 Liwei Zhang. All rights reserved.
//

import Foundation

func getPreceedingPartForText(fullContent: String, text: String) -> String? {
    if let r = fullContent.rangeOfString(text) {
        var end: String.Index
        fullContent.startIndex != r.startIndex ? (end = advance(r.startIndex, -1)) : (end = fullContent.startIndex)
        return fullContent.substringWithRange(Range<String.Index>(start: fullContent.startIndex, end: end))
    }
    return nil
}

var textStartFromLeft = true

class MoveThenExpandComponentTextView: UITextView {
    convenience init(rect: CGRect) {
        self.init(frame: rect)
        backgroundColor = UIColor.grayColor()
        textStartFromLeft ? (textAlignment = NSTextAlignment.Left) : (textAlignment = NSTextAlignment.Right)
        textContainer.widthTracksTextView = true
        textContainer.lineBreakMode = NSLineBreakMode.ByWordWrapping
        backgroundColor = UIColor.brownColor()
    }
    func refreshFrame(text: String, originOnParent: CGPoint, inSize:CGSize) -> (text: String?, y: CGFloat?) {
        if let range = self.text.rangeOfString(text) {
            let r = rangeToUITextRange(range, self)
            if let f = getTextFragmentFrame(text, self, originOnParent, inSize, r) {
                frame = f
                if let rangeLeft = getTextRangeLeftByFirstRect(self, text, r, textStartFromLeft: textStartFromLeft) {
                    if !rangeLeft.empty {
                        println("rangeLeft text: \(self.textInRange(rangeLeft))")
                        return (self.textInRange(rangeLeft), self.firstRectForRange(rangeLeft).origin.y)
                    }
                }
            }
        }
        return (nil, nil)
    }
}

// Get string left
func getTextRangeLeftByFirstRect<T: UITextInput>(view: T, text: String, range: UITextRange, textStartFromLeft: Bool = true) -> UITextRange? {
    if let r = getTextFromView(view).rangeOfString(text) {
        var p: CGPoint
        let k = view.firstRectForRange(range)
        println("firstRectForRange: \(k)")
        textStartFromLeft ? (p = CGPointMake(k.maxX, k.minY + k.height / 2)) : (p = CGPointMake(k.minX, k.minY + k.height / 2))
        let position = view.closestPositionToPoint(p)
        let start = view.positionFromPosition(position, offset: 1)
        let end = range.end
        return view.textRangeFromPosition(start, toPosition: end)
    }
    return nil
}

// MARK: - Target rect
// Get textView rect without considering contentOffset
func getTextFragmentFrame<T: UITextInput>(fragment: String, view: T, fragmentOriginOnParent: CGPoint, inSize: CGSize, range: UITextRange) -> CGRect? {
    if let origin = getTextOriginInView(view, fragment, range) {
        return CGRectMake(fragmentOriginOnParent.x - origin.x, fragmentOriginOnParent.y - origin.y, inSize.width - (fragmentOriginOnParent.x - origin.x), inSize.height)
    }
    return nil
}

func getTextOriginInView<T: UITextInput>(view: T, text: String, range: UITextRange) -> CGPoint? {
    if let r = getTextFromView(view).rangeOfString(text) {
        return view.firstRectForRange(range).origin
    }
    return nil
}


func rangeToUITextRange<T: UITextInput>(range: Range<String.Index>, view: T) -> UITextRange {
    let beginning = view.beginningOfDocument
    let text = getTextFromView(view)
    var l0 = 0
    for _ in 0...count(text) {
        if advance(text.startIndex, l0) == range.startIndex {
            break
        }
        l0++
    }
    var l1 = 0
    for _ in range {
        l1++
    }
    let start = view.positionFromPosition(beginning, offset: l0)
    let end = view.positionFromPosition(start!, offset: l1)
    return view.textRangeFromPosition(start!, toPosition: end!)
}

func getTextFromView<T: UITextInput>(view: T) -> String {
    let beginning = view.beginningOfDocument
    return view.textInRange(view.textRangeFromPosition(beginning, toPosition: view.endOfDocument))
}

func nsrangeToUITextRange(range: NSRange, textView: UITextView) -> UITextRange {
    let beginning = textView.beginningOfDocument
    let start = textView.positionFromPosition(beginning, offset: range.location)
    let end = textView.positionFromPosition(start!, offset: range.length)
    return textView.textRangeFromPosition(start!, toPosition: end!)
}