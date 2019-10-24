//
//  ViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-10-18.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import Shuffle_iOS
import PopBounceButton
import FirebaseDatabase
import GeoFire
import FirebaseFirestore

// swiftlint:disable vertical_whitespace line_length

internal class CardV2 {
    
    var artistName: String!
    var trackName: String!
    var genre: String!
    var coverArtLink: String!
    var backgroundLink: String!
    var albumName: String!
    var trackLink: String!
    var trackSource: String!
    var radius: Int!
    var latitude: Double!
    var longitude: Double!
    var city: String!
    var state: String!
    var country: String!
    let uid: String!
    let distance: Int!
    let id: String!
    let date: String!
   
    let streamCount: Int!
    let likedBy: [String: Any]
    let dislikedBy: [String: Any]
    var soundcloudLink: String!
    var spotifyLink: String!
    var itunesLink: String!
    let trackId: String!
    let totalLikes: Int!
    let totalDislikes: Int!
    
    
    init(artistName: String, trackName: String, genre: String, coverArtLink: String, backgroundLink: String, albumName: String, trackLink: String, trackSource: String, radius: Int, latitude: Double, longitude: Double, city: String, state: String, country: String, uid: String, distance: Int, id: String, date: String, streamCount: Int, likedBy:[String: Any], dislikedBy: [String: Any], soundcloudLink: String, spotifyLink: String, itunesLink: String, trackId: String, totalLikes: Int, totalDislikes: Int) {
        
        self.artistName = artistName
        self.trackName = trackName
        self.genre = genre
        self.coverArtLink = coverArtLink
        self.backgroundLink = backgroundLink
        self.albumName = albumName
        self.trackLink = trackLink
        self.trackSource = trackSource
        self.radius = radius
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.state = state
        self.country = country
        self.uid = uid
        self.distance = distance
        self.id = id
        self.date = date
      
        self.streamCount = streamCount
        self.likedBy = likedBy
        self.dislikedBy = dislikedBy
        self.soundcloudLink = soundcloudLink
        self.spotifyLink = spotifyLink
        self.itunesLink = itunesLink
        self.trackId = trackId
        self.totalLikes = totalLikes
        self.totalDislikes = totalDislikes
        
        
        
    }
    
    
    
 
     
}


class ViewController: UIViewController, ButtonStackViewDelegate, SwipeCardStackDataSource, SwipeCardStackDelegate  {
    
    
    var cards = [CardV2]()
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
               return SampleCard(model: cardModels[index])
           }
           
           func numberOfCards(in cardStack: SwipeCardStack) -> Int {
               return cardModels.count
           }
           
           func didSwipeAllCards(_ cardStack: SwipeCardStack) {
               print("Swiped all cards!")
           }
           
           func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
               print("Undo \(direction) swipe on \(cardModels[index].name)")
           }
           
           func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
               print("Swiped \(direction) on \(cardModels[index].name)")
           }
           
           func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
               print("Card tapped")
           }
           
           func didTapButton(button: TinderButton) {
               switch button.tag {
               case 1:
                   cardStack.undoLastSwipe(animated: true)
               case 2:
                   cardStack.swipe(.left, animated: true)
               case 3:
                   cardStack.swipe(.up, animated: true)
               case 4:
                   cardStack.swipe(.right, animated: true)
               default:
                   break
               }
           }
    private let cardStack = SwipeCardStack()
    private let buttonStackView = ButtonStackView()
    
    private var cardModels = [
        SampleCardModel(name: "Michelle",
                        age: 26,
                        occupation: "Graphic Designer",
                        image: UIImage(named: "michelle")),
        SampleCardModel(name: "Joshua",
                        age: 27,
                        occupation: "Business Services Sales Representative",
                        image: UIImage(named: "joshua")),
        SampleCardModel(name: "Daiane",
                        age: 23,
                        occupation: "Graduate Student",
                        image: UIImage(named: "daiane")),
        SampleCardModel(name: "Julian",
                        age: 25,
                        occupation: "Model/Photographer",
                        image: UIImage(named: "julian")),
        SampleCardModel(name: "Andrew",
                        age: 26,
                        occupation: nil,
                        image: UIImage(named: "andrew")),
        SampleCardModel(name: "Bailey",
                        age: 25,
                        occupation: "Software Engineer",
                        image: UIImage(named: "bailey")),
        SampleCardModel(name: "Rachel",
                        age: 27,
                        occupation: "Interior Designer",
                        image: UIImage(named: "rachel"))
    ]
    
    func getFirestoreTracks(){
         
        _ = UserDefaults.standard
         

      //   startAnimating(size, message: "Finding Music Near \(UserInfo.city), \(UserInfo.state)", type: NVActivityIndicatorType.circleStrokeSpin, fadeInAnimation: nil)
         
         _ = 0
        
       
        
         self.cards.removeAll()
        
        
       
         
       //  UserInfo.currentIndex = 0
         
         let db = Firestore.firestore()
         
         db.collection("all-tracks").getDocuments() { (querySnapshot, err) in
             
             
           
        
             if let err = err {
                 print("Error getting documents: \(err)")
             } else {
                 for document in querySnapshot!.documents {
                   
                     let data = document.data()
                 
                     
                     _ = data["artist"] as? String ?? "None"
                     _ = data["producer"] as? String ?? "None"
                     let username = data["username"] as? String ?? "None"
                     let trackName = data["title"] as? String ?? "None"
                     _ = data["description"] as? String ?? "None"
                     let genre = data["genre"] as? String ?? "None"
                     let coverURL = data["imgUrl"] as? String ?? "None"
                     let backgroundURL = data["username"] as? String ?? "None"
                     let albumName = data["album_title"] as? String ?? "None"
                     let trackURL = data["trackUrl"] as? String ?? "http://www.noiseaddicts.com/samples_1w72b820/2514.mp3"
                     let radius = data["radius"] as? String ?? "100"
                     let latitude = data["latitude"] as? String ?? "-33.918861"
                    let longitude = data["longitude"] as? String ?? "18.423300"
                     let city = data["city"] as? String ?? "None"
                     let state = data["state"] as? String ?? "None"
                     let country = data["country"] as? String ?? "None"
                     let uid = data["uid"] as? String ?? "None"
                     let id = document.documentID
                     let unixDate = data["time"] as? Int ?? 1561696540741
                    let likedBy = data["likedBy"] as? [String: Any] ?? ["false":"false"]
                     let dislikedBy = data["dislikedBy"] as? [String: Any] ?? ["false":"false"]
                     let streamCount = data["streamCount"] as? Int ?? 0
                     let soundcloudLink = data["soundcloudLink"] as? String ?? "None"
                     let spotifyLink = data["spotifyLink"] as? String ?? "None"
                     let itunesLink = data["itunesLink"] as? String ?? "None"
                     let trackId = document.documentID
                     let totalLikes =  data["totalLikes"] as? Int ?? 0
                     let totalDislikes =  data["totalDisikes"] as? Int ?? 0
                     
                     
                     
                     print("Track Id: \(trackId)")
                 
                     
                     
                       if trackURL.prefix(4) == "http"  {
                         
                   
                         
                    
                         
                         if !Double(latitude)!.isNaN && !Double(longitude)!.isNaN{
                            _ = CLLocation(latitude: Double(latitude)! , longitude: Double(longitude)! )
                        
                            
                             
                             
                             let card = CardV2(artistName: username, trackName: trackName, genre: genre, coverArtLink: coverURL, backgroundLink: backgroundURL, albumName: albumName, trackLink: trackURL, trackSource: "none", radius: Int(radius) ?? 100, latitude: Double(latitude)!, longitude: Double(longitude)!, city: city, state: state, country: country, uid: uid, distance: 0, id: id, date: String(unixDate), streamCount: streamCount, likedBy: likedBy, dislikedBy: dislikedBy, soundcloudLink: soundcloudLink, spotifyLink: spotifyLink, itunesLink: itunesLink, trackId:trackId, totalLikes: totalLikes, totalDislikes: totalDislikes )
                             
                            self.cards.append(card)
                            
                            
                             
                             
                         }else{
                               let card = CardV2(artistName: username, trackName: trackName, genre: genre, coverArtLink: coverURL, backgroundLink: backgroundURL, albumName: albumName, trackLink: trackURL, trackSource: "none", radius: Int(radius) ?? 100, latitude: Double(latitude)!, longitude: Double(longitude)!, city: city, state: state, country: country, uid: uid, distance: 1000000, id: id, date: String(unixDate), streamCount: streamCount, likedBy: likedBy, dislikedBy: dislikedBy, soundcloudLink: soundcloudLink, spotifyLink: spotifyLink, itunesLink: itunesLink, trackId:trackId , totalLikes: totalLikes, totalDislikes: totalDislikes )
                             
                             
                            self.cards.append(card)
                             
                         }
                        
                     
                    
    
                    // UserInfo.sources.append(audioItem)
                     
                     
                     
                   //  self.cards.append(card)
                    
                   
                     }
                     
                   
                    
            
                     }
                 }
             print("done getting firestore tracks")
            print("Card Count: \(self.cards.count)")
            
             
             
        
             
            
             
         }
     }
    
    //remove field that was causing everything to be slow
       func addGeohashToRealTimeDb(){
           
           for card in cards{
               let cardKey = card.id ?? "jAyWuKwPECcmDvejHsKZ"
               
               if cardKey != "jAyWuKwPECcmDvejHsKZ"{
                   let db = Firestore.firestore()
                   
                   print("Attmpting For: \(card.trackName)")
                   db.collection("all-tracks").document(cardKey)
                       
                       .getDocument() { (document, err) in
                           if err != nil {
                               // Some error occured
                                 print("Error For: \(card.trackName)")
                           } else {
                               
                            
                            let geofireRef = Database.database().reference().child("Geofire")
                                   let geoFire = GeoFire(firebaseRef: geofireRef)
                                   
                            geoFire.setLocation(CLLocation(latitude: card.latitude, longitude: card.longitude), forKey: cardKey) { (error) in
                                     if (error != nil) {
                                       print("An error occured: \(error)")
                                     } else {
                                       print("Saved location successfully!")
                                     }
                                   }
                           
                               
                     
                               
                               print("Done For: \(card.trackName)")
                            
                           }
                   }
               }
               
                   
               }
               

               
             
        
       }
    
    func findCardsAndPopulate(){
        
         self.cardModels.removeAll()
            print("finding cards")
            for card in cardKeys{
               
                
                if true{
                    let db = Firestore.firestore()
                    
                    print("Attmpting For: \(card)")
                    db.collection("all-tracks").document(card)
                        
                        .getDocument() { (document, err) in
                            if err != nil {
                                // Some error occured
                                  print("Error For: \(card)")
                            } else {
                                
                                let data = document?.data()
                                                
                                                    
                                _ = data?["artist"] as? String ?? "None"
                                                    _ = data?["producer"] as? String ?? "None"
                                                    let username = data?["username"] as? String ?? "None"
                                                    let trackName = data?["title"] as? String ?? "None"
                                                    _ = data?["description"] as? String ?? "None"
                                                    let genre = data?["genre"] as? String ?? "None"
                                                    let coverURL = data?["imgUrl"] as? String ?? "None"
                                                    let backgroundURL = data?["username"] as? String ?? "None"
                                                    let albumName = data?["album_title"] as? String ?? "None"
                                                    let trackURL = data?["trackUrl"] as? String ?? "http://www.noiseaddicts.com/samples_1w72b820/2514.mp3"
                                                    let radius = data?["radius"] as? String ?? "100"
                                                    let latitude = data?["latitude"] as? String ?? "-33.918861"
                                                   let longitude = data?["longitude"] as? String ?? "18.423300"
                                                    let city = data?["city"] as? String ?? "None"
                                                    let state = data?["state"] as? String ?? "None"
                                                    let country = data?["country"] as? String ?? "None"
                                                    let uid = data?["uid"] as? String ?? "None"
                                let id = document?.documentID
                                                    let unixDate = data?["time"] as? Int ?? 1561696540741
                                                   let likedBy = data?["likedBy"] as? [String: Any] ?? ["false":"false"]
                                                    let dislikedBy = data?["dislikedBy"] as? [String: Any] ?? ["false":"false"]
                                                    let streamCount = data?["streamCount"] as? Int ?? 0
                                                    let soundcloudLink = data?["soundcloudLink"] as? String ?? "None"
                                                    let spotifyLink = data?["spotifyLink"] as? String ?? "None"
                                                    let itunesLink = data?["itunesLink"] as? String ?? "None"
                                let trackId = document?.documentID
                                                    let totalLikes =  data?["totalLikes"] as? Int ?? 0
                                                    let totalDislikes =  data?["totalDisikes"] as? Int ?? 0
                                                    
                                                    
                                
                             
                               
                                
                                let card1 = SampleCardModel(name: username, age: streamCount, occupation: "\(city),\(state),\(country)", image: UIImage(named: "julian"))
                            
                                self.cardModels.append(card1)
                      
                                
                                print("Done For: \(card)")
                                self.cardStack.reloadData()
                               
                             
                            }
                    }
                }
                
                    
                }
        
        self.cardStack.reloadData()
                

                
              
         
        }
    
    var cardKeys = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let geofireRef = Database.database().reference().child("Geofire")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        
        
        
        /*
       geoFire.setLocation(CLLocation(latitude: 37.7853889, longitude: -122.4056973), forKey: "firebase-hq5") { (error) in
          if (error != nil) {
            print("An error occured: \(error)")
          } else {
            print("Saved location successfully!")
          }
        }
        */
        let center = CLLocation(latitude: 43.6590521, longitude: -80.2109276)
        // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
        let circleQuery = geoFire.query(at: center, withRadius: 200)
        // Query location by region
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: center.coordinate, span: span)
        _ = geoFire.query(with: region)
        
        circleQuery.observeReady({
          print("All initial data has been loaded and events have been fired!")
            self.findCardsAndPopulate()
        })
        
        circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
         
          print("Key '\(key)' entered the search area and is at location '\(location)'")
            self.cardKeys.append(key)
        })
        
        //getFirestoreTracks()
        
        
        cardStack.delegate = self
        cardStack.dataSource = self
        buttonStackView.delegate = self
     //   configureNavigationBar()
        layoutButtonStackView()
        layoutCardStackView()
        configureBackgroundGradient()
       // print("User Location: \(User.location["city"])")
        // Do any additional setup after loading the view.
    }
     private func configureNavigationBar() {
            let backButton = UIBarButtonItem(title: "Back",
                                             style: .plain,
                                             target: self,
                                             action: #selector(handleShift))
            backButton.tag = 1
            backButton.tintColor = .lightGray
            navigationItem.leftBarButtonItem = backButton
            
            let forwardButton = UIBarButtonItem(title: "Forward",
                                                style: .plain,
                                                target: self,
                                                action: #selector(handleShift))
            forwardButton.tag = 2
            forwardButton.tintColor = .lightGray
            navigationItem.rightBarButtonItem = forwardButton

            navigationController?.navigationBar.layer.zPosition = -1
        }
        
        private func configureBackgroundGradient() {
            let myGrey = UIColor(red: 244/255, green: 247/255, blue: 250/255, alpha: 1)
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.white.cgColor, myGrey.cgColor]
            gradientLayer.frame = view.bounds
            view.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        private func layoutButtonStackView() {
            view.addSubview(buttonStackView)
            buttonStackView.anchor(left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingLeft: 24, paddingBottom: 12, paddingRight: 24)
        }
        
        private func layoutCardStackView() {
            view.addSubview(cardStack)
            cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             left: view.safeAreaLayoutGuide.leftAnchor,
                             bottom: buttonStackView.topAnchor,
                             right: view.safeAreaLayoutGuide.rightAnchor)
        }
        
        @objc private func handleShift(_ sender: UIButton) {
            cardStack.shift(withDistance: sender.tag == 1 ? -1 : 1, animated: true)
        }
    }

