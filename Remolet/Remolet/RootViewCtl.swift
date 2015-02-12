//
//  RootViewCtl.swift
//  Remolet
//
//  Created by Liwei Zhang on 2015-02-07.
//  Copyright (c) 2015 Liwei Zhang. All rights reserved.
//

import Foundation
import UIKit

let appRect = CGRectMake(0, UIScreen.mainScreen().applicationFrame.origin.y, UIScreen.mainScreen().applicationFrame.width, UIScreen.mainScreen().applicationFrame.height)
let appRectZero = CGRectMake(0, 0, UIScreen.mainScreen().applicationFrame.width, UIScreen.mainScreen().applicationFrame.height)
let gapXs: CGFloat = 2
let gapS: CGFloat = 10
let gapM: CGFloat = 15
let gapL: CGFloat = 20
let zeroCGFloat = CGFloat(2)
let twoCGFloat = CGFloat(2)
let fontSizeS = CGFloat(14)
let fontSizeM = CGFloat(20)
let fontSizeL = CGFloat(96)

class RootViewCtl: UIViewController, UIScrollViewDelegate {
    var mainViewsBase: InfiniteHorizontalScrolledPageView!
    var inputCtl: inputViewCtl!
    var mainViewBaseTargetX: CGFloat = -1
    override func loadView() {
        view = UIView(frame: appRectZero)
        mainViewsBase = InfiniteHorizontalScrolledPageView(frame: view.frame)
        mainViewsBase.contentSize = CGSizeMake(view.frame.width * CGFloat(3), view.frame.height)
        mainViewsBase.delegate = self
        mainViewsBase.pagingEnabled = true
        mainViewsBase.contentOffset = CGPointMake(view.frame.width, 0)
        mainViewsBase.bounces = false
        view.addSubview(mainViewsBase)
        
        inputCtl = inputViewCtl()
        inputCtl.fontUsed = UIFont.systemFontOfSize(fontSizeL)
        mainViewsBase.addSubview(inputCtl.view)
        inputCtl.view.backgroundColor = UIColor.greenColor()
        
        var view1 = UIView(frame: CGRectMake(appRect.width, 0, appRect.width, appRect.height))
        view1.backgroundColor = UIColor.yellowColor()
        mainViewsBase.addSubview(view1)
        var view2 = UIView(frame: CGRectMake(appRect.width * twoCGFloat, 0, appRect.width, appRect.height))
        view2.backgroundColor = UIColor.blueColor()
        mainViewsBase.addSubview(view2)
        
        mainViewsBase.viewsToRotate = [inputCtl.view, view1, view2]
    }
    
    func actUponView(v: UIView) {
        if v.isEqual(inputCtl.view) {
            inputCtl.base.setContentOffset(CGPointMake(0, inputCtl.base.allStops[1]), animated: true)
            inputCtl.base.userTriggered = false
            inputCtl.base.basePositionY = inputCtl.base.allStops[1]
            if inputCtl.target.input.text == "" {
                inputCtl.target.isSelected = true
            }
        } else {
            inputCtl.deselectViewSets()
        }
    }
    // Handle each view's tasks when a view stops on the screen.
    // To do this, it is necessary to know when a view is finally stops and which one is on the screen.
    // 1. contentOffset is on one of the edge points
    // 2. no user drag occurs again
    // 3. scroll target is reached
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var i = -1
        if mainViewBaseTargetX == 0 {
            i = 0
        } else if mainViewBaseTargetX == mainViewsBase.frame.width * 2 {
            i = 2
        }
        if i >= 0 {
            if scrollView.contentOffset.x == mainViewBaseTargetX {
                mainViewBaseTargetX = -1
                actUponView(mainViewsBase.viewsToRotate[i])
            }
        }
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        mainViewBaseTargetX = -1
    }
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        mainViewBaseTargetX = targetContentOffset.memory.x
    }
}
