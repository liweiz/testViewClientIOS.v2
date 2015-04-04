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

func testWordToContextCtl() -> WordToContextCtl {
    let ctl = WordToContextCtl()
    ctl.firstGlyphOriginBeforeFullContent = CGPointMake(30, 10)
    ctl.fullContent = "When the user taps in an editable text view, that text view becomes the first responder and automatically asks the system to display the associated keyboard. Because the appearance of the keyboard has the potential to obscure portions of your user interface, it is up to you to make sure that does not happen by repositioning any views that might be obscured. Some system views, like table views, help you by scrolling the first responder into view automatically. If the first responder is at the bottom of the scrolling region, however, you may still need to resize or reposition the scroll view itself to ensure the first responder is visible."
    ctl.text = "Some system views, like table views, help you by scrolling the first responder into view automatically. If the first responder is at the bottom of the scrolling region, however, you may still need to resize or reposition the scroll view itself to ensure the first responder is visible."
    ctl.fullContentA = NSMutableAttributedString(string: ctl.fullContent as String)
    ctl.textA = NSMutableAttributedString(string: ctl.text as String)
    return ctl
}

class WordToContextCtl: UIViewController {
    var isShowingFullContent = false
    var base: UIScrollView!
    
    var fullContent: NSString!
    var fullContentA: NSAttributedString!
    var textColor = UIColor.greenColor()
    var text: NSString! // Mismatched text (text not in fullContent), should be handled before use this ctl.
    var textA: NSAttributedString!
    
    var sizeShownForFullContent: CGSize!
    var visiableRect: CGRect {
        return CGRectMake((view.frame.width - sizeShownForFullContent.width) / 2, (view.frame.height - sizeShownForFullContent.height) / 2, sizeShownForFullContent.width, sizeShownForFullContent.height)
    }
    var viewWithFullContent: UITextView! // Final status for the textView
    var firstGlyphOriginBeforeFullContent: CGPoint! // In ctl.view's coordinates.
    
    var firstGlyphOriginAfterFullContent: CGPoint! { // In ctl.view's coordinates.
        return view.convertPoint(boundingRectOriginForGlyphRange(viewWithFullContent, NSMakeRange(textGlyphRangeInFullContentView.location, 1)), fromView: viewWithFullContent)
    }
    var distanceToMoveToFullContent: CGPoint { // Use point as a container to store distances on both directions.
        return CGPointMake(firstGlyphOriginAfterFullContent.x - firstGlyphOriginBeforeFullContent.x, firstGlyphOriginAfterFullContent.y - firstGlyphOriginBeforeFullContent.y)
    }
    
    var animatedLineTextViews: [AnimatableOneLineTextView]! // To animate each line's changes.
    var animatedLineExtraTextViews: [AnimatableOneLineTextView]! // To animate each line's adaption to line wrap.
    
    
    override func loadView() {
        view = UIView(frame: CGRectMake(0, 0, sizeShownForFullContent.width, sizeShownForFullContent.height))
        viewWithFullContent = getViewWithFullContent(10)
        view.addSubview(viewWithFullContent)
        let textRectInFullContentView = viewWithFullContent.layoutManager.boundingRectForGlyphRange(textGlyphRangeInFullContentView, inTextContainer: viewWithFullContent.textContainer)
        base = UIScrollView(frame: view.frame)
        base.contentSize = CGSizeMake(view.frame.width, view.frame.height * 3)
        base.contentOffset = CGPointMake(0, view.frame.height)
    }
}

// MARK: - Animatable textView

class AnimatableTextViewCtl: UIViewController, UIScrollViewDelegate {
    var originalViewToMock: UITextView! // Prerequisite
    var highlightColor = UIColor.blackColor()
    var normalColor = UIColor.grayColor()
    var attriTextToHighlight: NSMutableAttributedString! // Prerequisite
    var attriFullText: NSMutableAttributedString! // Prerequisite
    var maxWidth: CGFloat! // Prerequisite
    
    var glyphRangesInOriginalViewToMock = [NSRange]()
    var lineRectsInOriginalViewToMock = [CGRect]()
    var lastGlyphIndexesInLinesInOriginalViewToMock: [Int] {
        var i = [Int]()
        for r in glyphRangesInOriginalViewToMock {
            i.append(r.location + r.length - 1)
        }
        return i
    }
    var firstExtraGlyphIndexesInLinesInOriginalViewToMock: [Int] {
        var i = [Int]()
        for r in glyphRangesInOriginalViewToMock {
            i.append(r.location + r.length)
        }
        return i
    }
    var highlightedTextCharacterRange: NSRange {
        get {
            return (attriFullText.string as NSString).rangeOfString(attriTextToHighlight.string as String)
        }
    }
    var highlightedTextGlyphRangeInOriginalViewToMock: NSRange {
        get {
            return originalViewToMock.layoutManager.glyphRangeForCharacterRange(highlightedTextCharacterRange, actualCharacterRange: nil)
        }
    }
    
    var animatedLineMainViews = [AnimatableOneLineTextView]()
    var animatedLineExtraViews = [AnimatableOneLineTextView]()
    var animatedLineViews: [AnimatableOneLineTextView] {
        return animatedLineMainViews + animatedLineExtraViews
    }
    var isExpanded = false
    // Transition
    func transitToExpanded(animated: Bool) {
        animatedLineExtraViews[0].adjustToMatchLineWrap(animated)
    }
    func transitToCollapsed(animated: Bool) {
        let a = animatedLineExtraViews.reverse()
        let b = animatedLineMainViews.reverse()
        for v in a {
            for k in v.nextLineExtraTextViewsInChain {
                k.setContentOffset(CGPointMake(k.contentOffset.x - v.extraXTiggere, k.contentOffset.y), animated: true)
            }
        }
    }
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if scrollView.isKindOfClass(AnimatableOneLineTextView) {
            let s = scrollView as! AnimatableOneLineTextView
            if let i = find(animatedLineExtraViews, s) {
                if i + 1 < animatedLineExtraViews.count {
                    animatedLineExtraViews[i + 1].adjustToMatchLineWrap(true)
                }
            }
        }
    }
    // Refresh animatableLines
    func refreshLines() {
        refreshLinesInfo()
        refreshAnimatableOneLineTextViews(&animatedLineMainViews)
        refreshAnimatableOneLineTextViews(&animatedLineExtraViews)
    }
    func refreshAnimatableOneLineTextViews(inout views: [AnimatableOneLineTextView]) {
        // Match the number of views.
        var y = views.count - lineRectsInOriginalViewToMock.count
        if y > 0 {
            do {
                views.last!.removeFromSuperview()
                views.removeLast()
                y--
            } while y > 0
        } else if y < 0 {
            var i = 0
            for r in glyphRangesInOriginalViewToMock {
                if i + 1 > views.count {
                    let l = getOneAnimatableOneLineTextView(lineRectsInOriginalViewToMock[i].origin, width: view.frame.width, height: view.frame.height)
                    l.delegate = self
                    view.addSubview(l)
                    views.append(l)
                }
                i++
            }
        }
        // Adjust appearance.
        if views.count > 0 {
            var j = 0
            let isForMain = views[0].isEqual(animatedLineMainViews[0]) ? true : false
            for v in views {
                // Reset contentOffset
                v.setContentOffset(CGPointMake(-view.frame.width * CGFloat(j), 0), animated: false)
                // Reset visiability.
                let charRange = isForMain ? NSMakeRange(0, lastGlyphIndexesInLinesInOriginalViewToMock[j]) : NSMakeRange(firstExtraGlyphIndexesInLinesInOriginalViewToMock[j], (v.textView.attributedText.string as NSString).length - firstExtraGlyphIndexesInLinesInOriginalViewToMock[j])
                v.textView.attributedText = setGlyphsVisiability(v.textView.attributedText, charRange, highlightColor)
                j++
            }
        }
    }
    func refreshLinesInfo() {
        glyphRangesInOriginalViewToMock.removeAll(keepCapacity: true)
        lineRectsInOriginalViewToMock.removeAll(keepCapacity: true)
        let s = originalViewToMock.attributedText.string as NSString
        let g = originalViewToMock.layoutManager.glyphRangeForCharacterRange(NSMakeRange(0, s.length), actualCharacterRange: nil)
        if g.length > 0 {
            var lineNo = 0
            do {
                let lastLineRect = lineNo > 0 ? lineRectsInOriginalViewToMock[lineNo - 1] : CGRectZero
                let lineGlyphRange = originalViewToMock.layoutManager.glyphRangeForBoundingRect(CGRectMake(0, lastLineRect.maxY + 1, 1, 1), inTextContainer: originalViewToMock.textContainer)
                let lineRect = originalViewToMock.layoutManager.boundingRectForGlyphRange(lineGlyphRange, inTextContainer: originalViewToMock.textContainer)
                glyphRangesInOriginalViewToMock.append(lineGlyphRange)
                lineRectsInOriginalViewToMock.append(lineRect)
                lineNo++
            } while g.length > (lineNo == 0 ? 0 : glyphRangesInOriginalViewToMock.last!.location + glyphRangesInOriginalViewToMock.last!.length - 1)
        }
    }
    
    func getOneAnimatableOneLineTextView(origin: CGPoint, width: CGFloat = 2000, height: CGFloat = 100) -> AnimatableOneLineTextView {
        var r = UITextView(frame: CGRectMake(0, 0, width, height))
        configTextView(r)
        r.attributedText = attriFullText
        return AnimatableOneLineTextView(textViewToInsert: r, rect: CGRectMake(origin.x, origin.y, width, height))
    }
    func configTextView(view: UITextView) {
        view.backgroundColor = UIColor.clearColor()
        view.contentInset = UIEdgeInsetsZero
        view.textContainer.lineFragmentPadding = 0
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
    }
    func getCharacterRangeFullContentViewForRect(rect: CGRect) -> NSRange {
        return originalViewToMock.layoutManager.characterRangeForGlyphRange(originalViewToMock.layoutManager.glyphRangeForBoundingRect(rect, inTextContainer: originalViewToMock.textContainer), actualGlyphRange: nil)
    }
}

// MARK: - Animatable Line

class AnimatableOneLineTextView: UIScrollView {
    var textView: UITextView!
    var nextLineTextViewsInChain: [AnimatableOneLineTextView]!
    var nextLineExtraTextViewsInChain: [AnimatableOneLineTextView]!
    var nextViews: [AnimatableOneLineTextView] {
        get {
            return nextLineTextViewsInChain + nextLineExtraTextViewsInChain
        }
    }
    override func setContentOffset(contentOffset: CGPoint, animated: Bool) {
        baseContentOffsetX = contentOffset.x
        super.setContentOffset(contentOffset, animated: animated)
    }
    var baseContentOffsetX: CGFloat!
    var extraXTiggered = CGFloat(0) // Store distance moved triggered by this on x axis.
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
    init(textViewToInsert: UITextView, rect: CGRect) {
        super.init(frame: CGRectMake(rect.origin.x, rect.origin.y, rect.width, rect.height))
        contentSize = CGSizeMake(textViewToInsert.frame.width * 3, textViewToInsert.frame.height)
        textView = textViewToInsert
        addSubview(textView)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // There are two stage of the transition: 1. every SyncedTextView changes its contentOffset synchronistically till expected position for first glyph in the text range is reached 2. adjust line wrap one line after another. This method is used on stage 2. So it's only used on extraTextView.
    func adjustToMatchLineWrap(animated: Bool) {
        if nextLineExtraTextViewsInChain.count > 1 {
            var r0 = nextLineTextViewsInChain
            r0.removeAtIndex(0)
            var r1 = nextLineExtraTextViewsInChain
            r1.removeAtIndex(0)
            nextLineExtraTextViewsInChain[0].nextLineTextViewsInChain = r0
            nextLineExtraTextViewsInChain[0].nextLineExtraTextViewsInChain = r1
        } else {
            return
        }
        for v in nextViews {
            v.baseContentOffsetX = v.contentOffset.x
        }
        if visiableGlyphsRectX >= contentOffset.x + frame.width {
            // Whole visiable part is not visiable now.
            proceedToNext(animated)
        } else {
            // Visiable part is still visiable.
            isTrigger = true
            baseContentOffsetX = contentOffset.x
            extraXTiggered = visiableGlyphsRectX - contentOffset.x
            setContentOffset(CGPointMake(visiableGlyphsRectX, contentOffset.y) , animated: animated)
            if !animated {
                updateFollowersContentOffset()
                proceedToNext(animated)
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if isTrigger {
            updateFollowersContentOffset()
        }
    }
    func proceedToNext(animated: Bool) {
        if nextLineExtraTextViewsInChain.count > 0 {
            nextLineExtraTextViewsInChain[0].adjustToMatchLineWrap(animated)
        }
    }
    func updateFollowersContentOffset() {
        for v in nextViews {
            v.contentOffset = CGPointMake(v.baseContentOffsetX + extraXTiggered, v.contentOffset.y)
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
