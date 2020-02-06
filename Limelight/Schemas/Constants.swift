//
//  Constants.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-10-19.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import Foundation
import UIKit

//
// User
//

// Type
let LISTENER = "listener"
let ARTIST = "artist"

// Subscription type for artists
let BASIC = "BASIC"
let PLUS = "PLUS"
let PRO = "PRO"

// Socials
let APPLEMUSIC = "applemusic"
let SOUNDCLOUD = "soundcloud"
let SPOTIFY = "spotify"
let TWITTER = "twitter"
let INSTAGRAM = "instagram"
let LIMELIGHT = "limelight"

// Location
let LATITUDE = "latitude"
let LONGITUDE = "longitude"
let CITY = "city"
let STATE = "state"
let COUNTRY = "country"

// Stream Source
let DISCOVER = "discover"
let LIBRARY = "library"
let LIKED = "liked"
let DISLIKED = "disliked"

// Audio Sources
let LIBRARYTRACKS = "libraryTracks"
let DISCOVERTRACKS = "discoverTracks"
let LIKEDTRACKS = "likedTracks"
let DISLIKEDTRACKS = "dislikedTracks"
let UPLOADEDTRACKS = "uploadedTracks"
let SEARCHEDTRACKS = "searchedTracks"
let DAILYTOPTRACKS = "dailyTopChartTracks"
let WEEKLYTOPTRACKS = "weeklyTopChartTracks"
let MONTHLYTOPTRACKS = "monthlyTopChartTracks"
let YEARLYTOPTRACKS = "yearlyTopChartTracks"
let BLACKLISTTRACKS = "blacklistTracks"

let TRACKOPTIONSHEIGHT = CGFloat(575)
let TRACKOPTIONSSPEED = 0.3
let TRACKOPTIONSCORNER = CGFloat(35)

let TRACKS = "Tracks"
let ARTISTS = "Artists"
let LISTENERS = "Listeners"

let BESTSORTED = "bestSorted"
let NEARESTSORTED = "nearestSorted"

let BIZLALUID = "RyFcbEUP8IUucwNSbLoft6JovZJ3"

let PROARTIST = "PRO"
let PLUSARTIST = "PLUS"
let BASICARTIST = "BASIC"

let PROSTARTRADIUS = 200
let PLUSSTARTRADIUS = 100
let BASICSTARTRADIUS = 50

let PROTRACKCOUNT = 9999
let PLUSTRACKCOUNT = 10
let BASICTRACKCOUNT = 2

let PROOUTREACH = 3000
let PLUSOUTREACH = 2000
let BASICOUTREACH = 1000

let REVENUECATAPIKEY = "WrwlGtJdqDtNuJVDPddygFFgWdbLHVSY"


let DEFAULTCOVERIMAGE = UIImage(named: "coverDefaultImage")
let DEFAULTCOVERURL = "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/eb777e7a-7d3c-487e-865a-fc83920564a1/d7kpm65-437b2b46-06cd-4a86-9041-cc8c3737c6f0.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2ViNzc3ZTdhLTdkM2MtNDg3ZS04NjVhLWZjODM5MjA1NjRhMVwvZDdrcG02NS00MzdiMmI0Ni0wNmNkLTRhODYtOTA0MS1jYzhjMzczN2M2ZjAuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.-bP80wHw6Jb8moQRsxURQxONZvAMnJ6xLDD8Es7mHps"

let MAXCACHEIMAGES = 20
let BACKGROUNDGRADIENT = [UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1), UIColor(red: 33/255, green: 10/255, blue: 56/255, alpha: 1)]
let LIMELIGHTGRADIENT = [UIColor(red: 109/255, green: 38/255, blue: 185/255, alpha: 1), UIColor(red: 219/255, green: 75/255, blue: 156/255, alpha: 1),UIColor(red: 66/255, green: 209/255, blue: 245/255, alpha: 1)]
let LIMELIGHTGRADIENTCG = [UIColor(red: 109/255, green: 38/255, blue: 185/255, alpha: 1).cgColor, UIColor(red: 219/255, green: 75/255, blue: 156/255, alpha: 1).cgColor,UIColor(red: 66/255, green: 209/255, blue: 245/255, alpha: 1).cgColor]
let LIMELIGHTPURPLE = UIColor(red: 167/255, green: 108/255, blue: 229/255, alpha: 1)

//UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors:[UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1), UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1),UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1), UIColor(red: 45/255, green: 14/255, blue: 78/255, alpha: 1)])


//FIREBASE EVENTS

let TRACKUPLOADEVENT = "trackUploaded"
let OUTREACHEVENT = "outreach50KM"
let CARDLIKEEVENT = "cardLike"
let CARDDISLIKEEVENT = "cardDislike"
let TRACKCOMMENTEVENT = "trackComment"
let TRACKSTREAMEVENT = "trackStreamed"
let TRACKACTIONEVENT = "trackAction"
