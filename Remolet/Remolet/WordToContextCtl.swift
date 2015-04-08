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

func testAnimatableTextViewCtl(onCtl: RootViewCtl, viewToAttachOn: UIView) -> AnimatableTextViewCtl {
    let ctl = AnimatableTextViewCtl()
    let oX = CGFloat(20)
    let oY = CGFloat(40)
    let o = UITextView(frame: CGRectMake(oX, oY, appRect.width - oX * 2, appRect.height - oY))
    let fullContent = "When the user taps in an editable text view, that text view becomes the first responder and automatically asks the system to display the associated keyboard. Because the appearance of the keyboard has the potential to obscure portions of your user interface, it is up to you to make sure that does not happen by repositioning any views that might be obscured. Some system views, like table views, help you by scrolling the first responder into view automatically. If the first responder is at the bottom of the scrolling region, however, you may still need to resize or reposition the scroll view itself to ensure the first responder is visible."
    o.attributedText = NSAttributedString(string: fullContent)
    o.contentInset = UIEdgeInsetsZero
    o.textContainer.lineFragmentPadding = 0
    o.showsHorizontalScrollIndicator = false
    o.showsVerticalScrollIndicator = false
    ctl.originalViewToMock = o
    ctl.maxWidth = o.frame.width
    ctl.attriFullText = NSMutableAttributedString(string: o.attributedText.string)
    ctl.attriTextToHighlight = NSMutableAttributedString(string: "Some system views, like table views, help you by scrolling the first responder into view automatically. If the first responder is at the bottom of the scrolling region, however, you may still need to resize or reposition the scroll view itself to ensure the first responder is visible.")
    viewToAttachOn.addSubview(o)
    o.hidden = true
    o.backgroundColor = UIColor.greenColor()
    onCtl.addChildViewController(ctl)
    ctl.didMoveToParentViewController(onCtl)
    viewToAttachOn.addSubview(ctl.view)
    
    var tap = UITapGestureRecognizer(target: ctl, action: "expandByTap")
    ctl.view.addGestureRecognizer(tap)
    return ctl
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
    
    override func loadView() {
        view = UIView(frame: originalViewToMock.frame)
        refreshLines()
    }
    
    // Transition
    func transitToCollapsedAtLanuch() {
        transitToExpanded(false)
        transitToCollapsed(true)
    }
    func expandByTap() {
        transitToExpanded(true)
    }
    func transitToExpanded(animated: Bool) {
        animatedLineExtraViews[0].adjustToMatchLineWrap(animated)
        if !animated {
            isExpanded = true
        }
    }
    func transitToCollapsed(animated: Bool) {
        if animatedLineExtraViews.count > 0 {
            let a = animatedLineExtraViews.reverse()
            a[0].setContentOffset(CGPointMake(a[0].contentOffset.x - a[0].extraXTiggered, a[0].contentOffset.y), animated: true)
        }
    }
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if scrollView.isKindOfClass(AnimatableOneLineTextView) {
            let s = scrollView as! AnimatableOneLineTextView
            if let i = find(animatedLineExtraViews, s) {
                if isExpanded {
                    if i - 1 >= 0 {
                        animatedLineExtraViews[i - 1].setContentOffset(CGPointMake(animatedLineExtraViews[i - 1].contentOffset.x - animatedLineExtraViews[i - 1].extraXTiggered, animatedLineExtraViews[i - 1].contentOffset.y), animated: true)
                    } else {
                        isExpanded = false
                    }
                } else {
                    if i + 1 < animatedLineExtraViews.count {
                        animatedLineExtraViews[i + 1].adjustToMatchLineWrap(true)
                    } else {
                        isExpanded = true
                    }
                }
            }
        }
    }
    // Refresh animatableLines
    func refreshLines() {
        refreshLinesInfo()
        refreshAnimatableOneLineTextViews(&animatedLineMainViews)
        refreshAnimatableOneLineTextViews(&animatedLineExtraViews)
        if animatedLineExtraViews.count > 0 {
            var r0 = animatedLineMainViews
            r0.removeAtIndex(0)
            (animatedLineExtraViews[0] as AnimatableOneLineTextView).nextLineTextViewsInChain = r0
            var r1 = animatedLineExtraViews
            r1.removeAtIndex(0)
            (animatedLineExtraViews[0] as AnimatableOneLineTextView).nextLineExtraTextViewsInChain = r1
        }
    }
    func refreshAnimatableOneLineTextViews(inout views: [AnimatableOneLineTextView]) {
        // Match the number of views.
        var y = views.count - lineRectsInOriginalViewToMock.count
        if y > 0 {
            while y > 0 {
                views.last!.removeFromSuperview()
                views.removeLast()
                y--
            }
        } else if y < 0 {
            var i = 0
            for r in glyphRangesInOriginalViewToMock {
                if i + 1 > views.count {
                    let l = getOneAnimatableOneLineTextView(CGPointMake(lineRectsInOriginalViewToMock[0].origin.x, lineRectsInOriginalViewToMock[i].origin.y))
                    l.delegate = self
//                    l.alpha = 0.8
//                    l.backgroundColor = UIColor.redColor()
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
                v.setContentOffset(CGPointMake(view.frame.width * CGFloat(j), 0), animated: false)
                // Reset visiability.
                let charRange = isForMain ? NSMakeRange(0, lastGlyphIndexesInLinesInOriginalViewToMock[j] + 1) : NSMakeRange(firstExtraGlyphIndexesInLinesInOriginalViewToMock[j], (v.textView.attributedText.string as NSString).length - firstExtraGlyphIndexesInLinesInOriginalViewToMock[j])
                v.textView.attributedText = setGlyphsVisiability(attriFullText, charRange, highlightColor)
                v.visiableCharacterRange = charRange
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
            var lineIndex = 0
            while g.length > (lineIndex == 0 ? 0 : glyphRangesInOriginalViewToMock.last!.location + glyphRangesInOriginalViewToMock.last!.length) {
                let lastLineRect = lineIndex > 0 ? lineRectsInOriginalViewToMock[lineIndex - 1] : CGRectZero
                let lineGlyphRange = originalViewToMock.layoutManager.glyphRangeForBoundingRect(CGRectMake(0, lastLineRect.maxY + 1, 1, 1), inTextContainer: originalViewToMock.textContainer)
                let lineRect = originalViewToMock.layoutManager.boundingRectForGlyphRange(lineGlyphRange, inTextContainer: originalViewToMock.textContainer)
                glyphRangesInOriginalViewToMock.append(lineGlyphRange)
                lineRectsInOriginalViewToMock.append(lineRect)
                lineIndex++
            }
        }
        
    }
    
    func getOneAnimatableOneLineTextView(origin: CGPoint, width: CGFloat = 10000, height: CGFloat = 100) -> AnimatableOneLineTextView {
        var r = UITextView(frame: CGRectMake(0, 0, width, height))
        configTextView(r)
        r.attributedText = attriFullText
        return AnimatableOneLineTextView(textViewToInsert: r, rect: CGRectMake(origin.x, origin.y, view.frame.width - origin.x * 2, height))
    }
    func configTextView(view: UITextView) {
        view.backgroundColor = UIColor.clearColor()
//        view.alpha = 0.5
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
    var nextLineTextViewsInChain: [AnimatableOneLineTextView]! // Prerequisite for nextLineExtraTextViewsInChain items
    var nextLineExtraTextViewsInChain: [AnimatableOneLineTextView]! // Prerequisite for nextLineExtraTextViewsInChain items
    var nextViews: [AnimatableOneLineTextView] {
        return nextLineTextViewsInChain + nextLineExtraTextViewsInChain
    }
    var baseContentOffsetX: CGFloat!
    var extraXTiggered = CGFloat(0) // Store distance moved triggered by this on x axis.
    var isTrigger = false
    var xDifferenceToLastView: CGFloat!
    var visiableCharacterRange: NSRange! // Used by lineExtraView to hide the visiable part.
    var visiableGlyphRange: NSRange {
        return textView.layoutManager.glyphRangeForCharacterRange(visiableCharacterRange, actualCharacterRange: nil)
    }
    var visiableGlyphsRectX: CGFloat {
        return textView.frame.origin.x + textView.textContainer.lineFragmentPadding + textView.textContainerInset.left + textView.layoutManager.boundingRectForGlyphRange(visiableGlyphRange, inTextContainer: textView.textContainer).origin.x
    }
    init(textViewToInsert: UITextView, rect: CGRect) {
        super.init(frame: rect)
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
        baseContentOffsetX = contentOffset.x
        for v in nextViews {
            v.baseContentOffsetX = v.contentOffset.x
        }
        if visiableGlyphsRectX >= contentOffset.x + frame.width {
            // Whole visiable part is not visiable now.
            proceedToNext(animated)
        } else {
            // Visiable part is still visiable.
            isTrigger = true
            extraXTiggered = visiableGlyphsRectX - contentOffset.x - frame.width
            println("extraXTiggered: \(extraXTiggered)")
            setContentOffset(CGPointMake(baseContentOffsetX + extraXTiggered, contentOffset.y), animated: animated)
            if !animated {
                updateFollowersContentOffset(contentOffset.x - baseContentOffsetX)
                proceedToNext(animated)
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if isTrigger {
            println("delta: \(contentOffset.x - baseContentOffsetX)")
            updateFollowersContentOffset(contentOffset.x - baseContentOffsetX)
        }
    }
    func proceedToNext(animated: Bool) {
        if nextLineExtraTextViewsInChain.count > 0 {
            nextLineExtraTextViewsInChain[0].adjustToMatchLineWrap(animated)
        }
    }
    func updateFollowersContentOffset(deltaOnX: CGFloat) {
        for v in nextViews {
            v.contentOffset = CGPointMake(v.baseContentOffsetX + deltaOnX, v.contentOffset.y)
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
    s.addAttribute(NSForegroundColorAttributeName, value: UIColor.clearColor(), range: NSMakeRange(0, (s.string as NSString).length))
    s.addAttribute(NSForegroundColorAttributeName, value: color, range: charRange)
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
