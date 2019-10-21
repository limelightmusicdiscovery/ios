//
//  Structures.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-10-19.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//
 // swiftlint:disable vertical_whitespace line_length unused_closure_parameter trailing_whitespace identifier_name function_body_length

import Foundation
import UIKit



enum SavedKeys {
    static let username = ""
    static let email = ""
    static let password = ""
    static let uid = ""

}

struct User {
    static var alias = ""
    static var type = ""
    static var subscription = ""
    static var library = [String]()
    static var likedTracks = [String]()
    static var dislikedTracks = [String]()
    static var following = [String]()
    static var followers = [String]()
    static var discoverBlacklist = [String]()
    static var socials = ["applemusic": "",
                          "soundcloud": "",
                          "spotify": "",
                          "twitter": "",
                          "instagram": "",
                          "limelight": ""]
    static var imageUrl = ""
    static var location = ["latitude": 0,
                           "longitude": 0,
                           "city": "",
                           "state": "",
                           "country": ""] as [String: Any]
    static var uid = ""
    static var username = ""
    static var email = ""
    static var bio = ""
    static var socialClicks = ["applemusic": 0,
                               "soundcloud": 0,
                               "spotify": 0,
                               "twitter": 0,
                               "instagram": 0,
                               "limelight": 0]
}

struct Track {
    static var artistUid = ""
    static var genre = ""
    static var albumTitle = ""
    static var description = ""
    static var imageUrl = ""
    static var socials = ["applemusic": "",
                          "soundcloud": "",
                          "spotify": "",
                          "limelight": ""]
    static var socialClicks = ["applemusic": 0,
                               "soundcloud": 0,
                               "spotify": 0,
                               "limelight": 0]
    static var radius = 0 //KM
    static var streamCount = 0
    static var datePosted = 0
    static var likedCount = 0
    static var dislikeCount = 0
    static var title = ""
    static var trackUrl = ""
    static var trackId = ""
}


struct SampleCardModel {
    let name: String
    let age: Int
    let occupation: String?
    let image: UIImage?
}

extension UIView {
    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, paddingTop: CGFloat = 0, paddingLeft: CGFloat = 0, paddingBottom: CGFloat = 0, paddingRight: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: paddingTop))
        }
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: paddingLeft))
        }
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom))
        }
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -paddingRight))
        }
        if width > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: width))
        }
        if height > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: height))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
    
    @discardableResult
    func anchorToSuperview() -> [NSLayoutConstraint] {
        return anchor(top: superview?.topAnchor, left: superview?.leftAnchor, bottom: superview?.bottomAnchor, right: superview?.rightAnchor)
    }
}

extension UIView {
    func applyShadow(radius: CGFloat, opacity: Float, offset: CGSize, color: UIColor = .black) {
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
    }
}

