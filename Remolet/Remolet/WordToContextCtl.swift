//
//  WordToContextCtl.swift
//  Remolet
//
//  Created by Liwei Zhang on 2015-03-13.
//  Copyright (c) 2015 Liwei Zhang. All rights reserved.
//

import Foundation
import UIKit
// NSLayoutManager works only with NSRange. It's easier to get NSRange from NSString instead of Range<String.Index> (http://stackoverflow.com/questions/27040924/nsrange-from-swift-range)

class WordToContextCtl: UIViewController {
    var fullContent: NSString!
    var fullContentA: NSAttributedString!
    var textColor: UIColor!
    var text: NSString! // Mismatched text (text not in fullContent), should be handled before use this ctl.
    var textA: NSAttributedString!
    var sizeShown: CGSize!
    var base: UIScrollView!
    var viewWithFullContent: UITextView! // Final status for the textView
    var visiableRect: CGRect!
    var textGlyphRange: NSRange {
        get {
            return viewWithFullContent.layoutManager.glyphRangeForCharacterRange(fullContent.rangeOfString(text as String), actualCharacterRange: nil)
        }
    }
    
    override func loadView() {
        view = UIView(frame: CGRectMake(0, 0, sizeShown.width, sizeShown.height))
        viewWithFullContent = getViewWithFullContent(10)
        view.addSubview(viewWithFullContent)
        let textRect = viewWithFullContent.layoutManager.boundingRectForGlyphRange(textGlyphRange, inTextContainer: viewWithFullContent.textContainer)
    }

    func generateSyncedLines(firstGlyphOriginInCtlView: CGPoint) {
        let sampleTextView = getTextViewInOneLine()
        let ranges = getCharacterRangesDecomposedTextShownInViewWithFullContent()
        var lines = [SyncedOneLineView]()
        for r in ranges {
            var l = SyncedOneLineView(sampleTextView: sampleTextView, rectVisiable: visiableRect), textViewOrigin: <#CGPoint#>)
        }
    }
    func generateLinesOnCtlView(firstGlyphOriginInCtlView: CGPoint, sampleTextView: UITextView, charRanges: [NSRange]) -> (views: [SyncedTextView], extraViews: [SyncedTextView?]) {
        let firstOrigin = getFirstLineTextViewOrigin(sampleTextView, pointInCtlView: firstGlyphOriginInCtlView)
        var textViews = [UITextView]()
        var i = 0
        for r in charRanges {
            var t = UITextView(frame: CGRectMake(firstOrigin.x - visiableRect.width * CGFloat(i), firstOrigin.y + sampleTextView.textContainer.size.height * CGFloat(i), sampleTextView.frame.width, sampleTextView.frame.height))
            configTextView(t)
            t.attributedText = setGlyphsVisiability(sampleTextView.attributedText, r, textColor)
            view.addSubview(t)
            textViews.append(t)
            i++
        }
        var views = [SyncedTextView]()
        var extraViews = [SyncedTextView?]()
        for v in textViews {
            var mainPart = SyncedTextView(textViewToInsert: v, rectVisiable: visiableRect)
            views.append(mainPart)
            
        }
    }
    func getFirstLineTextViewOrigin(sampleTextView: UITextView, pointInCtlView: CGPoint) -> CGPoint {
        let originInTextView = boundingRectOriginForGlyphRange(sampleTextView, sampleTextView.layoutManager.glyphRangeForCharacterRange(fullContent.rangeOfString(text as String), actualCharacterRange: nil))
        return originToMatchPoint(pointInCtlView, originInTextView)
    }
    func getViewWithFullContent(gap: CGFloat) -> UITextView {
        var r = UITextView(frame: CGRectMake(gap, 0, sizeShown.width - gap * 2, sizeShown.height))
        configTextView(r)
        r.attributedText = fullContentA
        let rect = r.layoutManager.usedRectForTextContainer(r.textContainer)
        r.frame = CGRectMake(r.frame.origin.x, (sizeShown.height - rect.height) / 2, r.frame.width, rect.height)
        return r
    }
    func getTextViewInOneLine(width: CGFloat = 2000) -> UITextView {
        var r = UITextView(frame: CGRectMake(0, 0, width, sizeShown.height))
        configTextView(r)
        r.attributedText = fullContentA
        if width == 2000 {
            let rect = r.layoutManager.usedRectForTextContainer(r.textContainer)
            r.frame = CGRectMake(0, 0, rect.width, rect.height)
        }
        return r
    }
    func configTextView(view: UITextView) {
        view.backgroundColor = UIColor.clearColor()
        view.contentInset = UIEdgeInsetsZero
        view.textContainer.lineFragmentPadding = 0
    }
    
    func getCharacterRangesDecomposedTextShownInViewWithFullContent() -> [NSRange] {
        let rectForText = viewWithFullContent.layoutManager.boundingRectForGlyphRange(textGlyphRange, inTextContainer: viewWithFullContent.textContainer)
        var r = [NSRange]()
        var glyphLocation = textGlyphRange.location
        do {
            let startingGlyphRect = viewWithFullContent.layoutManager.lineFragmentRectForGlyphAtIndex(glyphLocation, effectiveRange: nil)
            let lineGlyphRange = viewWithFullContent.layoutManager.glyphRangeForBoundingRect(startingGlyphRect, inTextContainer: viewWithFullContent.textContainer)
            let headLocation = lineGlyphRange.location < textGlyphRange.location ? textGlyphRange.location : lineGlyphRange.location
            let endLocation = lineGlyphRange.location + lineGlyphRange.length - 1 > textGlyphRange.location + textGlyphRange.length - 1 ? textGlyphRange.location + textGlyphRange.length - 1 : lineGlyphRange.location + lineGlyphRange.length - 1
            r.append(viewWithFullContent.layoutManager.characterRangeForGlyphRange(NSMakeRange(headLocation, endLocation - headLocation + 1), actualGlyphRange: nil))
            glyphLocation = endLocation + 1
        } while glyphLocation < textGlyphRange.location + textGlyphRange.length - 1
        return r
    }
    func getFinalCharacterRangeForRect(rect: CGRect) -> NSRange {
        return viewWithFullContent.layoutManager.characterRangeForGlyphRange(viewWithFullContent.layoutManager.glyphRangeForBoundingRect(rect, inTextContainer: viewWithFullContent.textContainer), actualGlyphRange: nil)
    }
}

// MARK: - SyncedLine

class SyncedTextView: UIScrollView {
    var textView: UITextView!
    init(textViewToInsert: UITextView, rectVisiable: CGRect) {
        super.init(frame: CGRectMake(rectVisiable.origin.x, textViewToInsert.frame.origin.y, rectVisiable.width, rectVisiable.height))
        contentSize = CGSizeMake(rectVisiable.width * 3, rectVisiable.height)
        contentOffset = CGPointMake(rectVisiable.width, 0)
        textViewToInsert.superview?.addSubview(self)
        textViewToInsert.frame.origin = self.convertPoint(textViewToInsert.frame.origin, fromView: self.superview!)
        textView = textViewToInsert
        self.addSubview(textView)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}




func originToMatchPoint(pointToMatch: CGPoint, pointInView: CGPoint) -> CGPoint {
    return CGPointMake(pointToMatch.x - pointInView.x, pointToMatch.y - pointInView.y)
}

func boundingRectOriginForGlyphRange(textView: UITextView, glyphRange: NSRange) -> CGPoint {
    let rect = textView.layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textView.textContainer)
    return CGPointMake(rect.origin.x + textView.textContainer.lineFragmentPadding + textView.textContainerInset.left, rect.origin.y + textView.textContainerInset.top)
}

func setGlyphsVisiability(aString: NSAttributedString, charRange: NSRange, color: UIColor) -> NSMutableAttributedString {
    var s = NSMutableAttributedString(attributedString: aString)
    s.addAttribute("NSForegroundColorAttributeName", value: UIColor.clearColor(), range: NSMakeRange(0, (s.string as NSString).length))
    s.addAttribute("NSForegroundColorAttributeName", value: color, range: charRange)
    return s
}

func getGlyphRectOriginInContainer(container: NSTextContainer, glyphIndex: Int) -> CGPoint {
    var p = CGPointZero
    return p
}

// MARK: - Line break text transition for one stop



// This operation is from top to bottom and one stop a time. The next operation only starts after the operation for the line above is completed. So the cooresponding lines shoud have the same glyphs (they do not necessarily come with the same glyphRange).
//func findUncessaryExtraGlyphRangeInThisLine(firstGlyphIndexOfTheLineInViewWithFullContent: Int, viewWithFullContent: UITextView, currentView: UITextView) -> NSRange {
//    // All glyphs
//}

func convertGlyphsRangeInView0ToInView1(glyphRange: NSRange, view0: UITextView, view1: UITextView) -> NSRange {
    let characterView0 = (view0.attributedText.string as NSString).substringWithRange(view0.layoutManager.characterRangeForGlyphRange(glyphRange, actualGlyphRange: nil))
    let characterRangeView1 = (view1.attributedText.string as NSString).rangeOfString(characterView0)
    return view1.layoutManager.glyphRangeForCharacterRange(characterRangeView1, actualCharacterRange: nil)
}

// NSLayoutManager's glyphRangeForBoundingRect bug: That documentation is incorrect; the glyphRangeForBoundingRect methods currently always return whole lines. http://www.cocoabuilder.com/archive/cocoa/17416-nslayoutmanager-glyphrangeforboundingrect-bug.html
func getGlyphRangeForTextOccupiedLines(text: NSAttributedString, view: UITextView) -> NSRange {
    return view.layoutManager.glyphRangeForBoundingRect(view.layoutManager.boundingRectForGlyphRange(view.layoutManager.glyphRangeForCharacterRange((view.attributedText.string as NSString).rangeOfString(text.string), actualCharacterRange: nil), inTextContainer: view.textContainer), inTextContainer: view.textContainer)
}


func getFullWideBoundingRectForGlyphRange(glyphRange: NSRange, view: UITextView) -> CGRect {
    var r = view.layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: view.textContainer)
    if r.width != view.textContainer.size.width - view.textContainer.lineFragmentPadding {
        r = CGRectMake(0, r.origin.y, view.textContainer.size.width - view.textContainer.lineFragmentPadding, r.height)
    }
    return r
}

func getGlyphRangeOfText(text: NSAttributedString, view: UITextView) -> NSRange {
    return view.layoutManager.glyphRangeForCharacterRange((view.attributedText.string as NSString).rangeOfString(text.string), actualCharacterRange: nil)
}
