//
//  LimelightUser.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-12-20.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import Foundation


struct LimelightUser {
    var uid = ""
    var username = ""
    var name = ""
    var profileImage = ""
    var listenerPoints = 0
    var followerKeys = [String]()
    var followingKeys = [String]()
    var following = [LimelightUser]()
    var followers = [LimelightUser]()
    var isFollowing = false
    
    init(uid: String, username: String, name: String, profileImage: String, listenerPoints: Int, followerKeys: [String],followingKeys: [String], following: [LimelightUser], followers: [LimelightUser], isFollowing: Bool) {
             
            self.uid = uid
             self.username = username
        self.listenerPoints = listenerPoints
        self.followerKeys = followerKeys
        self.followingKeys = followingKeys
        self.following = following
        self.followers = followers 
             
        self.profileImage = profileImage
             self.name = name
        self.isFollowing = isFollowing
            
    }
}
