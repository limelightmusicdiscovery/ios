//
//  Artist.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-18.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import Foundation

struct Artist{
    var uid = ""
    var subscriptionId = ""
    var username = ""
    var name = ""
    var bio = ""
    var profileImage = ""
    var totalStreams = 0
    var totalListeners = 0
    var signUpDate = 0
    var trackKeys = [String]()
    var tracks = [Track]()
    var followerKeys = [String]()
    var followingKeys = [String]()
    var verified = false
    var socials = [APPLEMUSIC: "",
                          SOUNDCLOUD: "",
                          SPOTIFY: "",
                          TWITTER: "",
                          INSTAGRAM: "",
                          LIMELIGHT: ""]
  
    var location = [LATITUDE: 0.0,
                           LONGITUDE: 0.0,
                           CITY: "",
                           STATE: "",
                           COUNTRY: ""] as [String : Any]
    var profileImpressions = 0
   
    
    init(uid: String, subscriptionId: String, username: String, name: String,bio: String, profileImage: String, totalStreams: Int, totalListeners: Int, signUpDate: Int, trackKeys: [String], tracks: [Track], followerKeys: [String], followingKeys: [String], verified: Bool, socials: [String: String], location: [String: Any], profileImpressions: Int) {
             
          
       self.uid = uid
          self.subscriptionId = subscriptionId
          self.username = username
        self.name = name
        self.bio = bio
          self.profileImage = profileImage
          self.totalStreams = totalStreams
          self.totalListeners = totalListeners
          self.signUpDate = signUpDate
         self.trackKeys = trackKeys
          self.tracks = tracks
          self.followerKeys = followerKeys
         self.followingKeys = followingKeys
          self.verified = verified
        self.socials = socials
        self.location = location
        self.profileImpressions = profileImpressions
    }
}
