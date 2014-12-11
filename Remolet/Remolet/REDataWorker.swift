//
//  REDataWorker.swift
//  Remolet
//
//  Created by Liwei Zhang on 2014-12-07.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

import Foundation
import UIKit

var sortOptions: [NSSortDescriptor] = []
let byCellTitleAlphabetA = NSSortDescriptor(key: "target0", ascending: true)
let byTimeCollectedA = NSSortDescriptor(key: "collectedAt0", ascending: true)
let byCellTitleAlphabetD = NSSortDescriptor(key: "target0", ascending: false)
let byTimeCollectedD = NSSortDescriptor(key: "collectedAt0", ascending: false)


func getCardsDataSource(source: [CardToShow]) -> [CardToShow] {
    return source.sorted({
        let x = $0 as CardToShow
        let y = $1 as CardToShow
        if x.collectedAt0 == y.collectedAt0 {
            return x.target0 > y.target0
        } else {
            return x.collectedAt0 < y.collectedAt0
        }
    })
}

