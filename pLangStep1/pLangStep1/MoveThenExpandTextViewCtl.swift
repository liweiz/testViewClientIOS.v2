//
//  MoveThenExpandTextViewCtl.swift
//  pLangStep1
//
//  Created by Liwei Zhang on 2015-08-02.
//  Copyright © 2015 Liwei Zhang. All rights reserved.
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


class MoveThenExpandTextViewCtl: UIViewController, NSLayoutManagerDelegate {
    var fullContent: NSString!
    var fullContentA: NSAttributedString!
    var fullContentStorage: NSTextStorage!
    var text: NSString! // Mismatched text (text not in fullContent), should be handled before use this ctl.
    var textA: NSAttributedString!
    var base: MoveThenExpandTextView!
    var rectSizeToShowOn: CGSize!
    var textStartFromLeft = true
    let initialHiddenWidth = CGFloat(5000)
    var textViewToShow: UITextView!
    var textViewHidden: UITextView!
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
            var tempView = getTextViewToShow(20, isFinal: true)
            return CGPointMake(tempView.frame.origin.x + initialBaseContentOffset.x, tempView.frame.origin.y + initialBaseContentOffset.y)
        }
    }
    var initialStatus = false
    var finalStatus = false
    override func loadView() {
        fullContentA = NSAttributedString(string: fullContent as String)
        textA = NSAttributedString(string: text as String)
        fullContentStorage = NSTextStorage(string: fullContent as String)
        initialBaseContentOffset = CGPointMake(rectSizeToShowOn.width, rectSizeToShowOn.height)
        view = UIView(frame: CGRectMake(0, 0, rectSizeToShowOn.width, rectSizeToShowOn.height))
        view.backgroundColor = UIColor.purpleColor()
        base = MoveThenExpandTextView(frame: CGRectMake(0, 0, rectSizeToShowOn.width, rectSizeToShowOn.height))
        // Make it large enough in all directions to
        base.contentSize = CGSizeMake(base.frame.width * 3, base.frame.height * 3)
        base.backgroundColor = UIColor.grayColor()
        base.initialContentOffset = initialBaseContentOffset
        base.contentOffset = initialBaseContentOffset
        
        // textViews
        textViewHidden = getTextViewHidden()
        textViewToShow = getTextViewToShow(10, isFinal: false)
        base.textViewToShow = textViewToShow
        base.textViewHidden = textViewHidden
        textViewHidden.attributedText = fullContentA.attributedSubstringFromRange(NSMakeRange(0, fullContentA.length - textA.length))
        textViewToShow.backgroundColor = UIColor.clearColor()
        
        adjustTextViewOriginToMatch(initialGlyphBeginPointInBase, view: textViewToShow)
        initialViewOriginInBase = textViewToShow.frame.origin
        //        base.userInteractionEnabled = false
        view.addSubview(base)
        base.addSubview(textViewHidden)
        base.addSubview(textViewToShow)
        let tap = UITapGestureRecognizer(target: self, action: "launchAnimation")
        view.addGestureRecognizer(tap)
    }
    func adjustTextViewOriginToMatch(glyphPointInBase: CGPoint, view: UITextView) {
        view.frame = CGRectMake(glyphPointInBase.x - (view.textContainerInset.left + view.textContainer.lineFragmentPadding), glyphPointInBase.y - view.textContainerInset.top, view.frame.width, view.frame.height)
    }
    func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        if layoutFinishedFlag {
            if layoutManager.isEqual(textViewHidden.layoutManager) {
                // Initial adjustment
                if textViewHidden.textContainer.size.width == initialHiddenWidth {
                    // Shrink hidden's width
                    textViewHidden.textContainer.size = CGSizeMake(textViewHidden.layoutManager.usedRectForTextContainer(textViewHidden.textContainer).width, textViewHidden.frame.height)
                }
                // Update shown every time after hidden's been updated
                let usedRange = textViewHidden.layoutManager.characterRangeForGlyphRange(textViewHidden.layoutManager.glyphRangeForBoundingRect(CGRectMake(0, 0, 5, 5), inTextContainer: textViewHidden.textContainer), actualGlyphRange: nil)
                textViewToShow.attributedText = fullContentA.attributedSubstringFromRange(NSMakeRange(usedRange.length, fullContentA.length - usedRange.length))
            } else if layoutManager.isEqual(textViewToShow.layoutManager) {
                
            }
        }
    }
    func launchAnimation() {
        initialStatus = true
        if initialStatus {
            if textViewHidden.frame.width == initialHiddenWidth {
                textViewHidden.frame = CGRectMake(textViewHidden.frame.origin.x, textViewHidden.frame.origin.y, textViewHidden.textContainer.size.width, textViewHidden.frame.height)
            }
            base.initialViewOrigin = textViewToShow.frame.origin
            base.shownViewOrigin = shownPoint
            base.initialTextHiddenWidth = textViewHidden.frame.width
            base.readyToMove = true
            base.moveAwayFromInitialPoint()
        } else if finalStatus {
            
        }
    }
    func getTextViewHidden() -> UITextView {
        var r = UITextView(frame: CGRectMake(0, 0, initialHiddenWidth, base.frame.height))
        configTextView(r)
        return r
    }
    func getTextViewToShow(gap: CGFloat, isFinal: Bool) -> UITextView {
        var r = UITextView(frame: CGRectMake(gap, 0, rectSizeToShowOn.width - gap * 2, base.frame.height))
        configTextView(r)
        if isFinal {
            r.attributedText = fullContentA
            r.frame.origin = CGPointMake(gap, (rectSizeToShowOn.height - r.layoutManager.usedRectForTextContainer(r.textContainer).height) / 2)
        }
        return r
    }
    func configTextView(view: UITextView) {
        view.contentInset = UIEdgeInsetsZero
        view.textContainer.lineBreakMode = NSLineBreakMode.ByCharWrapping
        view.textContainer.lineFragmentPadding = 0
        view.layoutManager.delegate = self
        view.userInteractionEnabled = false
    }
}


class MoveThenExpandTextView: UIScrollView, UIScrollViewDelegate {
    var readyToMove = false
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
            return CGPointMake(initialContentOffset.x - (shownViewOrigin.x - initialViewOrigin.x), initialContentOffset.y - (shownViewOrigin.y - initialViewOrigin.y))
        }
    }
    override func layoutSubviews() {
        if readyToMove {
            textViewHidden.frame = CGRectMake(textViewHidden.frame.origin.x, textViewHidden.frame.origin.y, (1 - abs(contentOffset.y - initialViewOrigin.y) / yDistance) * initialTextHiddenWidth, textViewHidden.frame.height)
            print("abs: \(abs(contentOffset.y - initialViewOrigin.y))")
        }
    }
    required init?(coder aDecoder: NSCoder) {
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
    //    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
    //        readyToMove = true
    //    }
}





func getAttributedStringLeft(fullString: NSAttributedString, layoutMgr: NSLayoutManager) -> NSAttributedString {
    return fullString.attributedSubstringFromRange(NSMakeRange(layoutMgr.firstUnlaidCharacterIndex(), fullString.length - layoutMgr.firstUnlaidCharacterIndex()))
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

enum TextRangeResult {
    case Ok(NSRange)
    case NotOk(errorText: String)
}

class TwoColumnLayoutMgr: NSLayoutManager {
    var textContainerToShow: MoveThenExpandTextContainer!
    var textContainerToHide: MoveThenExpandTextContainer!
    convenience init(showSize: CGSize, hiddenSize: CGSize, textToBeShown: NSString) {
        self.init()
        textContainerToShow = MoveThenExpandTextContainer(isHidden: false, size: showSize)
        textContainerToHide = MoveThenExpandTextContainer(isHidden: true, size: hiddenSize)
        self.addTextContainer(textContainerToShow)
        self.addTextContainer(textContainerToHide)
        textToShow = textToBeShown
    }
    // NSLayoutManager works only with NSRange. It's easier to get NSRange from NSString instead of Range<String.Index> (http://stackoverflow.com/questions/27040924/nsrange-from-swift-range)
    var textToShow: NSString!
    enum layoutMgrError: ErrorType {
        case NoTextStorage
    }
    var textRange: NSRange {
        get {
            do {
                let r = try self.getTextRange()
                return r
            } catch layoutMgrError.NoTextStorage {
                print("No text storage.")
            } catch {
                print("Unknow error on TwoColumnLayoutMgr.")
            }
        }
    }
    func getTextRange() throws -> NSRange {
        guard let t = textStorage else {
            throw layoutMgrError.NoTextStorage
        }
        return (t.string as NSString).rangeOfString(textToShow as String)
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
        var containerToUse: NSTextContainer
        if let t = textGlyphRange {
            containerToUse = NSIntersectionRange(glyphRange, t).length == t.length ? textContainerToShow : textContainerHidden
        } else {
            containerToUse = textContainerToShow
        }
        super.setTextContainer(containerToUse, forGlyphRange: glyphRange)
    }
    override func drawGlyphsForGlyphRange(glyphsToShow: NSRange, atPoint origin: CGPoint) {
        super.drawGlyphsForGlyphRange(glyphsToShow, atPoint: origin)
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
            lineBreakMode = NSLineBreakMode.ByCharWrapping
            lineFragmentPadding = 0
            maximumNumberOfLines = 1
        }
    }
}