//
//  NotificationCenter.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-28.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import Foundation


extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
    static let didCompleteTask = Notification.Name("didCompleteTask")
    static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
    static let trackUploaded = Notification.Name("trackUploaded")
    static let logout = Notification.Name("logout")
}
