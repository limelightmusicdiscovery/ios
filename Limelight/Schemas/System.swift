//
//  System.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-29.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import Foundation
import Firebase
import SwiftAudio
import SDWebImage
import Purchases
import SwiftMessages

struct System {
    static var tabBarController = UITabBarController()
    static var currentTrack = Track.self
    static var addedCardAudioListeners = false
    static var addedMPAudioListeners = false
    static var removedMPAudioListeners = false
    static var frame = CGRect()
    static var showingMP = false
    static var db = Firestore.firestore()
    static var push = PushNotificationSender()
    static var searchController = UISearchController(searchResultsController: nil)
    static var messageConfig = SwiftMessages.defaultConfig
    static func showMessage(title: String, body: String, duration: Double, type: Theme, image: UIImage?){
           
           let message = MessageView.viewFromNib(layout: .tabView)
                              message.configureTheme(type)
                              message.configureDropShadow()
                            
                                   
                              self.messageConfig.duration = .seconds(seconds: duration)
                              
        if image != nil {
            guard let trackImage = image?.sd_resizedImage(with: CGSize(width: 50, height: 50), scaleMode: .aspectFill) else {
                message.configureContent(title: title, body: body)
                message.button?.isHidden = true
                                              
                                             SwiftMessages.show(config: self.messageConfig, view: message)
                          self.messageConfig.duration = .seconds(seconds: 1.5)
                return
            }
             message.configureContent(title: title, body: body, iconImage: trackImage)
        }else {
              message.configureContent(title: title, body: body)
        }
       
    
                            
                              //error.button?.setTitle("Stop", for: .normal)
                              message.button?.isHidden = true
                               
                              SwiftMessages.show(config: self.messageConfig, view: message)
           self.messageConfig.duration = .seconds(seconds: 1.5)
       }
    static var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    static var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    static func flag(from country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }
    //profile actions
    
    static var imageDownloader =  SDWebImageManager()
    
    static func checkIfFollowing(uidToCheck: String, uid: String, completion: @escaping (_ action: String) -> Void){
        
        
        let docRef = db.collection("users").document(User.uid).collection("userFollowing").document(uidToCheck)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                
                unfollowUser(userUnfollowed: uidToCheck, uid: uid) { (done) in
                    if done {
                        print("user \(uid) unfollowed \(uidToCheck)")
                        
                        guard let followingIndex = User.followingIds.firstIndex(of: uidToCheck) else {
                            return
                        }
                        
                        if followingIndex != -1{
                            User.followingIds.remove(at: followingIndex)
                        }
                        
                        completion("unfollow")
                        
                    }else{
                        print("error user \(uid) unfollowing \(uidToCheck)")
                        completion("error")
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
                    }
                }
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
                followUser(userFollowed: uidToCheck, followedByUser: uid) { (done) in
                    if done {
                        print("user \(uid) followed \(uidToCheck)")
                        
                        User.followingIds.append(uidToCheck)
                        completion("follow")
                    }else{
                        print("error user \(uid) following \(uidToCheck)")
                        completion("error")
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
                    }
                }
                
                
            }
        }
    }
    
    static func unfollowUser(userUnfollowed: String, uid: String, completion: @escaping (_ done: Bool) -> Void){
        
        db.collection("users").document(User.uid).collection("userFollowing").document(userUnfollowed).delete() { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)
            } else {
                print("Document successfully deleted")
                
                db.collection("users").document(userUnfollowed).collection("userFollowers").document(User.uid).delete(){ err in
                    if let err = err {
                        print("Error writing document: \(err)")
                        completion(false)
                    } else {
                        print("Document successfully unfollowed")
                        completion(true)
                        
                    }
                }
            }
        }
        
    }
    
    static func followUser(userFollowed: String, followedByUser: String, completion: @escaping (_ done: Bool) -> Void){
        
        db.collection("users").document(User.uid).collection("userFollowing").document(userFollowed).setData([
            "date": NSDate().timeIntervalSince1970,
            "uid": userFollowed
            
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)
            } else {
                print("Document successfully written!")
                
                db.collection("users").document(userFollowed).collection("userFollowers").document(User.uid).setData([
                    "date": NSDate().timeIntervalSince1970,
                    "uid": User.uid
                    
                    
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                        completion(false)
                    } else {
                        print("Document successfully written!")
                        completion(true)
                        
                    }
                }
            }
        }
        
    }
    
    static func postToWallByUid(text: String, uid: String, completion: @escaping (_ done: Bool) -> Void){
        
        
        db.collection("users").document(uid).collection("wallPosts").addDocument(data: [
            "dateCreated": NSDate().timeIntervalSince1970,
            "uid": User.uid,
            "likes": 0,
            "text": text]
            
        ) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)
            } else {
                print("Document successfully written!")
                completion(true)
                //self.following = true
            }
        }
        
    }
    
    static func getWallPosts2(uid: String, completion: @escaping (_ wallPosts: [Comment]) -> Void){
        
        var wallPosts = [Comment]()
        
        db.collection("users").document(uid).collection("wallPosts").order(by: "dateCreated", descending: false).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(wallPosts)
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    
                    
                    let date = data["dateCreated"] as? Double ?? 0.0
                    
                    let uid = data["uid"] as? String ?? "None"
                    let likes = data["likes"] as? Int ?? 0
                    let text = data["text"] as? String ?? "None"
                    
                    let location = data["location"] as? String ?? ""
                    let commentId = document.documentID
                    
                    db.collection("users").document(uid).getDocument() { (document, err) in
                        if err != nil {
                            // Some error occured
                            print("Error ")
                        } else {
                            let data = document?.data()
                            let imgUrl = data?["photoUrl"] as? String ?? "N/A"
                            let username = data?["username"] as? String ?? "N/A"
                            let fcmToken = data?["fcmToken"] as? String ?? "N/A"
                            
                            let comment = Comment(text: text, username: username, uid: uid, profileImage: imgUrl, datePosted: Int(date), commentId: commentId, fcmToken: fcmToken)
                            
                            
                            wallPosts.append(comment)
                            
                            
                            
                        }
                    }
                }
                
            }
            
            print("wallPost Count: \(wallPosts.count)")
            completion(wallPosts)
            
            
            
            
        }
        
        
    }
    
    static func getWallPosts(uid: String, completion: @escaping (_ wallPosts: [Comment]) -> Void){
        var wallPosts = [Comment]()
        
        db.collection("users").document(uid).collection("wallPosts").order(by: "dateCreated", descending: false).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(wallPosts)
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    let date = data["dateCreated"] as? Double ?? 0.0
                    
                    let uid = data["uid"] as? String ?? "None"
                    
                    let text = data["text"] as? String ?? "None"
                    
                    let commentId = document.documentID
                    
                    let post = Comment(text: text, username: "N/A", uid: uid, profileImage: "N/A", datePosted: Int(date), commentId: commentId, fcmToken: "")
                    wallPosts.append(post)
                    
                    
                    
                }
                
                completion(wallPosts)
                
                
            }
        }
        
        
    }
    
    static func getCurrentUserDetailForPosts(posts: [Comment], completion: @escaping (_ fixedPosts: [Comment]) -> Void){
        
        var fixedPosts = posts
        var i = 0
        for post in posts {
            
            db.collection("users").document(post.uid).getDocument() { (document, err) in
                if err != nil {
                    // Some error occured
                    print("getting Error ")
                    i = i + 1
                    
                } else {
                    let data = document?.data()
                    let imgUrl = data?["photoUrl"] as? String ?? "N/A"
                    let username = data?["username"] as? String ?? "N/A"
                    
                    fixedPosts[i].profileImage = imgUrl
                    fixedPosts[i].username = username
                    i = i + 1
                    
                }
                
            }
            
        }
        
        completion(fixedPosts)
        
    }
    
    static func getUsersByUids(uids: [String], completion: @escaping (_ users: [LimelightUser]) -> Void){
        
        
        var users = [LimelightUser]()
        var count = 0
        
        
        for uid in uids {
             db.collection("users").document(uid)
                           
                           .getDocument() { (document, err) in
                               if err != nil {
                                   // Some error occured
                                   print("Error For: \(uid)")
                               } else {
                                   
                  let data = document?.data()
                      
                      
                    
                      let username = data?["username"] as? String ?? "None"
                      let name = data?["name"] as? String ?? "None"
                      
                      let profileImage = data?["photoUrl"] as? String ?? "None"
                      let listenerPoints =  data?["listenerPoints"] as? Int ?? 0
                      print("user: \(username)")
                      var isFollowing = false
                      
                                if User.followingIds.contains(uid){
                                                           isFollowing = true
                                                       }
                      
                      
                      
                      let user = LimelightUser(uid: uid, username: username, name: name, profileImage: profileImage, listenerPoints: listenerPoints, followerKeys: [""], followingKeys: [""], following: [LimelightUser](), followers: [LimelightUser](), isFollowing: isFollowing)
                      
                      // self.trackArray.append(track)
                      if user.username != "None"{
                          users.append(user)
                          
                        print("Done For: \(user.name)")
                         
                      }
                      count = count + 1
                                
                                if count == uids.count {
                                    completion(users)
                                }
                        
                    
                }
            }

            
        }
        
       
        
    }
    
    static func getFollowerIdsForUid(uid: String, completion: @escaping (_ followerUids: [String]) -> Void){
        
        
        var followerUids = [String]()
        
        db.collection("users").document(uid).collection("userFollowers").order(by: "date", descending: false).getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting followers: \(err)")
                completion(followerUids)
            } else {
                for document in querySnapshot!.documents {
                    // followerCount = followerCount + 1
                    let data = document.data()
                    let userId = data["uid"] as? String ?? "None"
                    
                    if userId != "None" && !followerUids.contains(document.documentID){
                        followerUids.append(userId)
                    }
                    
                }
                
                completion(followerUids)
                
            }
        }
        
    }
    
    
    static func getFollowingIdsForUid(uid: String, completion: @escaping (_ followingUids: [String]) -> Void){
        
        
        var followingUids = [String]()
        
        db.collection("users").document(uid).collection("userFollowing").order(by: "date", descending: false).getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting followers: \(err)")
                completion(followingUids)
            } else {
                for document in querySnapshot!.documents {
                    // followerCount = followerCount + 1
                    let data = document.data()
                    let userId = data["uid"] as? String ?? "None"
                    
                    if userId != "None" && !followingUids.contains(userId){
                        followingUids.append(userId)
                    }
                    
                }
                
                completion(followingUids)
                
            }
        }
        
    }
    //track actions
    
    static func addTracksToSource(trackArray: [Track], source: String){
        User.sources[source]?.removeAll()
        // loadTracks(source: source)
        var i = 0
        
        while i <  trackArray.count{
            
            if let audioItem = trackArray[i].audioItem {
                User.sources[source]?.append(audioItem)
            }
            
            
            //try? controller.player.add(item: UserInfo.cards[i].audioItem, playWhenReady:false)
            i = i + 1
        }
        //loadTracks(source: source)
        
    }
    
    
    static func getTrackIdsBySource(uid: String, source: String, completion: @escaping (_ trackIds: [String]) -> Void){
        var trackIds = [String]()
        
        db.collection("users").document(uid).collection(source).order(by: "dateAdded", descending: false).getDocuments { (snapshot, error) in
            
            print("Total \(source) documents for \(uid): \(snapshot!.count)")
            if let error = error
            {
                print("Error getting documents from \(source) for \(uid): \(error)");
            }
            else
            {
                
                for document in snapshot!.documents {
                    let data = document.data()
                    let trackId = data["trackId"] as? String ?? "None"
                    
                    if trackId != "None" && !(trackIds.contains(trackId) ){
                        trackIds.append(trackId)
                        
                    }else{
                        print("\(source) already contains \(trackId) for \(uid)")
                    }
                    
                    
                }
                
                completion(trackIds)
                
            }
            
            
        }
        
    }
    
    static func getTracksByIdsForSource(source: String, trackIds: [String], completion: @escaping (_ tracks: [Track]) -> Void){
        var tracks = [Track]()
        
        for trackId in trackIds{
            
            
            let db = Firestore.firestore()
            
            print("Attempting For: \(trackId)")
            db.collection("all-tracks").document(trackId)
                
                .getDocument() { (document, err) in
                    if err != nil {
                        // Some error occured
                        print("Error For: \(trackId)")
                    } else {
                        
                        let data = document?.data()
                        
                        
                        _ = data?["artist"] as? String ?? "None"
                        _ = data?["producer"] as? String ?? "None"
                        let username = data?["username"] as? String ?? "None"
                        let trackName = data?["title"] as? String ?? "None"
                        let description = data?["description"] as? String ?? "None"
                        let genre = data?["genre"] as? String ?? "None"
                        let coverURL = data?["imgUrl"] as? String ?? "None"
                        _ = data?["username"] as? String ?? "None"
                        let albumName = data?["album_title"] as? String ?? "None"
                        let trackURL = data?["trackUrl"] as? String ?? "http://www.noiseaddicts.com/samples_1w72b820/2514.mp3"
                        let radius = data?["radius"] as? String ?? "0"
                        
                        let latitude = data?["latitude"] as? String ?? "0.0"
                        let longitude = data?["longitude"] as? String ?? "0.0"
                        
                        
                        let city = data?["city"] as? String ?? "None"
                        let state = data?["state"] as? String ?? "None"
                        let country = data?["country"] as? String ?? "None"
                        let uid = data?["uid"] as? String ?? "None"
                        _ = document?.documentID
                        let unixDate = data?["time"] as? Int ?? 1561696540741
                        _ = data?["likedBy"] as? [String: Any] ?? ["false":"false"]
                        _ = data?["dislikedBy"] as? [String: Any] ?? ["false":"false"]
                        let streamCount = data?["streamCount"] as? Int ?? 0
                        let soundcloudLink = data?["soundcloudLink"] as? String ?? "None"
                        let spotifyLink = data?["spotifyLink"] as? String ?? "None"
                        let itunesLink = data?["itunesLink"] as? String ?? "None"
                        let Id = document?.documentID
                        let totalLikes =  data?["totalLikes"] as? Int ?? 0
                        let totalDislikes =  data?["totalDisikes"] as? Int ?? 0
                        let limelightLink = "" //need to finish
                        
                        let trackRadius = Int(radius) ?? 0
                        let trackLatitude = Double(latitude) ?? 0.0
                        let trackLongitude = Double(longitude) ?? 0.0
                        
                       
                        let audioItem = DefaultAudioItem(audioUrl: String(trackURL), artist: String(username), title: String(trackName), albumTitle: String(albumName), sourceType: .stream ,artwork: #imageLiteral(resourceName: "coverDefaultImage"))
                        
                        var likePercentage = 0.0
                        let commentCount =  data?["commentCount"] as? Int ?? 0
                        
                        
                        if totalLikes != 0 && totalDislikes != 0 {
                            let totalLikeDislikeCount = totalLikes + totalDislikes
                            likePercentage = (Double(totalLikes) / Double(totalLikeDislikeCount))
                            print("\(trackName): \(likePercentage)% [\(totalLikes) + \(totalDislikes) = \(totalLikeDislikeCount)]")
                        }
                        
                        
                        let track = Track(artistUsername: username, artistUid: uid, genre: genre, albumTitle: albumName, description: description, imageUrl: coverURL, socials:[APPLEMUSIC: itunesLink,
                                                                                                                                                                                SOUNDCLOUD: soundcloudLink,
                                                                                                                                                                                SPOTIFY: spotifyLink,
                                                                                                                                                                                LIMELIGHT: limelightLink], socialClicks: [APPLEMUSIC: 0,
                                                                                                                                                                                                                          SOUNDCLOUD: 0,
                                                                                                                                                                                                                          SPOTIFY: 0,
                                                                                                                                                                                                                          LIMELIGHT: 0], radius: trackRadius, streamCount: streamCount, uploadDate: unixDate, likeCount: totalLikes, dislikeCount: totalDislikes, commentCount: commentCount, title: trackName, trackUrl: trackURL, trackId: Id ?? "None", latitude: trackLatitude, longitude: trackLongitude, city: city, state: state, country: country, trackSource: LIKEDTRACKS,audioItem: audioItem, avgCoverColor: UIColor.black, comments: [Comment](), likePercentage: likePercentage, fcmToken: "")
                        
                        
                        
                        tracks.append(track)
                        
                        print("\(source) Done For: \(trackId)")
                        
                        if trackIds.count == tracks.count {
                            print("Done Loading Total \(tracks.count) \(source)")
                            
                            User.cards[source] = tracks
                            addTracksToSource(trackArray: tracks, source: source)
                            
                            completion(tracks)
                        }
                        
                        
                        
                    }
                    
                    
                    
            }
            
            
        }
        
        
        
        
    }
    
    static func handleLogin(email: String, password: String, completion: @escaping (_ uid: String) -> Void) {
        
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                
                
                print(error?.localizedDescription ?? "ERROR: Firebase auth - SignInViewController/handleLogin")
                
                
            } else {
                
                guard let uid = user?.user.uid else {
                    print("ERROR: UID is null - SignInViewController/handleLogin")
                    return
                }
                
                
                print("System UID: \(uid)")
                // getUserInfo(uid)
                completion(uid)
                User.uid = uid
                
                
            }
        })
        
        
        
    }
    
    //SUBSCRIPTION FUNCTIONS
    static func checkIfRevenueCatSubscriber(uid: String, completion: @escaping (_ subscribed: Bool) -> Void){
        db.collection("RevenueCatSubscriptions").document(uid).getDocument() { (document, error) in
            if document?.exists ?? false {
                print("exists Document data: \(document?.data())")
                
                Purchases.shared.purchaserInfo { (purchaserInfo, error) in
                    // access latest purchaserInfo
                    purchaserInfo?.activeSubscriptions.count
                    let entitlement = purchaserInfo?.entitlements["pro"]
                    Subscription.uid = User.uid
                    
                    Subscription.entitlementId = entitlement?.identifier ?? ""
                    Subscription.isActive = entitlement?.isActive ?? false
                    Subscription.periodType = entitlement?.periodType
                    Subscription.originalPurchaseDate = Int(entitlement?.originalPurchaseDate.timeIntervalSince1970 ?? 0)
                    Subscription.latestPurchaseDate = Int(entitlement?.latestPurchaseDate.timeIntervalSince1970 ?? 0)
                    Subscription.expirationPurchaseDate = Int(entitlement?.expirationDate?.timeIntervalSince1970 ?? 0)
                    Subscription.willRenew = entitlement?.willRenew ?? false
                    Subscription.store = entitlement?.store
                    print("e count: \( purchaserInfo?.activeSubscriptions.count)")
                    print(entitlement?.identifier)
                    if entitlement?.identifier == "pro" {
                        Subscription.planType = PROARTIST
                        Subscription.tracksAvailable = PROTRACKCOUNT
                    }else if  entitlement?.identifier == "plus" {
                        Subscription.planType = PLUSARTIST
                        Subscription.tracksAvailable = PLUSTRACKCOUNT
                    }else {
                        Subscription.planType = BASICARTIST
                        Subscription.tracksAvailable = BASICTRACKCOUNT
                    }
                    
                    if Subscription.isActive == true {
                        User.isSubscribed = true
                    }
                    
                    System.getTrackIdsBySource(uid: uid, source: UPLOADEDTRACKS) { (trackIds) in
                        User.trackKeys[UPLOADEDTRACKS] = trackIds
                    }
                    
                    System.setRevenueCatSubscription(uid: uid)
                    completion(true)
                    
                    
                    
                }
                
                
                
            } else {
                print("Document does not exist")
                completion(false)
            }
        }
    }
    
    static func checkIfChargebeeSubscriber(email: String, completion: @escaping (_ message: String) -> Void){
        
        //set User Uid for further reference
        
        // User.uid = uid
        db.collection("subscriptions").whereField("email", isEqualTo: email).limit(to: 1).getDocuments { (snapshot, error) in
            
            for document in snapshot!.documents{
                let data = document.data()
                let subscriptionId = data["subscriptionId"] as? String ?? "None"
                // let city = data?["city"] as? String ?? "None"
                //  let country = data?["country"] as? String ?? "None"
                //  let profilePhoto = data?["photoUrl"] as? String ?? "None"
            }
            
        }
        
        
    }
    
    static var controller = AudioController.shared
    
    static func migrateUser(uid: String, completion: @escaping (_ message: Bool) -> Void){
        
        db.collection("all-tracks").whereField("uid", isEqualTo: uid ).getDocuments { (snapshot, error) in
            
            for document in snapshot!.documents{
                let data = document.data()
                
                
                print("migrated track: \(document.documentID)")
                
                db.collection("users").document(uid).collection(UPLOADEDTRACKS).addDocument(data:["trackId": document.documentID, "dateAdded": Date().timeIntervalSince1970])
                
                FirebaseManager.setTrackGeohash(uid: uid, trackId: document.documentID)
                User.trackKeys[UPLOADEDTRACKS]?.append(document.documentID)
                
                
            }
            
            
            completion(true)
            
        }
        
    }
    
    static func setRevenueCatSubscription(uid: String) {
        db.collection("RevenueCatSubscriptions").document(uid).setData(["uid": uid, "entitlementId": Subscription.entitlementId, "originalPurchaseDate": Subscription.originalPurchaseDate, "latestPurchaseDate": Subscription.latestPurchaseDate, "expirationPurchaseDate": Subscription.expirationPurchaseDate, "willRenew": Subscription.willRenew, "isActive": Subscription.isActive, "tracksAvailable": Subscription.tracksAvailable, "uploadedTrackKeys": Subscription.uploadedTrackKeys]){ err in
            if let err = err {
                print("Error creating revenue cat subscription: \(err)")
                
            } else {
                print("Revenue cat subscription created successfully")
                
                db.collection("users").document(User.uid).setData([
                    "isArtist": true
                    
                ], merge: true)
                
                
            }
            
        }
    }
    
    
    //USER FUNCTIONS
    
    static func getUserInfo(uid: String, completion: @escaping (_ message: String) -> Void){
        
        //set User Uid for further reference
        print("UID: \(uid)")
        // User.uid = uid
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                
                let data = document.data()
                let subscriptionId = data?["subscriptionId"] as? String ?? "None"
                let city = data?["city"] as? String ?? "None"
                let state = data?["state"] as? String ?? "None"
                let country = data?["country"] as? String ?? "None"
                let profilePhoto = data?["photoUrl"] as? String ?? "None"
                let username = data?["username"] as? String ?? ""
                let bio = data?["bio"] as? String ?? ""
                //let coverPhoto = data?["coverPhotoUrl"] as? String ?? "" NOT USED YET
                let name = data?["name"] as? String ?? ""
                let spotify = data?["spotify"] as? String ?? ""
                let appleMusic = data?["applemusic"] as? String ?? ""
                let soundcloud = data?["soundcloud"] as? String ?? ""
                let twitter = data?["twitter"] as? String ?? ""
                let instagram = data?["instagram"] as? String ?? ""
                let spotifyClicks = data?["spotifyClicks"] as? Int ?? 0
                let soundcloudClicks = data?["soundcloudClicks"] as? Int ?? 0
                let applemusicClicks = data?["applemusicClicks"] as? Int ?? 0
                let twitterClicks = data?["twitterClicks"] as? Int ?? 0
                let instagramClicks = data?["instagramClicks"] as? Int ?? 0
                let listenerPoints = data?["listenerPoints"] as? Int ?? 0
                let profileImpressionCount = data?["profileImpressionCount"] as? Int ?? 0
                //not sure if below will work
                let followers = data?["followers"] as? [String]
                let following = data?["following"] as? [String]
                let likedTracks = data?["likedTracks"] as? [String]
                let dislikedTracks = data?["dislikedTracks"] as? [String]
                let library = data?["library"] as? [String]
                let isArtist = data?["isArtist"] as? Bool
                
                User.location["city"] = city
                User.location["state"] = state
                User.location["country"] = country
                User.imageUrl = profilePhoto
                User.username = username
                User.bio = bio
                User.name = name
                User.listenerPoints = listenerPoints
                User.socials["spotify"] = spotify
                User.socials["applemusic"] = appleMusic
                User.socials["soundcloud"] = soundcloud
                User.socials["twitter"] = twitter
                User.socials["instgram"] = instagram
                //add limelight social link
                User.socialClicks["spotify"] = spotifyClicks
                User.socialClicks["applemusic"] = applemusicClicks
                User.socialClicks["soundcloud"] = soundcloudClicks
                User.socialClicks["twitter"] = twitterClicks
                User.socialClicks["instagram"] = instagramClicks
                //add limelight clicks
                User.profileImpressionCount = profileImpressionCount
                //not sure if below will work
                // User.followers = followers ?? [String]()
                // User.following = following ?? [String]()
                User.trackKeys[LIKEDTRACKS] = likedTracks ?? [String]()
                User.trackKeys[DISLIKEDTRACKS] = dislikedTracks ?? [String]()
                User.trackKeys[LIBRARYTRACKS] = library ?? [String]()
                User.subscriptionId = subscriptionId
                User.isArtist = isArtist ?? false
                completion("finished")
                
                
                
            }
        }
        
        
    }
    
    static func formatNumber(_ n: Int) -> String {
        
        let num = abs(Double(n))
        let sign = (n < 0) ? "-" : ""
        
        switch num {
            
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)B"
            
        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)M"
            
        case 10_000...:
            var formatted = num / 1_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)K"
            
        case 0...:
            return "\(n)"
            
        default:
            return "\(sign)\(n)"
            
        }
        
    }
}
