//
//  AudioController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-11-15.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import Foundation
import SwiftAudio
import Firebase
import FirebaseFirestore
import LNPopupController
import GeoFire
import MediaPlayer

class AudioController {
    
    static let shared = AudioController()
    let player: QueuedAudioPlayer
    let audioSessionController = AudioSessionController.shared
    var currentSource = DISCOVERTRACKS
    var currentIndex = 0
    var isDiscoverScreen = false
    var db = Firestore.firestore()
    var delegate: cardControl?
    lazy var lastStreamedTrack = ""
    var currentlyPlaying: Track?
    
    
    func loadTracks(source: String){
          
          if let sources = User.sources[source] {
              print("\(sources.count) \(source) Source Added to Audio Player")
              player.automaticallyWaitsToMinimizeStalling = false
              player.bufferDuration = 0.1
            
            if source == DISCOVERTRACKS {
                try? player.add(items: sources, playWhenReady: false)
                try? audioSessionController.activateSession()
            }else {
                try? player.add(items: sources, playWhenReady: true)
                try? audioSessionController.activateSession()
            }
             
          }
          
       
          
      }
      
    
    func addTracksToSource(trackArray: [Track], source: String){
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
    
    func getCurrentlyPlayingTrackFromSource(source: String) -> (Track, Int) {
        var i = 0
        var found = false
        var index = -1
        var trackCard = Track(artistUsername: "", artistUid: "", genre: "", albumTitle: "", description: "", imageUrl: "", socials: [APPLEMUSIC: "",
              SOUNDCLOUD: "",
              SPOTIFY: "",
              LIMELIGHT: ""], socialClicks: [APPLEMUSIC: 0,
              SOUNDCLOUD: 0,
              SPOTIFY: 0,
              LIMELIGHT: 0], radius: 0, streamCount: 0, uploadDate: 0, likeCount: 0, dislikeCount: 0, commentCount: 0, title: "Welcome", trackUrl: "", trackId: "", latitude: 0.0, longitude: 0.0, city: "", state: "", country: "", trackSource: "",audioItem: DefaultAudioItem(audioUrl: "String(trackURL)", artist: "String(username)", title: "String(trackName)", albumTitle:" String(albumName)", sourceType: .stream ,artwork: #imageLiteral(resourceName: "itunes_13_icon__png__ico__icns__by_loinik_d8wqjzr-pre")), avgCoverColor: UIColor.black, comments: [Comment](), likePercentage: 0.0, fcmToken: "")
              
        
        while i < User.cards[source]?.count ?? 0 && found != true {
            let title = self.player.currentItem?.getTitle()
            
            if User.cards[source]?[i].title == title {
                found = true
               
                if let card = User.cards[source]?[i] {
                  
                   trackCard = card
                   index = i
                }
              
                
            }
            i = i + 1
            
        }
        
        return (trackCard, index)
    }
    
    func getCurrentlyPlayingTrack() -> (Track, String, Int) {
        let title = player.currentItem?.getTitle()
        var i = 0
        let sources = [DISCOVERTRACKS, LIBRARYTRACKS,LIKEDTRACKS,DISLIKEDTRACKS, UPLOADEDTRACKS]
        var found = false
        var trackSource = ""
        var trackCard = Track(artistUsername: "", artistUid: "", genre: "", albumTitle: "", description: "", imageUrl: "", socials: [APPLEMUSIC: "",
        SOUNDCLOUD: "",
        SPOTIFY: "",
        LIMELIGHT: ""], socialClicks: [APPLEMUSIC: 0,
        SOUNDCLOUD: 0,
        SPOTIFY: 0,
        LIMELIGHT: 0], radius: 0, streamCount: 0, uploadDate: 0, likeCount: 0, dislikeCount: 0, commentCount: 0, title: "Welcome", trackUrl: "", trackId: "", latitude: 0.0, longitude: 0.0, city: "", state: "", country: "", trackSource: "",audioItem: DefaultAudioItem(audioUrl: "String(trackURL)", artist: "String(username)", title: "String(trackName)", albumTitle:" String(albumName)", sourceType: .stream ,artwork: #imageLiteral(resourceName: "itunes_13_icon__png__ico__icns__by_loinik_d8wqjzr-pre")), avgCoverColor: UIColor.black, comments: [Comment](), likePercentage: 0.0, fcmToken: "")
        
        for source in sources {
            while i < User.cards[source]?.count ?? 0 && found != true {
                if User.cards[source]?[i].title == title {
                    found = true
                   
                    if let card = User.cards[source]?[i] {
                        trackSource = source
                        trackCard = card
                        return (card,source, i)
                    }
                  
                    
                }
                i = i + 1
                
            }
            i = 0
        }
        
        
      return (trackCard,trackSource,i)
    }
    
    func getTrackIndexInSourceByTitle(source: String, title: String) -> Int {
        
        var i = 0
        var found = false

        while i < User.cards[source]?.count ?? 0 && found != true {
            if User.cards[source]?[i].title == title {
                found = true
                return i
               
               
              
                
            }
            i = i + 1
            
        }
        return -1
    }
    
    func getTrackIndexInSource(source: String, trackId: String) -> Int {
        
        var i = 0
        var found = false

        while i < User.cards[source]?.count ?? 0 && found != true {
            if User.cards[source]?[i].trackId == trackId {
                found = true
                return i
               
               
              
                
            }
            i = i + 1
            
        }
        return -1
    }
    
  
    var foundTrack = false
    var i = 0
    
    func preloadTrack(index: Int, source: String){
        
        if User.sources[source]?.indices.contains(index) ?? false{
        
        if let track = User.sources[source]?[index] {
        
        if player.items.indices.contains(index) {
            
            print("Attempting to preload next track")
            
            let concurrentQueue = DispatchQueue(label: "trackPreload", attributes: .concurrent)
            concurrentQueue.sync {
               player.preload(item: track)
                          print("Next track has been preloaded")
            }
        }
        else{
            print("ERROR: Unable to preload track")
        }
        }
        }else{
            print("ERROR: Unable to preload track")
        }
    }
        
    
    
    
    
    var profileUid = ""
    
    func playTrack2(track: Track, source: String) {
        foundTrack = false
        i = 0
        let sources = User.sources[source]
        
        if currentSource != source {
            
          
            
            
            player.stop()
            player.removeUpcomingItems()
            loadTracks(source: source)
            //addTracksToSource(trackArray: User.cards[source] ?? [], source: source)
            print("Source Change: \(currentSource) -> \(source)")
            currentSource = source
            playTrack2(track: track, source: source)
            
            
        }else {
            while i < player.items.count || foundTrack != true{
                let trackTitle = player.items[i].getTitle()
                
                if trackTitle == track.title {
                    foundTrack = true
                }
                i = i + 1
            }
            
            if foundTrack {
                //print("searched index: \(player.items[i].getTitle())")
                try? player.jumpToItem(atIndex: i)
                
              
                currentIndex = i
                currentlyPlaying = track
                print("Playing: \(String(describing: track.title)) : \(track.likePercentage)%")
                               if !isDiscoverScreen && System.showingMP != true{
                                   showMusicPlayer(track: track, tabBarController: System.tabBarController)
                               }
                
                if lastStreamedTrack != track.trackId {
                    
                    DispatchQueue.global(qos: .background).async {
                        self.addStreamToDb(trackId: track.trackId, artistId: track.artistUid, streamedBy: User.uid, source: source, date: Int(NSDate().timeIntervalSince1970))
                                           
                        self.incrementTrackStreamCount(trackId: track.trackId)
                        self.incrementListenerPoints(userId: User.uid, incrementValue: 1)
                        self.lastStreamedTrack = track.trackId
                    }
                   
                }

            }else{
                print("playTrack2 didnt find track")
            }
        }
        
    }
    
    
    
    func playTrack(index: Int, source: String) {
           
           foundTrack = false
             i = 0
           let sources = User.sources[source]
        currentIndex = index 
    
        
        if currentSource != source {
            
          
            
            
            player.stop()
            player.removeUpcomingItems()
            loadTracks(source: source)
            //addTracksToSource(trackArray: User.cards[source] ?? [], source: source)
            print("Source Change: \(currentSource) -> \(source)")
            currentSource = source
            playTrack(index: index, source: source)
            
            
        }
        /*else if currentSource == UPLOADEDTRACKS {
            if currentlyPlaying?.artistUid != profileUid{

                player.stop()
                player.removeUpcomingItems()
                loadTracks(source: source)
                //addTracksToSource(trackArray: User.cards[source] ?? [], source: source)
               
                
              //  playTrack(index: index, source: source)
                
            }
        }*/ else {

           if player.items.indices.contains(index) {
               
            let trackTitle = player.items[index].getTitle()
            if User.cards[source]?.indices.contains(index) ?? false{
            if let card = User.cards[source]?[index] {
               
               if card.title == trackTitle {
                   
                   try? player.jumpToItem(atIndex: index)
                   //player.play()
                   currentIndex = index
                   currentlyPlaying = card
                
                print("line 257: \(card.title) - \(trackTitle)")
                   foundTrack = true
                
               }else{
                   
                   i = 0
                   
                   while i < sources?.count ?? 0 && foundTrack != true{
                       
                       if card.title == sources?[i].getTitle() {
                           try? player.jumpToItem(atIndex: i)
                           //player.play()
                            currentlyPlaying = card
                           foundTrack = true
                           currentIndex = i
                       }
                       i = i + 1
                   }
                    
               }
                
               if foundTrack == false{
                   print("ERROR: Track not found")
                  // addTracksToSource(trackArray: User.cards[source]!, source: source)
                   
               }else{
                   
                if player.playerState.rawValue != "playing" {
                    
                }
                   
                   print("Playing: \(String(describing: trackTitle)) : \(card.likePercentage)%")
                if !isDiscoverScreen && System.showingMP != true{
                    showMusicPlayer(track: card, tabBarController: System.tabBarController)
                }
                currentSource = source
               
                
                   //add stream function here
                if lastStreamedTrack != card.trackId {
                    
                    DispatchQueue.global(qos: .background).async {
                        self.addStreamToDb(trackId: card.trackId, artistId: card.artistUid, streamedBy: User.uid, source: source, date: Int(NSDate().timeIntervalSince1970))
                                           
                                           
                        self.incrementListenerPoints(userId: User.uid, incrementValue: 1)
                        self.incrementTrackStreamCount(trackId: card.trackId)
                        self.lastStreamedTrack = card.trackId
                    }
                   
                }
                
                currentlyPlaying = card
               
                
                System.imageDownloader.loadImage(with: URL(string: card.imageUrl), progress: nil) {
                                           (image, error, cacheType, imageURL, progress, data) in
                    
                   
                    let artwork = MPMediaItemArtwork.init(boundsSize: image?.size ?? CGSize(width: 50, height: 50), requestHandler: { (size) -> UIImage in
                        return (image ?? DEFAULTCOVERIMAGE!)
                    })
                    
                   
                            
                }
               
                //profileUid = card.artistUid
                
               }
                }
               
           }
            
        }
        }
    
       }
    
  
    
    
    func showMusicPlayer(track: Track, tabBarController: UITabBarController){
        print("showing music player for: \(track.title)")
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let popupContentController = storyboard.instantiateViewController(withIdentifier: "MusicPlayerController") as! MusicPlayerViewController
            //this fixed multiple listeners 
            self.player.event.stateChange.removeListener(tabBarController.popupContentView)
            self.player.event.fail.removeListener(tabBarController.popupContentView)
           self.player.event.secondElapse.removeListener(tabBarController.popupContentView)
                    
                   self.player.event.updateDuration.removeListener(tabBarController.popupContentView)
            self.player.event.seek.removeListener(tabBarController.popupContentView)
            self.player.event.fail.removeListener(tabBarController.popupContentView)
                  
          
            self.player.event.updateDuration.addListener(tabBarController.popupContentView, popupContentController.handleAudioPlayerUpdateDuration)
            self.player.event.seek.addListener(tabBarController.popupContentView, popupContentController.handleAudioPlayerDidSeek)
          
            self.player.event.secondElapse.addListener(tabBarController.popupContentView, popupContentController.handleAudioPlayerSecondElapsed)
                  
                   
           self.player.event.stateChange.addListener(tabBarController.popupContentView, popupContentController.handleAudioPlayerStateChange)
            self.player.event.fail.addListener(tabBarController.popupContentView, popupContentController.handlePlayerFailure(data:))
           
            popupContentController.songTitle = track.title//titles[(indexPath as NSIndexPath).row]
            popupContentController.albumTitle = track.artistUsername//subtitles[(indexPath as NSIndexPath).row]
            
            System.imageDownloader.loadImage(with: URL(string: track.imageUrl), progress: nil) {
                             (image, error, cacheType, imageURL, progress, data) in
               let defaultImage = DEFAULTCOVERIMAGE
               let resizedDefaultImage = defaultImage?.resized(toWidth: 50)
               let roundedDefaultImage = resizedDefaultImage?.withRoundedCorners(radius: 5)
               let resizedImage = image?.resized(toWidth: 50)
               let roundedImage = resizedImage?.withRoundedCorners(radius: 5)
                
                popupContentController.albumArt = roundedImage ?? DEFAULTCOVERIMAGE!
                       
            // body:"\(currentCard.title) by \(currentCard.artistUsername)"
              
                         }
            //images[(indexPath as NSIndexPath).row]
            popupContentController.track = track
            popupContentController.coverArtURL = track.imageUrl
            
            
          
        /*    if self.player.playerState.rawValue != "playing" {
                popupContentController.popupItem.leftBarButtonItems?[0].image = UIImage(named: "play-mini")
                       }else{
               
                   popupContentController.popupItem.leftBarButtonItems?[0].image = UIImage(named: "pause-mini")
                       }*/
            
        
        popupContentController.popupItem.accessibilityHint = NSLocalizedString("Double Tap to Expand the Mini Player", comment: "")
            tabBarController.popupContentView.popupCloseButton.accessibilityLabel = NSLocalizedString("Dismiss Now Playing Screen", comment: "")
        
        #if targetEnvironment(macCatalyst)
       // tabBarController?.popupBar.inheritsVisualStyleFromDockingView = true
        #endif
            
           
        
         
         //   tabBarController.popupBar.tintColor = UIColor(hexString: "299312")
            tabBarController.popupBar.barStyle = .prominent
            tabBarController.popupBar.inheritsVisualStyleFromDockingView = false
            tabBarController.popupBar.progressViewStyle = .top
            tabBarController.popupBar.marqueeScrollEnabled = true
            tabBarController.popupInteractionStyle = .drag
            tabBarController.popupBar.isTranslucent = true
         // tabBarController.popupBar.backgroundColor = .red
             tabBarController.presentPopupBar(withContentViewController: popupContentController, animated: true, completion: nil)
        if #available(iOS 13.0, *) {
            tabBarController.popupBar.tintColor = LIMELIGHTPURPLE
            //tabBarController.popupBar.backgroundColor = .red
            tabBarController.popupBar.backgroundStyle = .dark
            
        } else {
            tabBarController.popupBar.backgroundStyle = .extraLight
            
            tabBarController.popupBar.tintColor = UIColor(white: 38.0 / 255.0, alpha: 1.0)
        }
        
        }
      
    }
    
    
    func addStreamToDb(trackId: String, artistId: String, streamedBy: String, source: String, date: Int){
        
        let document = db.collection("Streams").document()
        
        
        document.setData([
                 "trackId": trackId,
                 "artistUid":artistId,
                 "streamedByUid": streamedBy,
                 "source": source,
                 "city": User.location[CITY] ?? "N/A",
                 "state": User.location[STATE] ?? "N/A",
                 "country": User.location[COUNTRY] ?? "N/A",
                 "date": date
               ]
                       
             ) { err in
                 if let err = err {
                     print("Error writing stream document: \(err)")
                 } else {
                     print("Stream successfully written")
                    let geofireRef = Database.database().reference().child("GeofireStreams")
                    let geoFire = GeoFire(firebaseRef: geofireRef)
                    guard let latitude = User.location[LATITUDE] as? CLLocationDegrees else {
                        print("cancelled geofirestream add, no lat")
                        return
                    }
                    
                    guard let longitude = User.location[LONGITUDE]  as? CLLocationDegrees else {
                        print("cancelled geofirestream add, no long")
                        return
                    }
                    geoFire.setLocation(CLLocation(latitude: latitude , longitude:longitude), forKey: document.documentID) { (error) in
                        if (error != nil) {
                            print("An error occured: \(error)")
                        } else {
                            print("Saved location successfully for stream")
                        }
                    }
                   
                 }
                           
             }

    }
    
    func getDiscoverTrackIndex(trackId: String) -> Int {
        var i = 0
        var index = -1
        while i < User.cards[DISCOVERTRACKS]?.count ?? 0 {
            if User.cards[DISCOVERTRACKS]?[i].trackId == trackId {
                index = i
            }
            i = i + 1
        }
        
        print("Discover Index: \(index)")
        
        return index
    }
    
    func incrementSourceCount(trackId: String, source: String){
       

        db.collection("all-tracks").document(trackId).setData([
            "\(source)AddCount": FieldValue.increment(Int64(1))
            
        ], merge: true)
        { err in
        if let err = err {
            print("Error writing source increment document: \(err)")
        } else {
            print("source increment successfully written")
        
             
            }
        }
    }
    
    func incrementCommentCount(trackId: String){
          
        let discoverTrackIndex = getDiscoverTrackIndex(trackId: trackId)
        if discoverTrackIndex != -1 {
                       User.cards[DISCOVERTRACKS]?[discoverTrackIndex].commentCount += 1
                   }
        

           db.collection("all-tracks").document(trackId).setData([
               "commentCount": FieldValue.increment(Int64(1))
               
           ], merge: true)
           { err in
           if let err = err {
               print("Error writing comment count increment document: \(err)")
           } else {
               print("comment count increment successfully written")
           
                
               }
           }
       }
    
    
    func decrementCommentCount(trackId: String){
      let discoverTrackIndex = getDiscoverTrackIndex(trackId: trackId)
        if discoverTrackIndex != -1 {
                       User.cards[DISCOVERTRACKS]?[discoverTrackIndex].commentCount -= 1
                   }

        db.collection("all-tracks").document(trackId).setData([
            "commentCount": FieldValue.increment(Int64(-1))
            
        ], merge: true)
        { err in
        if let err = err {
            print("Error writing comment count increment document: \(err)")
        } else {
            print("comment count increment successfully written")
            
           
            }
        }
    }
    
   
       
    
    func incrementListenerPoints(userId: String, incrementValue: Int){
    
        db.collection("users").document(userId).setData([
            "listenerPoints": FieldValue.increment(Int64(incrementValue))
            
        ], merge: true)
        { err in
        if let err = err {
            print("Error writing listener point increment document: \(err)")
        } else {
            print("listener point increment successfully written")
            }
        }
    }
    
    
    
    func incrementTrackStreamCount(trackId: String){
        db.collection("all-tracks").document(trackId).setData([
            "streamCount": FieldValue.increment(Int64(1))
        ], merge: true)
        { err in
        if let err = err {
            print("Error track stream increment increment document: \(err)")
        } else {
            print("track stream increment successfully written")
            Analytics.logEvent(TRACKSTREAMEVENT, parameters: [
                                "username": User.username,
                                "trackId":trackId,
                               
                                "location":  "\(User.location[CITY] ?? "N/A"), \(User.location[STATE] ?? "N/A"), \(User.location[COUNTRY] ?? "N/A")"
                               
                                ])
            }
        }
    }
    
    init() {
        print("AudioController initialized")
        let controller = RemoteCommandController()
        player = QueuedAudioPlayer(remoteCommandController: controller)
        player.remoteCommands = [
            .stop,
            .play,
            .pause,
            .togglePlayPause,
            .next,
            .previous,
            .changePlaybackPosition,
            
        ]
        try? audioSessionController.set(category: .playback)
        
        
       // try? player.add(items: sources2, playWhenReady: true)
    }
    
    func addTrackToBlacklist(trackId: String){
         if !(User.trackKeys[BLACKLISTTRACKS]?.contains(trackId) ?? true){
            print("\(trackId) not in blacklist")
            User.trackKeys[BLACKLISTTRACKS]?.append(trackId)
            db.collection("users").document(User.uid).collection("blacklistTracks").addDocument(data:["trackId": trackId, "dateAdded": Date().timeIntervalSince1970]){ err in
                               if let err = err {
                                   print("Error writing document: \(err)")
                                 
                               } else {
                                   print("Track added to blacklist successfully")
                                 
                            
                                   }
            
                }
         }else{
              print("\(trackId) already in blacklist")
        }
        
        
    }
    
    
       func addTrackToUserCollectionCompletion(trackId: String, source: String, track: Track?, completion: @escaping (_ action: String) -> Void){
        
        if source == LIKEDTRACKS {
            
            
            
           incrementSourceCount(trackId: trackId, source: source)
            
            if User.name != ""{
        
                System.push.sendPushNotification(to: FirebaseManager.fcmTokenDict[track?.artistUid ?? BIZLALUID] ?? BIZLALUID, title: "",body:  "\(User.name) (\(User.username)) liked \(track?.title ?? "your track.")")
                
            }
        
            
        else{
                System.push.sendPushNotification(to: FirebaseManager.fcmTokenDict[track?.artistUid ?? BIZLALUID] ?? BIZLALUID, title: "",body:  "\(User.username) liked \(track?.title ?? "your track").")
                       }
        }
        
        if source == DISLIKEDTRACKS {
             incrementSourceCount(trackId: trackId, source: source)
           
        }
        
        
        if source == LIBRARYTRACKS {
            
            incrementSourceCount(trackId: trackId, source: source)
            
            if User.name != ""{
        
                System.push.sendPushNotification(to: FirebaseManager.fcmTokenDict[track?.artistUid ?? BIZLALUID] ?? BIZLALUID, title: "",body:  "\(User.name) (\(User.username)) added \(track?.title ?? "your track") to their library.")
                
            }
        
            
        else{
                System.push.sendPushNotification(to:FirebaseManager.fcmTokenDict[track?.artistUid ?? BIZLALUID] ?? BIZLALUID, title: "",body:  "\(User.username) added \(track?.title ?? "your track") to their library.")
                       }
        }

       
 
        if source != LIBRARYTRACKS && source != UPLOADEDTRACKS {
             addTrackToBlacklist(trackId: trackId)
        }
          
           
           if !(User.trackKeys[source]?.contains(trackId) ?? true){
            guard let track = track else {
                return
            }
              
             
               User.trackKeys[source]?.insert(trackId, at: 0)
               User.sources[source]?.insert((track.audioItem)!, at: 0)
            
            
               User.cards[source]?.insert(track, at: 0)
           }
       
           
           let db = Firestore.firestore()
           var exists = false
           var trackDocument = ""
           
           
           
           db.collection("users").document(User.uid).collection(source).whereField("trackId", isEqualTo: trackId).getDocuments(){ (querySnapshot, err) in
               if let err = err {
                   print("Error getting documents: \(err)")
               } else {
                   for document in querySnapshot!.documents {
                       _ = document.data()
                       exists = true
                       trackDocument = document.documentID
                   }
                   
                   //exists = true
                   
                   
                   print("Found document")
                   
               }
               
               if exists != true{
               
                   db.collection("users").document(User.uid).collection(source).addDocument(data:["trackId": trackId, "dateAdded": Date().timeIntervalSince1970]){ err in
                       if let err = err {
                           print("Error writing document: \(err)")
                         
                       } else {
                           print("\(track?.title) added to \(source) successfully")
                          // self.addTrackToBlacklist(trackId: trackId)
                        completion("added")
                         
                    
                           }
    
                       }
                   }
        
               else {
                   
                   if let index = User.trackKeys[source]?.firstIndex(of: trackId){
                          User.trackKeys[source]?.remove(at: index)
                       
                       let cardIndex = self.getTrackIndexInSource(source: source, trackId: trackId)
                       
                       if cardIndex != -1 {
                            User.cards[source]?.remove(at: cardIndex)
                           
                           NotificationCenter
                               .default
                               .post(name: NSNotification.Name(rawValue: "dataDeleted"), object: self)
                             }
                       }
                           
      
               print(trackDocument)
                   
                   db.collection("users").document(User.uid).collection(source).document(trackDocument).delete() { err in
                       if let err = err {
                           print("Error removing document: \(err)")
                        
                       } else {
                           print("Track successfully removed from \(source)")
                            completion("removed")
        
                           }
                           
                           
                       }
                   }
                   
               }
               
           }
       
    
    
    
    func addTrackToUserCollection(trackId: String, source: String, track: Track?){
        Analytics.logEvent(TRACKACTIONEVENT, parameters: [
        "username": User.username,
        "trackId":trackId,
        "source": source,
        "location":  "\(User.location[CITY] ?? "N/A"), \(User.location[STATE] ?? "N/A"), \(User.location[COUNTRY] ?? "N/A")"
       
        ])
        if source == LIKEDTRACKS {
            incrementSourceCount(trackId: trackId, source: source)
           
            if User.name != ""{
        
                System.push.sendPushNotification(to: FirebaseManager.fcmTokenDict[track?.artistUid ?? BIZLALUID] ?? BIZLALUID, title: "",body:  "\(User.name) (\(User.username)) liked \(track?.title ?? "your track").")
                
            }
        
            
        else{
                System.push.sendPushNotification(to: FirebaseManager.fcmTokenDict[track?.artistUid ?? BIZLALUID] ?? BIZLALUID, title: "",body:  "\(User.username) liked \(track?.title ?? "your track").")
                       }
        }
        
        if source == DISLIKEDTRACKS {
            incrementSourceCount(trackId: trackId, source: source)
           
        }
        
        if source == LIBRARYTRACKS {
            incrementSourceCount(trackId: trackId, source: source)
            if User.name != ""{
        
                System.push.sendPushNotification(to: FirebaseManager.fcmTokenDict[track?.artistUid ?? BIZLALUID] ?? BIZLALUID, title: "",body:  "\(User.name) (\(User.username)) added \(track?.title ?? "your track") to their library.")
                
            }
        
            
        else{
             System.push.sendPushNotification(to: FirebaseManager.fcmTokenDict[track?.artistUid ?? BIZLALUID] ?? BIZLALUID, title: "",body:  "\(User.username) added \(track?.title ?? "your track") to their library.")
                       }
        }

      if source != LIBRARYTRACKS {
             addTrackToBlacklist(trackId: trackId)
        }
        
        if !(User.trackKeys[source]?.contains(trackId) ?? true){
            User.cards[source]?.insert(track!, at: 0)
            User.trackKeys[source]?.insert(trackId, at: 0)
            User.sources[source]?.insert((track?.audioItem)!, at: 0)
        }
     
        let db = Firestore.firestore()
        var exists = false
        var trackDocument = ""
   
        db.collection("users").document(User.uid).collection(source).whereField("trackId", isEqualTo: trackId).getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    _ = document.data()
                    exists = true
                    trackDocument = document.documentID
                }
             print("Found document")
                
            }
            
            if exists != true{
            
                db.collection("users").document(User.uid).collection(source).addDocument(data:["trackId": trackId, "dateAdded": Date().timeIntervalSince1970]){ err in
                    if let err = err {
                        print("Error writing document: \(err)")
                      
                    } else {
                        print("\(track?.title) added to \(source) successfully")
             
                        }
 
                    }
                }
     
            else {
                
                if let index = User.trackKeys[source]?.firstIndex(of: trackId){
                       User.trackKeys[source]?.remove(at: index)
                    
                    let cardIndex = self.getTrackIndexInSource(source: source, trackId: trackId)
                    
                    if cardIndex != -1 {
                         User.cards[source]?.remove(at: cardIndex)
                        
                        NotificationCenter
                            .default
                            .post(name: NSNotification.Name(rawValue: "dataDeleted"), object: self)
                          }
                    }
                        
   
            print(trackDocument)
                
                db.collection("users").document(User.uid).collection(source).document(trackDocument).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                     
                    } else {
                        print("Track successfully removed from \(source)")
                        
     
                        }
                        
                        
                    }
                }
                
            }
            
        }
    
}
    
    

