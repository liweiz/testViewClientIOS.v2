//
//  ContentsView.swift
//  Remolet
//
//  Created by Liwei Zhang on 2015-02-21.
//  Copyright (c) 2015 Liwei Zhang. All rights reserved.
//

import Foundation
import UIKit


class ContentsViewCtl: UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return 1
    }
    override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
            var c: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! UICollectionViewCell
            return c
    }
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.performBatchUpdates({
            collectionView.collectionViewLayout.invalidateLayout()
            }, completion: nil)
    }
}

class ContentCell: UICollectionViewCell {
    var target: UILabel!
    var translation: UILabel!
    var context: UILabel!
    var detail: UILabel!
}

class ContentsView: UICollectionView {
    
    
    
}

func getLayout() -> ContentsViewLayout {
    var l = ContentsViewLayout()
    l.minimumLineSpacing = 1
    l.itemSize = CGSizeMake(appRect.width, (appRect.height - l.minimumLineSpacing * 7))
    return l
}

enum DisplayMode {
    case ExpandableList
    case AllExpanded
    case AllExpandedZoomedOut
}

class ContentsViewLayout: UICollectionViewFlowLayout, UICollectionViewDelegateFlowLayout {
    var displayMode = DisplayMode.ExpandableList
    var listSize = CGSizeZero
    var expandedSize = CGSizeZero
    var expandedSizeZoomedOut = CGSizeZero
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch displayMode {
        case DisplayMode.ExpandableList:
            if let r = find(collectionView.indexPathsForSelectedItems() as! [NSIndexPath], indexPath) {
                return expandedSize
            }
            return listSize
        case DisplayMode.AllExpanded:
            return expandedSize
        case DisplayMode.AllExpandedZoomedOut:
            return expandedSizeZoomedOut
        default:
            return listSize
        }
    }

}