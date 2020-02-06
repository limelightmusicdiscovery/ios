//
//  ArtistSubscription.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-12-25.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import Foundation
import Purchases

struct Subscription {
    static var id = ""
    static var entitlementId = ""
    static var uid = ""
    static var latestPurchaseDate = 0
    static var originalPurchaseDate = 0
    static var expirationPurchaseDate = 0
    static var store: Purchases.Store?
    static var isActive = false
    static var willRenew = false
    static var periodType: Purchases.PeriodType?
    static var planType = ""
    static var startingRadius = 50
   
    static var boosts = [Boost]() //change this to array of type Boost
    static var tracksAvailable = 0
    static var uploadedTrackKeys = [String]()
    static var originalAppVersion = ""
    
}

struct Boost{
    var id = ""
    var entitlementId = ""
    var uid = ""
    var boostType = ""
    var distanceRadius = ""
    var createdAt = 0
    var effectiveUntil = 0
    var outreachAtStart = 0
    var outreachAtEnd = 0
   
 
    
    init(id: String, entitlementId: String, uid: String, boostType: String, createdAt: Int, effectiveUntil: Int, outreachAtStart:Int,outreachAtEnd: Int) {
        self.id = id
        self.entitlementId = entitlementId
        self.uid = uid
        self.boostType = boostType
        self.createdAt = createdAt
        self.effectiveUntil = effectiveUntil
        self.outreachAtStart = outreachAtStart
        self.outreachAtEnd = outreachAtEnd
     
      
    }
}

