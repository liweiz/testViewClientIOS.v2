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
    var viewToOperate: UIView! {
        didSet {
            viewToOperate.addGestureRecognizer(longPress)
        }
    }
    var animationDuration = 0.3
    var shrinkRatio = CGFloat(0.8)
    var actOnSwipeUp: (() -> ())?
    var actOnSwipeDown: (() -> ())?
    var shrink, enlarge, becomeVisiable: CAAnimation!
    var show: CAAnimationGroup!
    override init(frame: CGRect) {
        super.init(frame: frame)
        longPress = UILongPressGestureRecognizer(target: self, action: "toSwipeMode")
        tap = UITapGestureRecognizer(target: self, action: "exitSwipeMode")
        self.addGestureRecognizer(tap)
        self.delegate = self
        self.pagingEnabled = true
        shrink = shrinkView()
        enlarge = enlargeView()
        becomeVisiable = becomeVisiableView()
        show = showView()
        shrink.delegate = self
        enlarge.delegate = self
        becomeVisiable.delegate = self
        show.delegate = self
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
            self.tap.enabled = false
            self.longPress.enabled = true
            self.scrollEnabled = false
            viewToOperate.layer.addAnimation(show, forKey: "show")
        }
    }
    var longPress: UILongPressGestureRecognizer!
    func toSwipeMode() {
        if longPress.state == UIGestureRecognizerState.Began {
            viewToOperate.layer.removeAllAnimations()
            self.longPress.enabled = false
            self.tap.enabled = true
            self.scrollEnabled = true
            viewToOperate.layer.addAnimation(shrink, forKey: "shrink")
        }
    }
    var tap: UITapGestureRecognizer!
    func exitSwipeMode() {
        self.tap.enabled = false
        self.longPress.enabled = true
        self.scrollEnabled = false
        viewToOperate.layer.addAnimation(enlarge, forKey: "enlarge")
        viewToOperate.layer.removeAnimationForKey("shrink")
    }
    func showView() -> CAAnimationGroup {
        var show = CAAnimationGroup()
        show.animations = [becomeVisiableView(), enlargeView()]
        show.setValue(NSString(UTF8String: "show"), forKey: "animName")
        return show
    }
    func shrinkView() -> CAAnimation {
        var shrink = CABasicAnimation(keyPath: "transform")
        shrink.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        shrink.toValue = NSValue(CATransform3D: CATransform3DMakeScale(shrinkRatio, shrinkRatio, 1))
        shrink.duration = animationDuration
        shrink.fillMode = kCAFillModeForwards
        shrink.removedOnCompletion = false
        shrink.setValue(NSString(UTF8String: "shrink"), forKey: "animName")
        return shrink
    }
    func enlargeView() -> CAAnimation {
        var enlarge = CABasicAnimation(keyPath: "transform")
        enlarge.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(shrinkRatio, shrinkRatio, 1))
        enlarge.toValue = NSValue(CATransform3D: CATransform3DIdentity)
        enlarge.duration = animationDuration
        enlarge.removedOnCompletion = true
        enlarge.setValue(NSString(UTF8String: "enlarge"), forKey: "animName")
        return enlarge
    }
    func becomeVisiableView() -> CAAnimation {
        var beVisiable = CABasicAnimation(keyPath: "opacity")
        beVisiable.fromValue = NSNumber(float: 0)
        beVisiable.toValue = NSNumber(float: 1)
        beVisiable.duration = animationDuration
        beVisiable.removedOnCompletion = true
        beVisiable.setValue(NSString(UTF8String: "becomeVisiable"), forKey: "animName")
        return beVisiable
    }
    override func animationDidStart(anim: CAAnimation!) {
        viewToOperate.userInteractionEnabled = false
        switch anim.valueForKey("animName") as! NSString {
        case NSString(UTF8String: "enlarge")!, NSString(UTF8String: "show")!:
            viewToOperate.layer.removeAnimationForKey("shrink")
        default:
            println("Wrong animation")
        }
        
    }
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if flag {
            switch anim.valueForKey("animName") as! NSString {
            case NSString(UTF8String: "enlarge")!, NSString(UTF8String: "show")!:
                viewToOperate.userInteractionEnabled = true
                viewToOperate.layer.removeAllAnimations()
            default:
                println("Wrong animation")
            }
        }
    }

}