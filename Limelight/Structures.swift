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

