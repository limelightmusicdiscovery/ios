//
//  Track.swift
//  Limelight
//
//  Created by Athina Vandame on 2019-10-20.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import Foundation

struct Track {
    static var artistUid = ""
    static var genre = ""
    static var albumTitle = ""
    static var description = ""
    static var imageUrl = ""
    static var socials = [APPLEMUSIC: "",
                          SOUNDCLOUD: "",
                          SPOTIFY: "",
                          LIMELIGHT: ""]
    static var socialClicks = [APPLEMUSIC: 0,
                               SOUNDCLOUD: 0,
                               SPOTIFY: 0,
                               LIMELIGHT: 0]
    static var radius = 0 //Stored in KM
    static var streamCount = 0
    static var uploadDate = 0
    static var likedCount = 0
    static var dislikeCount = 0
    static var title = ""
    static var trackUrl = ""
    static var trackId = ""
    static var comments = []
}
