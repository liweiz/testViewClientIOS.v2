//
//  InfiniteHorizontalScrolledPageView.swift
//  Remolet
//
//  Created by Liwei Zhang on 2015-02-01.
//  Copyright (c) 2015 Liwei Zhang. All rights reserved.
//

import Foundation
import UIKit

/* 
1. User scroll to target another page
2. Page fully displayed
3. Recenter scrollView and adjust page order
*/
class InfiniteHorizontalScrolledPageView: UIScrollView, UIScrollViewDelegate {
    var viewsToRotate: [UIView]!
    override func layoutSubviews() {
        super.layoutSubviews()
        if contentOffset.x == 0 || contentOffset.x == frame.width * 2 {
            if let r = recenter(self, viewsToRotate) {
                viewsToRotate = r
            }
        }
    }
}

// At any given moment, 0 => the left view, 1 => the middle one, 2 => the right one
// The initial position is 0, 1, 2, see loadView
func recenter(view: UIScrollView, views: [UIView]) -> [UIView]? {
    var updatedViews = [UIView]()
    if view.contentOffset.x == 0 {
        // Get the new position before recentering contentview since contentOffset will change after recentering
        // Dismiss keyboard after leaving New
        updatedViews.append(views[2])
        updatedViews.append(views[0])
        updatedViews.append(views[1])
    } else if view.contentOffset.x == view.frame.size.width * 2 {
        updatedViews.append(views[1])
        updatedViews.append(views[2])
        updatedViews.append(views[0])
    } else {
        return nil
    }
    repositionSubviews(view, updatedViews)
    view.setContentOffset(CGPointMake(view.frame.size.width, 0), animated: false)
    return updatedViews
}

func repositionSubviews(view: UIScrollView, views: [UIView]) {
    var i = 0
    for v in views {
        v.frame = CGRectMake(view.frame.size.width * CGFloat(i), 0, view.frame.size.width, view.frame.size.height)
        i++
    }
}



