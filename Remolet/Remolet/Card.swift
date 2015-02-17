//
//  Card.swift
//  Remolet
//
//  Created by Liwei Zhang on 2015-02-16.
//  Copyright (c) 2015 Liwei Zhang. All rights reserved.
//

import Foundation

struct Card {
    // Language to be translated.
    var sourceLang = ""
    var targetLang = ""
    var target = ""
    var translation = ""
    var context = ""
    var detail = ""
    // Since users can edit file as csv in any file system, a lastTimeModified/timeCreated field is not practical here. We assign an Int to indicate the no it is in the array. It is decided by the order added. Later added one comes with a larger no. New one from cloud comes with larger no than any local one's. -1 indicates it's a blank row for an expanded card.
    var noInList = -1
    // Each number stands for the submitted status in the order of target/translation/context/detail. If the number is less than 1000 such as 0101 (target not submitted/translation submitted/context not submitted/detail submitted, the number sent is 101), server will restore the number back to four digits. This is to reduce duplicate submissions.
    var submittedToPool = 0
}

// MARK: - Sort Options

internal enum SortOptionsItem {
    case NoInListDescending_TargetAscending_TranslationAscending
    case TargetAscending_TranslationAscending_NoInListDescending
    case TargetDescending_TranslationAscending_NoInListDescending
    case TranslationAscending_TargetAscending_NoInListDescending
    case TranslationDescending_TargetAscending_NoInListDescending
}

internal enum SortOptionItem {
    case TargetAscending
    case TargetDescending
    case TranslationAscending
    case TranslationDescending
    case NoInListAscending
    case NoInListDescending
}

internal enum SortItemsBy {
    case Target
    case Translation
    case NoInList
}


// MARK: - Compare

extension Card: Equatable, Comparable {}

func ==(l: Card, r: Card) -> Bool {
    if l.target.localizedCompare(r.target) == NSComparisonResult.OrderedSame && l.translation.localizedCompare(r.translation) == NSComparisonResult.OrderedSame && l.context.localizedCompare(r.context) == NSComparisonResult.OrderedSame && l.detail.localizedCompare(r.detail) == NSComparisonResult.OrderedSame {
        return true
    }
    return false
}

var sortRule = SortOptionsItem.NoInListDescending_TargetAscending_TranslationAscending

func <(l: Card, r: Card) -> Bool {
    var listL: [String]
    var listR: [String]
    switch sortRule {
    case SortOptionsItem.NoInListDescending_TargetAscending_TranslationAscending, SortOptionsItem.TargetAscending_TranslationAscending_NoInListDescending,
    SortOptionsItem.TargetDescending_TranslationAscending_NoInListDescending:
        listL = [l.target, l.translation, l.context, l.detail]
        listR = [r.target, r.translation, r.context, r.detail]
    case SortOptionsItem.TranslationAscending_TargetAscending_NoInListDescending,
    SortOptionsItem.TranslationDescending_TargetAscending_NoInListDescending:
        listL = [l.translation, l.target, l.context, l.detail]
        listR = [r.translation, r.target, r.context, r.detail]
    }
    var leftIsSmaller: Bool? = nil
    var i = 0
    for x in listL {
        let k = x.localizedCompare(listR[i])
        if k == NSComparisonResult.OrderedAscending {
            leftIsSmaller = true
            break
        } else if k == NSComparisonResult.OrderedDescending {
            leftIsSmaller = false
            break
        }
        i++
    }
    if sortRule == SortOptionsItem.NoInListDescending_TargetAscending_TranslationAscending {
        if l.noInList < r.noInList {
            return true
        } else if l.noInList > r.noInList {
            return false
        }
    }
    return leftIsSmaller!
}