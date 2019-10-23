//
//  User.swift
//  Limelight
//
//  Created by Athina Vandame on 2019-10-20.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import Foundation

struct User {
    static var alias = ""
    static var type = ""
    static var subscription = ""
    static var library = [String]()
    static var likedTracks = [String]()
    static var dislikedTracks = [String]()
    static var following = [String]()
    static var followers = [String]()
    static var discoveryBlacklist = [String]()
    static var socials = [APPLEMUSIC: "",
                          SOUNDCLOUD: "",
                          SPOTIFY: "",
                          TWITTER: "",
                          INSTAGRAM: "",
                          LIMELIGHT: ""]
    static var imageUrl = ""
    static var location = [LATITUDE: 0,
                           LONGITUDE: 0,
                           CITY: "",
                           STATE: "",
                           COUNTRY: ""] as [String: Any]
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
    static var comments = [] 
}
