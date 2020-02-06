//
//  Track.swift
//  Limelight
//
//  Created by Athina Vandame on 2019-10-20.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import Foundation
import SwiftAudio

struct Track {
    var artistUsername = ""
    var artistUid = ""
    var genre = ""
    var albumTitle = ""
    var description = ""
    var imageUrl = ""
    var socials = [APPLEMUSIC: "",
                          SOUNDCLOUD: "",
                          SPOTIFY: "",
                          LIMELIGHT: ""]
    var socialClicks = [APPLEMUSIC: 0,
                               SOUNDCLOUD: 0,
                               SPOTIFY: 0,
                               LIMELIGHT: 0]
    var radius = 0 //Stored in KM
    var streamCount = 0
    var uploadDate = 0
    var likeCount = 0
    var dislikeCount = 0
    var commentCount = 0
    var title = ""
    var trackUrl = ""
    var trackId = ""
    var latitude = 0.0
    var longitude = 0.0
    var city = ""
    var state = ""
    var country = ""
    var trackSource = ""
    var audioItem: AudioItem?
    var avgCoverColor: UIColor
    var comments = [Comment]()
    var likePercentage = 0.0
    var fcmToken = ""
    var outreach = 0
   
   
    
    init(artistUsername: String, artistUid: String, genre: String, albumTitle: String, description: String,
         imageUrl: String, socials: [String: String], socialClicks: [String: Int], radius: Int, streamCount: Int, uploadDate: Int, likeCount: Int, dislikeCount: Int, commentCount: Int, title: String, trackUrl: String, trackId: String, latitude: Double, longitude: Double, city: String, state: String, country: String, trackSource: String, audioItem: AudioItem, avgCoverColor: UIColor, comments: [Comment], likePercentage: Double, fcmToken: String, outreach: Int) {
        
        
           
           self.artistUsername = artistUsername
           self.title = title
           self.genre = genre
           self.imageUrl = imageUrl
           self.albumTitle = albumTitle
           self.trackUrl = trackUrl
           self.trackSource = trackSource
           self.radius = radius
           self.latitude = latitude
           self.longitude = longitude
           self.city = city
           self.state = state
           self.country = country
           self.artistUid = artistUid
           self.radius = radius
           self.trackId = trackId
           self.uploadDate = uploadDate
           self.streamCount = streamCount
           self.likeCount = likeCount
           self.dislikeCount = dislikeCount
        self.commentCount = commentCount
           self.socials = socials
           self.socialClicks = socialClicks
           self.trackId = trackId
           self.audioItem = audioItem
           self.avgCoverColor = avgCoverColor
           self.comments = comments
           self.likePercentage = likePercentage
        self.fcmToken = fcmToken
        self.outreach = outreach
          

           
       }
       
}
