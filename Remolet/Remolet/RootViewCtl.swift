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

class RootViewCtl: UIViewController {
    var mainViewsBase: InfiniteHorizontalScrolledPageView!
    var inputCtl: inputViewCtl!
    override func loadView() {
        view = UIView(frame: appRectZero)
        mainViewsBase = InfiniteHorizontalScrolledPageView(frame: view.frame)
        mainViewsBase.contentSize = CGSizeMake(view.frame.width * CGFloat(3), view.frame.height)
        mainViewsBase.delegate = mainViewsBase
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
}
