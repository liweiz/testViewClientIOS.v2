//
//  LongPressThenSwipeActionView.swift
//  Remolet
//
//  Created by Liwei Zhang on 2015-02-17.
//  Copyright (c) 2015 Liwei Zhang. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class LongPressThenSwipeActionView: UIScrollView, UIScrollViewDelegate {
    var viewToOperate: UIView!
    var animationDuration = 0.3
    var shrinkRatio = CGFloat(0.8)
    var actOnSwipeUp: (() -> ())?
    var actOnSwipeDown: (() -> ())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        longPress = UILongPressGestureRecognizer(target: self, action: "toSwipeMode")
        tap = UITapGestureRecognizer(target: self, action: "exitSwipeMode")
        self.delegate = self
        self.pagingEnabled = true
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.memory.y == scrollView.contentSize.height - scrollView.frame.height {
            if let aUp = actOnSwipeUp {
                aUp()
            }
        } else if targetContentOffset.memory.y == 0 && scrollView.contentSize.height > scrollView.frame.height * 2 {
            if let aDown = actOnSwipeDown {
                aDown()
            }
        }
    }
    override func layoutSubviews() {
        if self.contentOffset.y == self.contentSize.height - self.frame.height || (self.contentOffset.y == 0 && self.contentSize.height > self.frame.height * 2) {
            // Action on swipe completed, reset and showing viewToOperate again.
            if self.contentSize.height > self.frame.height * 2 {
                self.setContentOffset(CGPointMake(0, self.frame.height), animated: false)
            } else {
                self.setContentOffset(CGPointZero, animated: false)
            }
            
        }
    }
    var longPress: UILongPressGestureRecognizer!
    func toSwipeMode() {
        if longPress.state == UIGestureRecognizerState.Began {
            self.longPress.enabled = false
            self.tap.enabled = true
            self.scrollEnabled = true
            viewToOperate.userInteractionEnabled = false
            shrinkView(viewToOperate)
        }
    }
    var tap: UITapGestureRecognizer!
    func exitSwipeMode() {
        self.tap.enabled = false
        self.longPress.enabled = true
        self.scrollEnabled = false
        viewToOperate.userInteractionEnabled = true
        enlargeView(viewToOperate)
    }
    func shrinkView(v: UIView) {
        var shrink = CABasicAnimation(keyPath: "transform")
        shrink.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        shrink.toValue = NSValue(CATransform3D: CATransform3DMakeScale(shrinkRatio, shrinkRatio, 1))
        shrink.duration = animationDuration
        shrink.removedOnCompletion = false
        v.layer.addAnimation(shrink, forKey: "shrink")
    }
    func enlargeView(v: UIView) {
        var enlarge = CABasicAnimation(keyPath: "transform")
        enlarge.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(shrinkRatio, shrinkRatio, 1))
        enlarge.toValue = NSValue(CATransform3D: CATransform3DIdentity)
        enlarge.duration = animationDuration
        enlarge.removedOnCompletion = true
        v.layer.addAnimation(enlarge, forKey: "enlarge")
    }
    func becomeVisiable(v: UIView) {
        var beVisiable = CABasicAnimation(keyPath: "opacity")
        beVisiable.fromValue = NSNumber(float: 0)
        beVisiable.toValue = NSNumber(float: 1)
        beVisiable.duration = animationDuration
        beVisiable.removedOnCompletion = true
        v.layer.addAnimation(beVisiable, forKey: "becomeVisiable")
    }
}