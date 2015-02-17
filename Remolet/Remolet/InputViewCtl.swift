//
//  InputViewCtl.swift
//  Remolet
//
//  Created by Liwei Zhang on 2015-02-16.
//  Copyright (c) 2015 Liwei Zhang. All rights reserved.
//

import Foundation
import UIKit

// Use this as in memory db before Realm is available in Swift.
var cardsNow = [Card]()

class InputViewCtl: UIViewController {
    var base: VerticalScrollSwitchView!
    var target, translation, detail, context: ViewSet!
    var fontUsed: UIFont!
    var viewSets = [ViewSet]()
    override func loadView() {
        view = TapToActView(frame: appRectZero)
        base = VerticalScrollSwitchView(frame: view.frame)
        base.delegate = base
        let w = view.frame.width
        let h = view.frame.height
        target = ViewSet(frame: CGRectMake(zeroCGFloat, base.frame.height, w, getViewSetHeight(1)))
        translation = ViewSet(frame: CGRectMake(zeroCGFloat, CGRectGetMaxY(target.frame), w, getViewSetHeight(1)))
        context = ViewSet(frame: CGRectMake(zeroCGFloat, CGRectGetMaxY(translation.frame), w, getViewSetHeight(3)))
        detail = ViewSet(frame: CGRectMake(zeroCGFloat, CGRectGetMaxY(context.frame), w, getViewSetHeight(3)))
        // Make sure the height is tall enough to show last input on top of the screen.
        base.contentSize = CGSizeMake(base.frame.width, CGRectGetMinY(detail.frame) + appRect.height + base.frame.height * 2)
        base.stops = [CGRectGetMinY(target.frame), CGRectGetMaxY(target.frame), CGRectGetMaxY(translation.frame), CGRectGetMaxY(context.frame), CGRectGetMaxY(detail.frame)]
        base.basePositionY = base.stops.first!
        viewSets = [target, translation, context, detail]
        base.addSubview(target)
        base.addSubview(translation)
        base.addSubview(context)
        base.addSubview(detail)
        base.contentOffset = CGPointMake(0, CGRectGetMinY(target.frame))
        view.addSubview(base)
        target.inputPlaceholder.text = "Word(s)"
        translation.inputPlaceholder.text = "Translation"
        context.inputPlaceholder.text = "Example"
        detail.inputPlaceholder.text = "Detailed explanation"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectViewSet:", name: "verticalStopChangedByUserScrolling", object: base)
        for s in viewSets {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollToSelected:", name: "viewSetSelected", object: s)
        }
    }
    func getViewSetHeight(lineNo: CGFloat) -> CGFloat {
        return gapM * twoCGFloat + fontUsed.lineHeight * lineNo
    }
    func selectViewSet(note: NSNotification) {
        if let o = note.object as? VerticalScrollSwitchView {
            if let i = find(o.allStops, o.basePositionY) {
                let x = viewSets[i - 1]
                x.isSelected = true
            }
        }
    }
    func deselectViewSets() {
        for v in viewSets {
            if v.isSelected {
                v.isSelected = false
            }
        }
    }
    func scrollToSelected(note: NSNotification) {
        if let v = note.object as? ViewSet {
            if let i = find(viewSets, v) {
                let y = base.allStops[i + 1]
                base.setContentOffset(CGPointMake(0, y), animated: true)
                base.userTriggered = false
                base.basePositionY = y
            }
        }
    }
}
