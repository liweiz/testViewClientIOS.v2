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
    var isShowingFullContent = false
    var base: UIScrollView!
    
    var fullContent: NSString!
    var fullContentA: NSAttributedString!
    var textColor: UIColor!
    var text: NSString! // Mismatched text (text not in fullContent), should be handled before use this ctl.
    var textA: NSAttributedString!
    
    var sizeShownForFullContent: CGSize!
    var visiableRect: CGRect!
    var viewWithFullContent: UITextView! // Final status for the textView
    
    var firstGlyphOriginBeforeFullContent: CGPoint! // In ctl.view's coordinates.
    var firstGlyphOriginAfterFullContent: CGPoint! // In ctl.view's coordinates.
    
    var lineTextViews: [SyncedTextView]! // To animate each line's changes.
    var lineExtraTextViews: [SyncedTextView]! // To animate each line's adaption to line wrap.
    
    var textCharacterRange: NSRange {
        get {
            return fullContent.rangeOfString(text as String)
        }
    }
    var textGlyphRangeInFullContentView: NSRange {
        get {
            return viewWithFullContent.layoutManager.glyphRangeForCharacterRange(textCharacterRange, actualCharacterRange: nil)
        }
    }
    override func loadView() {
        view = UIView(frame: CGRectMake(0, 0, sizeShown.width, sizeShown.height))
        viewWithFullContent = getViewWithFullContent(10)
        view.addSubview(viewWithFullContent)
        let textRect = viewWithFullContent.layoutManager.boundingRectForGlyphRange(textGlyphRange, inTextContainer: viewWithFullContent.textContainer)
        base = UIScrollView(frame: view.frame)
        base.contentSize = CGSizeMake(view.frame.width, view.frame.height * 3)
        base.contentOffset = CGPointMake(0, view.frame.height)
    }
    // Sync trigger
    func getYDistanceToGo() -> CGFloat {
        
    }
    
    // Synced lines
    func generateSyncedLines(firstGlyphOriginInCtlView: CGPoint) {
        let sampleTextView = getTextViewInOneLine()
        let cRanges = getCharacterRangesDecomposedTextShownInViewWithFullContent()
        let textViews = generateLinesOnCtlView(firstGlyphOriginInCtlView, sampleTextView: sampleTextView, charRanges: cRanges)
        lineTextViews = [SyncedTextView]()
        lineExtraTextViews = [SyncedTextView]()
        var i = 0
        for v in textViews.0 {
            var mainPart = SyncedTextView(textViewToInsert: textViews.mainView[i], rectVisiable: visiableRect)
            lineTextViews.append(mainPart)
            var extraPart = SyncedTextView(textViewToInsert: textViews.extraView[i], rectVisiable: visiableRect)
            lineExtraTextViews.append(extraPart)
            i++
        }
    }
    func generateLinesOnCtlView(firstGlyphOriginInCtlView: CGPoint, sampleTextView: UITextView, charRanges: ([NSRange], [NSRange])) -> (mainView: [UITextView], extraView: [UITextView]) {
        firstLineOriginBeforeFullContent = getFirstLineTextViewOrigin(sampleTextView, pointInCtlView: firstGlyphOriginInCtlView)
        var mainViews = [UITextView]()
        var extraViews = [UITextView]()
        var i = 0
        for r in charRanges.0 {
            var x = generateTextViewsForOneLine(firstOrigin, charRanges: charRanges, sampleTextView: sampleTextView, lineNo: i)
            mainViews.append(x.mainView)
            extraViews.append(x.mainView)
            i++
        }
        return (mainViews, extraViews)
    }
    func generateTextViewsForOneLine(firstViewOrigin: CGPoint, charRanges: ([NSRange], [NSRange]), sampleTextView: UITextView, lineNo: Int) -> (mainView: UITextView, extraView: UITextView) {
        var main = generateTextView(firstViewOrigin, charRange: charRanges.0[lineNo], sampleTextView: sampleTextView, lineNo: lineNo)
        var extra = generateTextView(firstViewOrigin, charRange: charRanges.1[lineNo], sampleTextView: sampleTextView, lineNo: lineNo)
        return (main, extra)
    }
    func generateTextView(firstViewOrigin: CGPoint, charRange: NSRange, sampleTextView: UITextView, lineNo: Int) -> UITextView {
        var t = UITextView(frame: CGRectMake(firstViewOrigin.x - visiableRect.width * CGFloat(lineNo), firstViewOrigin.y + sampleTextView.textContainer.size.height * CGFloat(lineNo), sampleTextView.frame.width, sampleTextView.frame.height))
        configTextView(t)
        t.attributedText = setGlyphsVisiability(sampleTextView.attributedText, charRange, textColor)
        view.addSubview(t)
        return t
    }
    func getFirstLineTextViewOrigin(sampleTextView: UITextView, pointInCtlView: CGPoint) -> CGPoint {
        let originInTextView = boundingRectOriginForGlyphRange(sampleTextView, sampleTextView.layoutManager.glyphRangeForCharacterRange(fullContent.rangeOfString(text as String), actualCharacterRange: nil))
        return originToMatchPoint(pointInCtlView, originInTextView)
    }
    func getViewWithFullContent(gap: CGFloat) -> UITextView {
        var r = UITextView(frame: CGRectMake(gap, 0, sizeShownForFullContent.width - gap * 2, sizeShownForFullContent.height))
        configTextView(r)
        r.attributedText = fullContentA
        let rect = r.layoutManager.usedRectForTextContainer(r.textContainer)
        r.frame = CGRectMake(r.frame.origin.x, (sizeShownForFullContent.height - rect.height) / 2, r.frame.width, rect.height)
        return r
    }
    func getTextViewInOneLine(width: CGFloat = 2000) -> UITextView {
        var r = UITextView(frame: CGRectMake(0, 0, width, sizeShownForFullContent.height))
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
    
    func getCharacterRangesDecomposedTextShownInViewWithFullContent() -> (mainRange: [NSRange], rangeLeft: [NSRange]) {
        let rectForText = viewWithFullContent.layoutManager.boundingRectForGlyphRange(textGlyphRangeInFullContentView, inTextContainer: viewWithFullContent.textContainer)
        var mainRange = [NSRange]()
        var rangeLeft = [NSRange]()
        var glyphLocation = textGlyphRangeInFullContentView.location
        do {
            let startingGlyphRect = viewWithFullContent.layoutManager.lineFragmentRectForGlyphAtIndex(glyphLocation, effectiveRange: nil)
            let lineGlyphRange = viewWithFullContent.layoutManager.glyphRangeForBoundingRect(startingGlyphRect, inTextContainer: viewWithFullContent.textContainer)
            let headLocation = lineGlyphRange.location < textGlyphRangeInFullContentView.location ? textGlyphRangeInFullContentView.location : lineGlyphRange.location
            let endLocation = lineGlyphRange.location + lineGlyphRange.length - 1 > textGlyphRangeInFullContentView.location + textGlyphRangeInFullContentView.length - 1 ? textGlyphRangeInFullContentView.location + textGlyphRangeInFullContentView.length - 1 : lineGlyphRange.location + lineGlyphRange.length - 1
            mainRange.append(viewWithFullContent.layoutManager.characterRangeForGlyphRange(NSMakeRange(headLocation, endLocation - headLocation + 1), actualGlyphRange: nil))
            glyphLocation = endLocation + 1
        } while glyphLocation < textGlyphRangeInFullContentView.location + textGlyphRangeInFullContentView.length - 1
        for r in mainRange {
            rangeLeft.append(NSMakeRange(r.location + r.length, textCharacterRange.length - r.length))
        }
        return (mainRange, rangeLeft)
    }
    func getCharacterRangeFullContentViewForRect(rect: CGRect) -> NSRange {
        return viewWithFullContent.layoutManager.characterRangeForGlyphRange(viewWithFullContent.layoutManager.glyphRangeForBoundingRect(rect, inTextContainer: viewWithFullContent.textContainer), actualGlyphRange: nil)
    }
}

// MARK: - SyncedLine

class SyncedTextView: UIScrollView {
    var textView: UITextView!
    var nextLineTextViewsInChain: [SyncedTextView]!
    var nextLineExtraTextViewsInChain: [SyncedTextView]!
    var nextViews: [SyncedTextView] {
        get {
            return nextLineTextViewsInChain + nextLineExtraTextViewsInChain
        }
    }
    override func setContentOffset(contentOffset: CGPoint, animated: Bool) {
        lastRecordedContentOffsetX = contentOffset.x
        super.setContentOffset(contentOffset, animated: animated)
    }
    var lastRecordedContentOffsetX: CGFloat!
    var isTrigger = false
    var xDifferenceToLastView: CGFloat!
    var visiableCharacterRange: NSRange!
    var visiableGlyphRange: NSRange {
        get {
            return textView.layoutManager.glyphRangeForCharacterRange(visiableCharacterRange, actualCharacterRange: nil)
        }
    }
    var visiableGlyphsRectX: CGFloat {
        get {
            return textView.frame.origin.x + textView.textContainer.lineFragmentPadding + textView.textContainerInset.left + textView.layoutManager.boundingRectForGlyphRange(visiableGlyphRange, inTextContainer: textView.textContainer).origin.x
        }
    }
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
    override func layoutSubviews() {
        super.layoutSubviews()
        if isTrigger {
            let delta = contentOffset.x - lastRecordedContentOffsetX
            lastRecordedContentOffsetX = contentOffset.x
            for v in nextViews {
                v.contentOffset = CGPointMake(v.contentOffset.x + delta, v.contentOffset.y)
            }
        }
    }
    // There are two stage of the transition: 1. every SyncedTextView changes its contentOffset synchronistically till expected position for first glyph in the text range is reached 2. adjust line wrap one line after another. This method is used on stage 2. So it's only used on extraTextView.
    func adjustToMatchLineWrap() {
        if nextLineExtraTextViewsInChain.count > 0 {
            var r0 = nextLineTextViewsInChain
            r0.removeAtIndex(0)
            var r1 = nextLineExtraTextViewsInChain
            r1.removeAtIndex(0)
            nextLineExtraTextViewsInChain[0].nextLineTextViewsInChain = r0
            nextLineExtraTextViewsInChain[0].nextLineExtraTextViewsInChain = r1
        }
        if visiableGlyphsRectX >= contentOffset.x + frame.width {
            // Whole visiable part is not visiable now.
            if nextLineExtraTextViewsInChain.count > 0 {
                nextLineExtraTextViewsInChain[0].adjustToMatchLineWrap()
            }
        } else {
            // Visiable part is still visiable.
            isTrigger = true
            setContentOffset(CGPointMake(visiableGlyphsRectX, contentOffset.y) , animated: true)
        }
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
