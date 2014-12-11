//
//  REListView.swift
//  Remolet
//
//  Created by Liwei Zhang on 2014-12-07.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

import Foundation
import UIKit



// deleted indexpath is always based on current snapshot

// When to take a snapshot? Once UI should response to a change triggered. There are two types of change: 1. user triggered 2. system(server) triggered. We need a container to store all the changes between the previous snapshot and the one following. We also generate an array with rowid only to quickly locatethe index of any given item. UI finally makes batch change based on the info above.

