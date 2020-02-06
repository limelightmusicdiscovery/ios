//
//  Comment.swift
//  Limelight
//
//  Created by Athina Vandame on 2019-10-21.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import Foundation

// Comments are used on a User's wall and on a Track
// TODO future feature: comment threads
// Not necessary right now?

struct Comment {
    var text = ""
    var username = ""
    var uid = ""
    var profileImage = ""
    var datePosted = 0
    var commentId = ""
    var fcmToken = ""
    
    init(text: String, username: String, uid: String, profileImage: String, datePosted: Int, commentId: String, fcmToken: String) {
             
             self.text = text
             self.username = username
             self.uid = uid
        self.profileImage = profileImage
             self.datePosted = datePosted
        self.commentId = commentId
        self.fcmToken = fcmToken
            
    }
}
