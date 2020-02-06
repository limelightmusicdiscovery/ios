//
//  FirebaseManager.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-22.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import Foundation
import Firebase
import GeoFire
import Alamofire
import SwiftyJSON

struct FirebaseManager {
    static var db = Firestore.firestore()
    static var fcmTokenDict = [String: String]()
    static func updateFcmToken() {
        
    
         let token = Messaging.messaging().fcmToken
        let defaults = UserDefaults.standard
        if let uid = defaults.string(forKey: SavedKeys.uid) {
            
            if token != "" {
                db.collection("users").document(uid).setData([
                                                                 "fcmToken": token ?? ""
                                                               
                                                             ], merge: true)
            }
                
                
        }
        User.fcmToken = token ?? ""
        print("FCM Updated:  \(token ?? "")")
        

  
                               
    }
    static func setTrackGeohash(uid: String, trackId: String) {
        let geofireRef = Database.database().reference().child("Geofire")
               let geoFire = GeoFire(firebaseRef: geofireRef)
               guard let latitude = User.location[LATITUDE] as? CLLocationDegrees else {
                   print("cancelled geofiresuser add, no lat")
                   return
               }
               
               guard let longitude = User.location[LONGITUDE]  as? CLLocationDegrees else {
                   print("cancelled geofireuser add, no long")
                   return
               }
               geoFire.setLocation(CLLocation(latitude: latitude , longitude:longitude), forKey: trackId) { (error) in
                   if (error != nil) {
                       print("An error occured: \(error)")
                   } else {
                       print("Saved location successfully for track")
                }
        }
    }
    
    static func getUserInfoForTracks(source: String) {
        let db = Firestore.firestore()
        var i = 0
        var tracks = [Track]()
        while i < (User.cards[source]?.count ?? 0) - 1 {
            print("Attempting for \( User.cards[source]?[i].artistUid)")
            db.collection("users").document(User.cards[source]?[i].artistUid ?? BIZLALUID).getDocument() { (document, err) in
                if err != nil {
                    // Some error occured
                    print("Error For: \( User.cards[source]?[i].artistUid)")
                } else {
                      let data = document?.data()
                     let imgUrl = data?["photoUrl"] as? String ?? "N/A"
                    let username = data?["username"] as? String ?? "N/A"
                    let fcmToken = data?["fcmToken"] as? String ?? "N/A"
                    let uid = data?["uid"] as? String ?? "N/A"
                   
                    print("Attempting track adjust for \(username): \(fcmToken)")
                    
                    fcmTokenDict[uid] = fcmToken
                   
       
                   
                
                }
            }
            i = i + 1
        }
       

        

    }


    static func updateUserLocation(uid: String){
        
        let geofireRef = Database.database().reference().child("GeofireUsers")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        guard let latitude = User.location[LATITUDE] as? CLLocationDegrees else {
            print("cancelled geofiresuser add, no lat")
            return
        }
        
        guard let longitude = User.location[LONGITUDE]  as? CLLocationDegrees else {
            print("cancelled geofireuser add, no long")
            return
        }
        geoFire.setLocation(CLLocation(latitude: latitude , longitude:longitude), forKey: uid) { (error) in
            if (error != nil) {
                print("An error occured: \(error)")
            } else {
                print("Saved location successfully for user")
                let token = "139f44dca310cf"
                Alamofire.request("https://us1.locationiq.com/v1/reverse.php?key=\(token)&lat=\(latitude)&lon=\(longitude)&format=json")
                    .responseJSON { response in
                        
                        switch response.result {
                        case .success(let result):
                            // do what you need
                            
                            let swiftyJSONVar = JSON(result)
                            
                            
                            let city = swiftyJSONVar["address"]["city"].stringValue
                            let state = swiftyJSONVar["address"]["state"].stringValue
                            let country = swiftyJSONVar["address"]["country"].stringValue
                            
                            User.location[CITY] = city
                            User.location[STATE] = state
                            User.location[COUNTRY] = country
                            print("geocoding success location: \(city), \(state), \(country)")
                            
                            let db = Firestore.firestore()
                            
                            db.collection("users").document(User.uid).setData([
                                "latitude": latitude,
                                "longitude": longitude,
                                "city": city,
                                "state": state,
                                "country": country,
                                "lastSignIn": NSDate().timeIntervalSince1970
                            ], merge: true)
                            
                            
                        case .failure(let error):
                            // do what you need
                            
               
                            print("Error geocoding location: \(error)")
                        }
                }
            }
            
        }
    }
}


