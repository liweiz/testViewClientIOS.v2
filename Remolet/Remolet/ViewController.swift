//
//  ViewController.swift
//  Remolet
//
//  Created by Liwei Zhang on 2014-11-30.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var coreCtl = setupCoreViewCtl(appRect)
        self.addChildViewController(coreCtl)
        self.view.addSubview(coreCtl.view)
        coreCtl.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

func setupCoreViewCtl(aFrame: CGRect) -> UIViewController {
    var ctl = UIViewController()
    var base = UIScrollView(frame: aFrame)
    println(aFrame)
    base.contentSize = CGSizeMake(aFrame.width * 2, aFrame.height)
    ctl.view = base
    var inputViewCtl = setupInputViewCtl(appRect)
    ctl.addChildViewController(inputViewCtl)
    base.addSubview(inputViewCtl.view)
    inputViewCtl.didMoveToParentViewController(ctl)
    return ctl
}




class inputViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var sectionOnDuty: Int = 0
    let sectionStops: [CGFloat] = inputStops
    var wordCounter: UILabel
    let inputs: [UITextView]
    var startPositionY: CGFloat
    var dragStartPointY: CGFloat
    var targetPositionY: CGFloat
}



func setupInputViewCtl(aFrame: CGRect) -> inputViewController {
    var ctl = inputViewController()
    ctl.view = UIView(frame: aFrame)
    var aInputView = setupInputView(aFrame: appRect)
    ctl.view.addSubview(aInputView)
    return ctl
}

let sysFontName = "AmericanTypewriter"
let fontS = UIFont(name: sysFontName, size: 18)!
let fontM = UIFont(name: sysFontName, size: 24)!
let fontL = UIFont(name: sysFontName, size: 28)!

let sectionHs: [CGFloat] = []

func getInputBoxHeight(#fontUsed: UIFont, #gapUsed: CGFloat, #noOfLines: CGFloat) -> CGFloat {
    return fontUsed.lineHeight * noOfLines + gapUsed * 2
}

func getSectionHeight(#gap: CGFloat, #fontUsed: UIFont, #gapInInputBox: CGFloat, #noOfLines: CGFloat) -> CGFloat {
    return getInputBoxHeight(fontUsed: fontUsed, gapUsed: gapInInputBox, noOfLines: noOfLines) + gap * 2
}

let gapToSectionTop = gapS

func getSectionInputHeights() -> [CGFloat] {
    let targetH = getInputBoxHeight(fontUsed: fontM, gapUsed: gapToSectionTop, noOfLines: 1)
    let translationH = getInputBoxHeight(fontUsed: fontM, gapUsed: gapToSectionTop, noOfLines: 1)
    let detailH = getInputBoxHeight(fontUsed: fontM, gapUsed: gapToSectionTop, noOfLines: 4)
    let contextH = getInputBoxHeight(fontUsed: fontM, gapUsed: gapToSectionTop, noOfLines: 8)
    return [targetH, translationH, contextH, detailH]
}

func getSectionHeights() -> [CGFloat] {
    let targetH = getSectionHeight(gap: gapToSectionTop, fontUsed: fontM, gapInInputBox: gapToSectionTop, noOfLines: 1)
    let translationH = getSectionHeight(gap: gapToSectionTop, fontUsed: fontM, gapInInputBox: gapToSectionTop, noOfLines: 1)
    let detailH = getSectionHeight(gap: gapToSectionTop, fontUsed: fontM, gapInInputBox: gapToSectionTop, noOfLines: 4)
    let contextH = getSectionHeight(gap: gapToSectionTop, fontUsed: fontM, gapInInputBox: gapToSectionTop, noOfLines: 8)
    return [targetH, translationH, contextH, detailH]
}

func getStopPointsYs(#startY: CGFloat, #sectionHeights: [CGFloat]) -> [CGFloat] {
    var l = [startY + 20]
    var i = 0
    for j in sectionHeights {
        l += [l[i] + j]
        i += 1
    }
    return l
}

let sectionInputHeights = getSectionInputHeights()
let sectionHeights = getSectionHeights()
let inputStops = getStopPointsYs(startY: 0, sectionHeights: sectionHeights)

func setupInputView(#aFrame: CGRect) -> UIScrollView {
    var inputScrollView = UIScrollView(frame: aFrame)
    let w = aFrame.width - gapM * 2
    var targetInput = UITextView(frame: CGRectMake(gapM, inputStops[0] + gapToSectionTop, w, sectionInputHeights[0]))
    println(inputStops[0])
    var translationInput = UITextView(frame: CGRectMake(gapM, inputStops[1] + gapToSectionTop, w, sectionInputHeights[1]))
    var contextInput = UITextView(frame: CGRectMake(gapM, inputStops[2] + gapToSectionTop, w, sectionInputHeights[2]))
    var detailInput = UITextView(frame: CGRectMake(gapM, inputStops[3] + gapToSectionTop, w, sectionInputHeights[3]))
    inputScrollView.contentSize = CGSizeMake(appRect.width, inputStops.last!)
    configInputs([targetInput, translationInput, contextInput, detailInput], inputScrollView)
    return inputScrollView
}

func configInputs(inputs: [UITextView], onView: UIView) {
    for u in inputs {
        u.backgroundColor = UIColor.yellowColor()
        u.font = fontM
        u.textColor = UIColor.greenColor()
        onView.addSubview(u)
        let lineH: CGFloat = 0.5
        var bottomLine = UIView(frame: CGRectMake(0 + CGRectGetMinX(u.frame), CGRectGetMaxY(u.frame) - lineH, u.frame.width, lineH))
        bottomLine.backgroundColor = UIColor.blackColor()
        onView.addSubview(bottomLine)
    }
}



