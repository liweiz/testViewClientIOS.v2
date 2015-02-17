//
//  CardsViewCtl.swift
//  Remolet
//
//  Created by Liwei Zhang on 2015-02-16.
//  Copyright (c) 2015 Liwei Zhang. All rights reserved.
//

import Foundation
import UIKit

class CardsViewCtl: UITableViewController {
    let cellIdentifier = "CardCell"
    override init(style: UITableViewStyle) {
        super.init(style: style)
        
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dbSnapshots[0].count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        switch sortRule {
        case SortOptionsItem.NoInListDescending_TargetAscending_TranslationAscending,
        SortOptionsItem.TargetAscending_TranslationAscending_NoInListDescending,
        SortOptionsItem.TargetDescending_TranslationAscending_NoInListDescending:
            cell.textLabel?.text = dbSnapshots[0][indexPath.row].target
        case SortOptionsItem.TranslationAscending_TargetAscending_NoInListDescending,
        SortOptionsItem.TranslationDescending_TargetAscending_NoInListDescending:
            cell.textLabel?.text = dbSnapshots[0][indexPath.row].translation
        }
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        <#code#>
    }
}