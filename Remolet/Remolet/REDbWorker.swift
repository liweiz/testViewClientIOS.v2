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
    var localId0 = "_"
    var locallyDeleted0 = false
    var serverId0 = "_"
    var versionNo0 = 0
    var serverAndLocalId0: String {
        return serverId0 + localId0
    }
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
    var targetLang0 = ""
    var sourceLang0 = ""
    var serverAndLocalId0 = ""
}

struct Card {
    var belongTo0 = ""
    var collectedAt0 = 0
    var context0 = ""
    var detail0 = ""
    var target0 = ""
    var translation0 = ""
    var targetLang0 = ""
    var sourceLang0 = ""
    var serverAndLocalId0 = ""
}

struct ReqIdCandidate {
    var lastModifiedAtLocal0 = 0
    var createdAtLocal0 = 0
    var done0 = false
    var editAction0 = ""
    var operationVersion0 = 0
    var reqId0 = ""
    var serverAndLocalId0 = ""
}

// Shared fields
let lastModifiedAtLocal = Expression<Int>("lastModifiedAtLocal")
let lastModifiedAtServer = Expression<Int>("lastModifiedAtServer")
let localId = Expression<String>("localId")
let locallyDeleted = Expression<Bool>("locallyDeleted")
let serverId = Expression<String>("serverId")
let versionNo = Expression<Int>("versionNo")
// serverId + localId to make sure its's not empty string. If any part is empty string use "_"(undersctore) to indicate its empty state. This is to prevent from the case that serverId and localId have same strings.
let serverAndLocalId = Expression<String>("serverId")
// user
let activated = Expression<Bool>("activated")
let deviceInfoId = Expression<String>("deviceInfoId")
let deviceUuid = Expression<String>("deviceUuid")
let email = Expression<String>("email")
let isLoggedIn = Expression<Bool>("isLoggedIn")
let isSharing = Expression<Bool>("isSharing")
let rememberMe = Expression<Bool>("rememberMe")
let sortOption = Expression<String>("sortOption")
let targetLang = Expression<String>("targetLang")
let sourceLang = Expression<String>("sourceLang")
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
        t.column(localId)
        t.column(locallyDeleted)
        t.column(serverId)
        t.column(versionNo)
        t.column(serverAndLocalId)
        
        t.primaryKey(serverAndLocalId)
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
        
        t.column(targetLang)
        t.column(sourceLang)
        t.column(serverAndLocalId)
        
        t.foreignKey(serverAndLocalId, references: files[serverAndLocalId], update: .Cascade, delete: .Cascade)
    }
    
    let cards = db["cards"]
    db.create(table: cards, ifNotExists: true) { t in
        t.column(belongTo)
        t.column(collectedAt)
        t.column(context)
        t.column(detail)
        t.column(target)
        t.column(translation)
        
        t.column(targetLang)
        t.column(sourceLang)
        t.column(serverAndLocalId)
        
        t.foreignKey(serverAndLocalId, references: files[serverAndLocalId], update: .Cascade, delete: .Cascade)
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
        t.column(serverAndLocalId)
        
        t.foreignKey(serverAndLocalId, references: files[serverAndLocalId], update: .Cascade, delete: .Cascade)
    }
    
    return (files, users, cards, reqIdCandidates)
}

let tables = setupTables(db)

func insertFile(#db: Database, #f: File) -> Int? {
    return tables.files.insert(lastModifiedAtLocal <- f.lastModifiedAtLocal0, lastModifiedAtServer <- f.lastModifiedAtServer0, localId <- f.localId0, locallyDeleted <- f.locallyDeleted0, serverId <- f.serverId0, versionNo <- f.versionNo0, serverAndLocalId <- f.serverAndLocalId0)
}

func insertUser(#db: Database, #u: User) -> Int? {
    return tables.users.insert(activated <- u.activated0, deviceInfoId <- u.deviceInfoId0, deviceUuid <- u.deviceUuid0, email <- u.email0, isLoggedIn <- u.isLoggedIn0, isSharing <- u.isSharing0, sortOption <- u.sortOption0, targetLang <- u.targetLang0, sourceLang <- u.sourceLang0, serverAndLocalId <- u.serverAndLocalId0)
}

func insertCard(#db: Database, #c: Card) -> Int? {
    return tables.cards.insert(belongTo <- c.belongTo0, collectedAt <- c.collectedAt0, context <- c.context0, detail <- c.detail0, target <- c.target0, translation <- c.translation0, targetLang <- c.targetLang0, sourceLang <- c.sourceLang0, serverAndLocalId <- c.serverAndLocalId0)
}

func insertReqIdCandidate(#db: Database, #r: ReqIdCandidate) -> Int? {
    return tables.reqIdCandidates.insert(lastModifiedAtLocal <- r.lastModifiedAtLocal0, createdAtLocal <- r.createdAtLocal0, done <- r.done0, editAction <- r.editAction0, operationVersion <- r.operationVersion0, reqId <- r.reqId0, serverAndLocalId <- r.serverAndLocalId0)
}

func updateFile(#db: Database, #f: File) -> Int? {
    if let n = tables.files.filter(serverId == f.serverId0).update(lastModifiedAtLocal <- f.lastModifiedAtLocal0, lastModifiedAtServer <- f.lastModifiedAtServer0, localId <- f.localId0, locallyDeleted <- f.locallyDeleted0, serverId <- f.serverId0, versionNo <- f.versionNo0, serverAndLocalId <- f.serverAndLocalId0) {
        return n
    } else {
        return tables.files.filter(localId == f.localId0).update(lastModifiedAtLocal <- f.lastModifiedAtLocal0, lastModifiedAtServer <- f.lastModifiedAtServer0, localId <- f.localId0, locallyDeleted <- f.locallyDeleted0, serverId <- f.serverId0, versionNo <- f.versionNo0, serverAndLocalId <- f.serverAndLocalId0)?
    }
}

func updateUser(#db: Database, #u: User) -> Int? {
    return tables.users.filter(serverAndLocalId == u.serverAndLocalId0).update(activated <- u.activated0, deviceInfoId <- u.deviceInfoId0, deviceUuid <- u.deviceUuid0, email <- u.email0, isLoggedIn <- u.isLoggedIn0, isSharing <- u.isSharing0, sortOption <- u.sortOption0, targetLang <- u.targetLang0, sourceLang <- u.sourceLang0, serverAndLocalId <- u.serverAndLocalId0)
}

func updateCard(#db: Database, #c: Card) -> Int? {
    return tables.cards.filter(serverAndLocalId == c.serverAndLocalId0).update(belongTo <- c.belongTo0, collectedAt <- c.collectedAt0, context <- c.context0, detail <- c.detail0, target <- c.target0, translation <- c.translation0, targetLang <- c.targetLang0, sourceLang <- c.sourceLang0, serverAndLocalId <- c.serverAndLocalId0)
}

func updateReqIdCandidate(#db: Database, #r: ReqIdCandidate) -> Int? {
    return tables.reqIdCandidates.filter(serverAndLocalId == r.serverAndLocalId0).update(lastModifiedAtLocal <- r.lastModifiedAtLocal0, createdAtLocal <- r.createdAtLocal0, done <- r.done0, editAction <- r.editAction0, operationVersion <- r.operationVersion0, reqId <- r.reqId0, serverAndLocalId <- r.serverAndLocalId0)
}

func deleteFile(#db: Database, #f: File) -> Int? {
    if let n = tables.files.filter(serverId == f.serverId0).delete() {
        return n
    } else {
        return tables.files.filter(localId == f.localId0).delete()
    }
}

func deleteUser(#db: Database, #u: User) -> Int? {
    return tables.users.filter(serverAndLocalId == u.serverAndLocalId0).delete()
}

func deleteCard(#db: Database, #c: Card) -> Int? {
    return tables.cards.filter(serverAndLocalId == c.serverAndLocalId0).delete()
}

func deleteReqIdCandidate(#db: Database, #r: ReqIdCandidate) -> Int? {
    return tables.reqIdCandidates.filter(serverAndLocalId == r.serverAndLocalId0).delete()
}

struct CardToShow {
    var collectedAt0 = 0
    var context0 = ""
    var detail0 = ""
    var target0 = ""
    var translation0 = ""
    var serverAndLocalId0 = ""
    
}

func getCards(#db: Database, #userServerId: String) -> [Card] {
    tables.cards.filter(belongTo == userServerId && locallyDeleted == false)
}

