//
//  REDbWorker.swift
//  Remolet
//
//  Created by Liwei Zhang on 2014-12-01.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

import Foundation
import SQLite

let db = Database()

struct File {
    var lastModifiedAtLocal0 = 0
    var lastModifiedAtServer0 = 0
    var locallyDeleted0 = false
    var targetLang0 = ""
    var sourceLang0 = ""
    var serverId0 = ""
    var versionNo0 = 0
    var rowid0 = 0
}

struct User {
    var activated0 = false
    var deviceInfoId0 = ""
    var deviceUuid0 = ""
    var email0 = ""
    var isLoggedIn0 = false
    var isSharing0 = false
    var rememberMe0 = false
    var sortOption0 = ""
    var linkTo0 = 0
}

struct Card {
    var belongTo0 = ""
    var collectedAt0 = 0
    var context0 = ""
    var detail0 = ""
    var target0 = ""
    var translation0 = ""
    var linkTo0 = 0
}

struct ReqIdCandidate {
    var lastModifiedAtLocal0 = 0
    var createdAtLocal0 = 0
    var done0 = false
    var editAction0 = ""
    var operationVersion0 = 0
    var reqId0 = ""
    var linkTo0 = 0
}

// Shared fields
let lastModifiedAtLocal = Expression<Int>("lastModifiedAtLocal")
let lastModifiedAtServer = Expression<Int>("lastModifiedAtServer")
let rowid = Expression<Int>("rowid")
let locallyDeleted = Expression<Bool>("locallyDeleted")
let serverId = Expression<String>("serverId")
let versionNo = Expression<Int>("versionNo")
let targetLang = Expression<String>("targetLang")
let sourceLang = Expression<String>("sourceLang")
// user
let activated = Expression<Bool>("activated")
let deviceInfoId = Expression<String>("deviceInfoId")
let deviceUuid = Expression<String>("deviceUuid")
let email = Expression<String>("email")
let isLoggedIn = Expression<Bool>("isLoggedIn")
let isSharing = Expression<Bool>("isSharing")
let rememberMe = Expression<Bool>("rememberMe")
let sortOption = Expression<String>("sortOption")
let linkTo = Expression<Int>("linkTo")
// card
let belongTo = Expression<String>("belongTo")
let collectedAt = Expression<Int>("collectedAt")
let context = Expression<String>("context")
let detail = Expression<String>("detail")
let target = Expression<String>("target")
let translation = Expression<String>("translation")
// reqIdCandidate
let createdAtLocal = Expression<Int>("createdAtLocal")
let done = Expression<Bool>("done")
let editAction = Expression<String>("editAction")
let operationVersion = Expression<Int>("operationVersion")
let reqId = Expression<String>("reqId")

func setupTables(db:Database) -> (files: Query, users: Query, cards: Query, reqIdCandidates: Query) {
    let files = db["files"]
    db.create(table: files, ifNotExists: true) { t in
        t.column(lastModifiedAtLocal)
        t.column(lastModifiedAtServer)
        t.column(locallyDeleted)
        t.column(serverId)
        t.column(versionNo)
        t.column(targetLang)
        t.column(sourceLang)

        t.column(rowid, primaryKey: .Autoincrement)
    }
    
    let users = db["users"]
    
    db.create(table: users, ifNotExists: true) { t in
        t.column(activated)
        t.column(deviceInfoId)
        t.column(deviceUuid)
        t.column(email)
        t.column(isLoggedIn)
        t.column(isSharing)
        t.column(sortOption)
        t.column(linkTo)
        
        t.foreignKey(linkTo, references: files[linkTo], update: .Cascade, delete: .Cascade)
    }
    
    let cards = db["cards"]
    db.create(table: cards, ifNotExists: true) { t in
        t.column(belongTo)
        t.column(collectedAt)
        t.column(context)
        t.column(detail)
        t.column(target)
        t.column(translation)
        t.column(linkTo)
        
        t.foreignKey(linkTo, references: files[linkTo], update: .Cascade, delete: .Cascade)
        t.foreignKey(belongTo, references: users[serverId], update: .Cascade, delete: .Cascade)
    }
    
    let reqIdCandidates = db["reqIdCandidates"]
    db.create(table: reqIdCandidates, ifNotExists: true) { t in
        t.column(lastModifiedAtLocal)
        t.column(createdAtLocal)
        t.column(done)
        t.column(editAction)
        t.column(operationVersion)
        t.column(reqId)
        // Belong to that file
        t.column(linkTo)
        
        t.foreignKey(linkTo, references: files[linkTo], update: .Cascade, delete: .Cascade)
    }
    
    return (files, users, cards, reqIdCandidates)
}

let tables = setupTables(db)

// MARK: - CRUD

func insertFile(#db: Database, #f: File) -> Int? {
    return tables.files.insert(lastModifiedAtLocal <- f.lastModifiedAtLocal0, lastModifiedAtServer <- f.lastModifiedAtServer0, locallyDeleted <- f.locallyDeleted0, serverId <- f.serverId0, versionNo <- f.versionNo0, targetLang <- f.targetLang0, sourceLang <- f.sourceLang0)
}

func insertUser(#db: Database, #u: User) -> Int? {
    return tables.users.insert(activated <- u.activated0, deviceInfoId <- u.deviceInfoId0, deviceUuid <- u.deviceUuid0, email <- u.email0, isLoggedIn <- u.isLoggedIn0, isSharing <- u.isSharing0, sortOption <- u.sortOption0, linkTo <- u.linkTo0)
}

func insertCard(#db: Database, #c: Card) -> Int? {
    return tables.cards.insert(belongTo <- c.belongTo0, collectedAt <- c.collectedAt0, context <- c.context0, detail <- c.detail0, target <- c.target0, translation <- c.translation0, linkTo <- c.linkTo0)
}

func insertReqIdCandidate(#db: Database, #r: ReqIdCandidate) -> Int? {
    return tables.reqIdCandidates.insert(lastModifiedAtLocal <- r.lastModifiedAtLocal0, createdAtLocal <- r.createdAtLocal0, done <- r.done0, editAction <- r.editAction0, operationVersion <- r.operationVersion0, reqId <- r.reqId0, linkTo <- r.linkTo0)
}

func updateFile(#db: Database, #f: File) -> Int? {
    if let n = tables.files.filter(serverId == f.serverId0).update(lastModifiedAtLocal <- f.lastModifiedAtLocal0, lastModifiedAtServer <- f.lastModifiedAtServer0, locallyDeleted <- f.locallyDeleted0, serverId <- f.serverId0, versionNo <- f.versionNo0, targetLang <- f.targetLang0, sourceLang <- f.sourceLang0) {
        return n
    } else {
        return tables.files.filter(rowid == f.rowid0).update(lastModifiedAtLocal <- f.lastModifiedAtLocal0, lastModifiedAtServer <- f.lastModifiedAtServer0, locallyDeleted <- f.locallyDeleted0, serverId <- f.serverId0, versionNo <- f.versionNo0, targetLang <- f.targetLang0, sourceLang <- f.sourceLang0)
    }
}

func updateUser(#db: Database, #u: User) -> Int? {
    return tables.users.filter(linkTo == u.linkTo0).update(activated <- u.activated0, deviceInfoId <- u.deviceInfoId0, deviceUuid <- u.deviceUuid0, email <- u.email0, isLoggedIn <- u.isLoggedIn0, isSharing <- u.isSharing0, sortOption <- u.sortOption0)
}

func updateCard(#db: Database, #c: Card) -> Int? {
    return tables.cards.filter(linkTo == c.linkTo0).update(belongTo <- c.belongTo0, collectedAt <- c.collectedAt0, context <- c.context0, detail <- c.detail0, target <- c.target0, translation <- c.translation0)
}

func updateReqIdCandidate(#db: Database, #r: ReqIdCandidate) -> Int? {
    return tables.reqIdCandidates.filter(linkTo == r.linkTo0).update(lastModifiedAtLocal <- r.lastModifiedAtLocal0, createdAtLocal <- r.createdAtLocal0, done <- r.done0, editAction <- r.editAction0, operationVersion <- r.operationVersion0, reqId <- r.reqId0, linkTo <- r.linkTo0)
}

func deleteFile(#db: Database, #f: File) -> Int? {
    if let n = tables.files.filter(serverId == f.serverId0).delete() {
        return n
    } else {
        return tables.files.filter(rowid == f.rowid0).delete()
    }
}

func deleteUser(#db: Database, #u: User) -> Int? {
    return tables.users.filter(linkTo == u.linkTo0).delete()
}

func deleteCard(#db: Database, #c: Card) -> Int? {
    return tables.cards.filter(linkTo == c.linkTo0).delete()
}

func deleteReqIdCandidate(#db: Database, #r: ReqIdCandidate) -> Int? {
    return tables.reqIdCandidates.filter(linkTo == r.linkTo0).delete()
}

struct CardToShow {
    var collectedAt0 = 0
    var context0 = ""
    var detail0 = ""
    var target0 = ""
    var translation0 = ""
    var rowid0 = 0
}

func getCards(#userServerId: String) -> [CardToShow] {
    var r: [CardToShow] = []
    for c in tables.cards.filter(belongTo == userServerId && locallyDeleted == false) {
        var x = CardToShow()
        x.collectedAt0 = c[collectedAt]
        x.context0 = c[context]
        x.detail0 = c[detail]
        x.target0 = c[target]
        x.translation0 = c[translation]
        x.rowid0 = c[rowid]
        r.append(x)
    }
    return r;
}

func getFile(#rowId: Int) -> File? {
    var f = File()
    for r in tables.cards.filter(rowid == rowId) {
        f.lastModifiedAtLocal0 = r.get(lastModifiedAtLocal)
        f.lastModifiedAtServer0 = r.get(lastModifiedAtServer)
        f.locallyDeleted0 = r.get(locallyDeleted)
        f.rowid0 = rowId
        f.serverId0 = r.get(serverId)
        f.sourceLang0 = r.get(sourceLang)
        f.targetLang0 = r.get(targetLang)
        f.versionNo0 = r.get(versionNo)
        return f
    }
    return nil
}

func getUser(#rowId: Int) -> User? {
    var u = User()
    for r in tables.users.filter(rowid == rowId) {
        u.activated0 = r.get(activated)
        u.deviceInfoId0 = r.get(deviceInfoId)
        u.deviceUuid0 = r.get(deviceUuid)
        u.email0 = r.get(email)
        u.isLoggedIn0 = r.get(isLoggedIn)
        u.isSharing0 = r.get(isSharing)
        u.rememberMe0 = r.get(rememberMe)
        u.sortOption0 = r.get(sortOption)
        u.linkTo0 = r.get(linkTo)
        return u
    }
    return nil
}

func getCard(#rowId: Int) -> Card? {
    var c = Card()
    for r in tables.cards.filter(rowid == rowId) {
        c.belongTo0 = r.get(belongTo)
        c.collectedAt0 = r.get(collectedAt)
        c.context0 = r.get(context)
        c.detail0 = r.get(detail)
        c.target0 = r.get(target)
        c.translation0 = r.get(translation)
        c.linkTo0 = r.get(linkTo)
        return c
    }
    return nil
}

func getReqIdCandidate(#rowId: Int) -> ReqIdCandidate? {
    var e = ReqIdCandidate()
    for r in tables.reqIdCandidates.filter(rowid == rowId) {
        e.lastModifiedAtLocal0 = r.get(lastModifiedAtLocal)
        e.createdAtLocal0 = r.get(createdAtLocal)
        e.done0 = r.get(done)
        e.editAction0 = r.get(editAction)
        e.operationVersion0 = r.get(operationVersion)
        e.reqId0 = r.get(reqId)
        e.linkTo0 = r.get(linkTo)
        return e
    }
    return nil
}

typealias rowIdServerIdPairs = [Int: String]

typealias dataSourceSnapshot = [CardToShow]
typealias dataSourceSnapshotIndex = [Int]
var dataSourceSnapshots = [dataSourceSnapshot]()

func getIndexArray(shot: dataSourceSnapshot) -> dataSourceSnapshotIndex {
    var d = dataSourceSnapshotIndex()
    for c in shot {
        d += [c.rowid0]
    }
    return d
}

func getIndexPath(#rowId: Int, #snapshot: dataSourceSnapshot, #snapshotIndex: dataSourceSnapshotIndex, #sec: Int) -> NSIndexPath? {
    if let n = find(snapshotIndex, rowId) {
        return NSIndexPath(forRow: n, inSection: sec)
    }
    return nil
}

// To identify whether the editing operation is on a locally existing record. If yes, return the rowid.
func checkIfExistingLocally(#serverId: String, #rowId: Int, #pairs: rowIdServerIdPairs) -> Int? {
    if rowId != 0 {
        // Locally existing
        return rowId
    } else {
        for i in pairs.keys {
            if pairs[i] == serverId {return i}
        }
        return nil
    }
}








