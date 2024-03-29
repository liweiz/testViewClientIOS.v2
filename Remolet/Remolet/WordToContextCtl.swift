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
    return setupAnimatableTextViewCtl(onCtl, viewToAttachOn, "When the user taps in an editable text view, that text view becomes the first responder and automatically asks the system to display the associated keyboard. Because the appearance of the keyboard has the potential to obscure portions of your user interface, it is up to you to make sure that does not happen by repositioning any views that might be obscured. Some system views, like table views, help you by scrolling the first responder into view automatically. If the first responder is at the bottom of the scrolling region, however, you may still need to resize or reposition the scroll view itself to ensure the first responder is visible.", "Some system views, like table views, help you by scrolling the first responder into view automatically. If the first responder is at the bottom of the scrolling region, however, you may still need to resize or reposition the scroll view itself to ensure the first responder is visible.")
}

func setupAnimatableTextViewCtl(onCtl: RootViewCtl, viewToAttachOn: UIView, fullContent: String, toHighlight: String) -> AnimatableTextViewCtl {
    let ctl = AnimatableTextViewCtl()
    let oX = CGFloat(70)
    let oY = CGFloat(40)
    ctl.firstGlyphOriginFromListInCtlView = CGPointMake(oX, oY)
    let o = UITextView(frame: CGRectMake(oX, oY, appRect.width - oX * 2, appRect.height - oY))
    o.attributedText = NSAttributedString(string: fullContent)
    o.contentInset = UIEdgeInsetsZero
    o.textContainer.lineFragmentPadding = 0
    o.showsHorizontalScrollIndicator = false
    o.showsVerticalScrollIndicator = false
    ctl.originalViewToMock = o
    ctl.attriTextToHighlight = NSMutableAttributedString(string: toHighlight)
    viewToAttachOn.addSubview(o)
    o.hidden = true
    o.backgroundColor = UIColor.greenColor()
    onCtl.addChildViewController(ctl)
    ctl.didMoveToParentViewController(onCtl)
    viewToAttachOn.addSubview(ctl.view)
    
    
    
    ctl.verticalAdjuster = UIScrollView(frame: ctl.view.frame)
    ctl.verticalAdjuster.contentSize = CGSizeMake(ctl.verticalAdjuster.frame.width, ctl.verticalAdjuster.frame.height * 3)
    ctl.verticalAdjuster.contentOffset = CGPointMake(0, ctl.verticalAdjuster.frame.height)
    ctl.view.addSubview(ctl.verticalAdjuster)
    
    var tap = UITapGestureRecognizer(target: ctl, action: "expandByTap")
    ctl.view.addGestureRecognizer(tap)
    return ctl
}

// MARK: - Animatable textView

class AnimatableTextViewCtl: UIViewController, UIScrollViewDelegate {
    var firstGlyphOriginFromListInCtlView: CGPoint! // Prerequisite
    
    var originalViewToMock: UITextView! // Prerequisite
    var attriTextToHighlight: NSMutableAttributedString! // Prerequisite
    
    var verticalAdjuster: UIScrollView!
    var highlightColor = UIColor.blackColor()
    
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
    var highlightedTextGlyphRangeInOriginalViewToMock: NSRange {
        return originalViewToMock.layoutManager.glyphRangeForCharacterRange(highlightedTextCharacterRange, actualCharacterRange: nil)
    }
    var highlightedTextCharacterRange: NSRange {
        return (originalViewToMock.attributedText!.string as NSString).rangeOfString(attriTextToHighlight.string as String)
    }
    
    var animatedLineMainViews = [AnimatableOneLineTextView]()
    var animatedLineExtraViews = [AnimatableOneLineTextView]()
    var animatedLineViews: [AnimatableOneLineTextView] {
        return animatedLineMainViews + animatedLineExtraViews
    }
    var isExpanded = false
    var animateHighlightOnly = true
    
    func getFirstHighlightedGlyphOriginInOneAnimatableOneLineTextView(view: AnimatableOneLineTextView) -> CGPoint {
        return view.textView.layoutManager.boundingRectForGlyphRange(view.textView.layoutManager.glyphRangeForCharacterRange(highlightedTextCharacterRange, actualCharacterRange: nil), inTextContainer: view.textView.textContainer).origin
    }
    
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
        view.userInteractionEnabled = false
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
                    view.addSubview(l)
                    views.append(l)
                }
                i++
            }
        }
        // Adjust appearance.
        refreshAppearance(&views)
    }
    func refreshAppearance(inout views: [AnimatableOneLineTextView]) {
        if views.count > 0 {
            var j = 0
            let isForMain = views[0].isEqual(animatedLineMainViews[0]) ? true : false
            var o = CGFloat(0)
            if views.count > 0 {
                let k = views[0].convertPoint(firstGlyphOriginFromListInCtlView, fromView: view)
                o = getFirstHighlightedGlyphOriginInOneAnimatableOneLineTextView(views[0]).x - k.x
            }
            for v in views {
                // Reset contentOffset
                v.setContentOffset(CGPointMake(o + view.frame.width * CGFloat(j), 0), animated: false)
                // Reset visiability.
                let charRange = isForMain ? NSMakeRange(highlightedTextCharacterRange.location, lastGlyphIndexesInLinesInOriginalViewToMock[j] - highlightedTextCharacterRange.location + 1) : NSMakeRange(firstExtraGlyphIndexesInLinesInOriginalViewToMock[j], (v.textView.attributedText.string as NSString).length - firstExtraGlyphIndexesInLinesInOriginalViewToMock[j])
                v.textView.attributedText = setGlyphsVisiability(originalViewToMock.attributedText!, charRange, highlightColor)
                v.visiableCharacterRange = charRange
                j++
            }
        }
    }
    func refreshLinesInfo() {
        glyphRangesInOriginalViewToMock.removeAll(keepCapacity: true)
        lineRectsInOriginalViewToMock.removeAll(keepCapacity: true)
        let s = originalViewToMock.attributedText.string as NSString
        let g = animateHighlightOnly ? getGlyphRangeForTextOccupiedLines(attriTextToHighlight, originalViewToMock) : originalViewToMock.layoutManager.glyphRangeForCharacterRange(NSMakeRange(0, s.length), actualCharacterRange: nil)
        if g.length > 0 {
            var lastRect = CGRectZero
            while g.location + g.length > (glyphRangesInOriginalViewToMock.count > 0 ? glyphRangesInOriginalViewToMock.last!.location + glyphRangesInOriginalViewToMock.last!.length : 0) {
                let lineGlyphRange = originalViewToMock.layoutManager.glyphRangeForBoundingRect(CGRectMake(0, lastRect.maxY + 1, 1, 1), inTextContainer: originalViewToMock.textContainer)
                lastRect = originalViewToMock.layoutManager.boundingRectForGlyphRange(lineGlyphRange, inTextContainer: originalViewToMock.textContainer)
                if NSIntersectionRange(lineGlyphRange, highlightedTextGlyphRangeInOriginalViewToMock).length > 0 {
                    glyphRangesInOriginalViewToMock.append(lineGlyphRange)
                    lineRectsInOriginalViewToMock.append(lastRect)
                }
            }
        }
    }
    func getOneAnimatableOneLineTextView(origin: CGPoint, width: CGFloat = 10000, height: CGFloat = 100) -> AnimatableOneLineTextView {
        var r = UITextView(frame: CGRectMake(0, 0, width, height))
        configTextView(r)
        r.attributedText = originalViewToMock.attributedText!
        return AnimatableOneLineTextView(textViewToInsert: r, rect: CGRectMake(origin.x, origin.y, view.frame.width - origin.x * 2, height))
    }
    func configTextView(view: UITextView) {
        view.backgroundColor = UIColor.clearColor()
        view.contentInset = UIEdgeInsetsZero
        view.textContainer.lineFragmentPadding = 0
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
    }
}

func adjustToMatchLineMove(isForWrap: Bool, viewFollowed: AnimatableOneLineTextView, mainViews: [AnimatableOneLineTextView], extraViews: [AnimatableOneLineTextView]) {
    if let i = find(mainViews, viewFollowed) {
        var followings = isForWrap ? [AnimatableOneLineTextView]() : [extraViews[i]]
        followings = mainViews.filter{ find(mainViews, $0)! > i }
        if followings.count == 0 { return }
        followings = followings + extraViews.filter{ find(extraViews, $0)! > i }
        if isForWrap {
            
        }
        syncFollowingViews(viewFollowed, followings)
    }
}

func adjustToMatchLineWrap(animated: Bool, mainViews: [AnimatableOneLineTextView], extraViews: [AnimatableOneLineTextView]) {
    for m in mainViews {
        if let i = find(mainViews, m) {
            var next = mainViews.filter{ find(mainViews, $0)! > i }
            if next.count == 0 { return }
            var nextExtra = extraViews.filter{ find(extraViews, $0)! > i }
            m.baseContentOffsetX = m.contentOffset.x
            updateFollowingViewsBaseContentOffsetX(m, next + nextExtra)
            if m.visiableGlyphsRectX < m.contentOffset.x + m.frame.width { // Visiable part is still visiable.
                m.isTrigger = true
                m.extraXTiggered = m.visiableGlyphsRectX - m.contentOffset.x - m.frame.width
                m.setContentOffset(CGPointMake(m.baseContentOffsetX + m.extraXTiggered, m.contentOffset.y), animated: animated) // Animated move synces one by one after the previous one finishes.
                if !animated {
                    syncFollowingViews(m, next + nextExtra)
                }
            }
        }
    }
}



func updateFollowingViewsBaseContentOffsetX(viewFollowed: AnimatableOneLineTextView, followingViews: [AnimatableOneLineTextView]) {
    for v in followingViews {
        v.baseContentOffsetX = v.contentOffset.x
    }
}

func syncFollowingViews(viewFollowed: AnimatableOneLineTextView, followingViews: [AnimatableOneLineTextView]) {
    for v in followingViews {
        v.contentOffset = CGPointMake(v.baseContentOffsetX + viewFollowed.contentOffset.x - viewFollowed.baseContentOffsetX, v.contentOffset.y)
    }
}

// MARK: - Animatable Line

class AnimatableOneLineTextView: UIScrollView {
    var textView: UITextView!
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
        decelerationRate = UIScrollViewDecelerationRateFast
        contentSize = CGSizeMake(textViewToInsert.frame.width * 3, textViewToInsert.frame.height)
        textView = textViewToInsert
        addSubview(textView)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // There are two stage of the transition: 1. every SyncedTextView changes its contentOffset synchronistically till expected position for first glyph in the text range is reached 2. adjust line wrap one line after another. This method is used on stage 2. So it's only used on extraTextView.
    override func layoutSubviews() {
        super.layoutSubviews()
        if isTrigger {
            updateFollowersContentOffset(contentOffset.x - baseContentOffsetX)
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
