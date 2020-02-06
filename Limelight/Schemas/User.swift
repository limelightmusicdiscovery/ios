//
//  User.swift
//  Limelight
//
//  Created by Athina Vandame on 2019-10-20.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import Foundation
import SwiftAudio
import Firebase
import SDWebImage
import Purchases

struct User {
    static var fcmToken = ""
    static var name = ""
    static var type = ""
    static var birthdate = ""
    static var sex = ""
    static var subscriptionId = ""
    static var isSubscribed = false
    static var listenerPoints = 0
    static var followerIds = [String]()
    static var followingIds = [String]()
    static var following = [LimelightUser]()
    static var followers = [LimelightUser]()
    static var wallComments = [Comment]()
    static var discoverTracks = [Track]()
    static var libraryTracks = [Track]()
    static var likedTracks = [Track]()
    static var dislikedTracks = [Track]()
    static var isArtist = false 
    
    static var cards = [DISCOVERTRACKS: [Track](),
                        LIBRARYTRACKS: [Track](),
                        LIKEDTRACKS: [Track](),
                        DISLIKEDTRACKS: [Track](),
                        UPLOADEDTRACKS: [Track](),
                        DAILYTOPTRACKS: [Track](),
                        WEEKLYTOPTRACKS: [Track](),
                        MONTHLYTOPTRACKS: [Track](),
                        SEARCHEDTRACKS: [Track]()]
    
    static var sources = [DISCOVERTRACKS: [AudioItem](),
                          LIBRARYTRACKS: [AudioItem](),
                          LIKEDTRACKS: [AudioItem](),
                          DISLIKEDTRACKS: [AudioItem](),
                          UPLOADEDTRACKS: [AudioItem](),
                          DAILYTOPTRACKS: [AudioItem](),
                          WEEKLYTOPTRACKS: [AudioItem](),
                          MONTHLYTOPTRACKS: [AudioItem](),
                          SEARCHEDTRACKS: [AudioItem]()]
    
    static var trackKeys = [DISCOVERTRACKS: [String](),
                            LIBRARYTRACKS: [String](),
                            LIKEDTRACKS: [String](),
                            DISLIKEDTRACKS: [String](),
                            UPLOADEDTRACKS: [String](),
                            DAILYTOPTRACKS: [String](),
                            WEEKLYTOPTRACKS: [String](),
                            MONTHLYTOPTRACKS: [String](),
                            BLACKLISTTRACKS: [String](),
                            SEARCHEDTRACKS: [String]()]
    
    
    
    
    static var discoveryBlacklist = [String]()
    static var socials = [APPLEMUSIC: "",
                          SOUNDCLOUD: "",
                          SPOTIFY: "",
                          TWITTER: "",
                          INSTAGRAM: "",
                          LIMELIGHT: ""]
    static var imageUrl = ""
    static var location = [LATITUDE: 0.0,
                           LONGITUDE: 0.0,
                           CITY: "",
                           STATE: "",
                           COUNTRY: ""] as [String : Any]
    static var uid = ""
    static var username = ""
    static var email = ""
    static var bio = ""
    static var socialClicks = [APPLEMUSIC: 0,
                               SOUNDCLOUD: 0,
                               SPOTIFY: 0,
                               TWITTER: 0,
                               INSTAGRAM: 0,
                               LIMELIGHT: 0]
    static var comments = [Comment]()
    static var password = ""
    static var profileImpressionCount = 0
    static var outreachIn50km = 0
    
}
