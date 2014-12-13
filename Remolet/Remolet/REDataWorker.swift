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

struct OrderedDic<KeyType: Hashable, ValueType> {
    typealias ArrayType = [KeyType]
    typealias DicType = [KeyType: ValueType]
    
    var array = ArrayType()
    var dic = DicType()
    
    mutating func insert(value: ValueType, forKey key: KeyType, atIndex index: Int) -> ValueType? {
        var adjustedIndex = index
        let existingValue = self.dic[key]
        if existingValue != nil {
            let existingIndex = find(self.array, key)!
            if existingIndex < index {
                adjustedIndex--
            }
            self.array.removeAtIndex(existingIndex)
        }
        self.array.insert(key, atIndex: adjustedIndex)
        self.dic[key] = value
        return existingValue
    }
    mutating func removeAtIndex(index: Int) -> (KeyType, ValueType) {
        precondition(index < self.array.count, "Index out-of-bounds")
        let key = self.array.removeAtIndex(index)
        let value = self.dic.removeValueForKey(key)!
        return (key, value)
    }
    subscript(key: KeyType) -> ValueType? {
        get {
            return self.dic[key]
        }
        set {
            if let index = find(self.array, key) {
            } else {
                self.array.append(key)
            }
            self.dic[key] = newValue
        }
    }
    subscript(index: Int) -> (KeyType, ValueType) {
        get {
            precondition(index < self.array.count, "Index out-of-counds")
            let key = self.array[index]
            let value = self.dic[key]!
            return (key, value)
        }
    }
}








