//
//  Stream.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-31.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import Foundation

struct Stream {
    var city = ""
    var state = ""
    var country = ""
    var source = ""
    var streamedByUid = ""
    var trackId = ""
    var date = ""
    
    init(city: String, state: String, country: String, source: String, streamedByUid: String, trackId: String, date: String) {
             
             self.city = city
             self.state = state
             self.country = country
             self.source = source
             self.streamedByUid = streamedByUid
        self.trackId = trackId
        self.date = date
            
    }
}
