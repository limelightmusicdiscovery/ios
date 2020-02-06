//
//  DiscoverViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-10-22.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import VerticalCardSwiper
import FirebaseDatabase
import GeoFire
import FirebaseFirestore
import SDWebImage
import SwiftAudio
import ChameleonFramework
import MapKit
import SideMenu
import Purchases
import PopupDialog
import SwiftMessages
import FirebaseAnalytics

internal class Contact {
    
    let name: String!
    let age: Int!
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    
}

protocol cardControl {
    func reloadCards()
    
}


class DiscoverViewController: UIViewController, VerticalCardSwiperDatasource, VerticalCardSwiperDelegate, ButtonStackViewDelegate, CLLocationManagerDelegate, CAAnimationDelegate, cardControl{
    func reloadCards() {
        cardSwiper.reloadData()
    }
    
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    lazy var controller = AudioController.shared
    var foundTrack = false
    var i = 0
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    var geoFireTracks = GeoFire(firebaseRef: Database.database().reference().child("Geofire"))
    var geoFireUsers = GeoFire(firebaseRef: Database.database().reference().child("GeofireUsers"))
    let gradientOne = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1).cgColor
    let gradientTwo = UIColor(red: 244/255, green: 88/255, blue: 53/255, alpha: 1).cgColor
    let gradientThree = UIColor(red: 196/255, green: 70/255, blue: 107/255, alpha: 1).cgColor
    var locationManager = CLLocationManager()
    var tracks = [Track]()
    var trackKeys = [String]()
    @IBOutlet weak var statusTopLabel: UILabel!
    @IBOutlet weak var pointsCountButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        print("discover will appear")
        //setNavBarLogo()
        //self.navigationController?.view.backgroundColor = .clear
        //super.viewWillAppear(true)
    }
    @IBAction func generateError(_ sender: UIButton){
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    @IBAction func showSearchRadiusContainer(_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let popupNavController = storyboard.instantiateViewController(withIdentifier: "SearchRadius") as? SearchRadiusContainerViewController else { return }
        popupNavController.height = TRACKOPTIONSHEIGHT
        popupNavController.topCornerRadius = TRACKOPTIONSCORNER
        popupNavController.presentDuration = TRACKOPTIONSSPEED
        popupNavController.dismissDuration = TRACKOPTIONSSPEED
        popupNavController.source = LIBRARYTRACKS
        popupNavController.index = 0
        
        
        let generator =  UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        present(popupNavController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Discover did appear")
        
        
        
        UIView.animate(withDuration: 0.5) {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.view.backgroundColor = .clear
            self.navigationController?.navigationBar.layoutIfNeeded()
        }
        
        controller.isDiscoverScreen = true
        //setNavBarLogo()
        
        if true {//controller.currentlyPlaying?.trackSource == DISCOVERTRACKS {
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        
        if self.controller.currentlyPlaying?.trackSource == DISCOVERTRACKS && User.cards[DISCOVERTRACKS]?.indices.contains(self.controller.player.currentIndex) ?? false {
            print("scrolling to \(self.controller.player.currentIndex)")
            if self.discoverPlayingTitle != self.controller.player.currentItem?.getTitle() {
                self.discoverPlayingTitle = self.controller.player.currentItem?.getTitle()
                self.cardSwiper.scrollToCard(at: self.controller.player.currentIndex, animated: true)
                
            }
        }
        
        //cardSwiper.reloadData()
        
        //adjustCardForCurrentlyPlaying()
        
        
        
        //cardSwiper.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Discover will disppear")
        controller.isDiscoverScreen = false
        if User.cards[controller.currentSource]?.indices.contains(controller.currentIndex) ?? false{
            if let playingTrack = controller.currentlyPlaying {
                if controller.player.playerState.rawValue != "stopped" {
                    controller.showMusicPlayer(track: playingTrack, tabBarController: System.tabBarController)
                }
                
            }
            //  if User.cards[controller.currentSource]?.indices.contains(controller.currentIndex) ?? false{
            
        }
        
        
        //controller.playTrack(index: controller.currentIndex, source: controller.currentSource)
    }
    
    func showArtistPayWall(){
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if let e = error {
                print(e.localizedDescription)
            }
            
            // Route the view depending if we have a premium cat user or not
            if false{//purchaserInfo?.entitlements["pro"]?.isActive == true || purchaserInfo?.entitlements["plus"]?.isActive == true {
                
                // if we have a pro_cat subscriber, send them to the cat screen
                //  let storyboard = UIStoryboard(name: "Main", bundle: nil)
                //  let controller = storyboard.instantiateViewController(withIdentifier: "cats")
                //   controller.modalPresentationStyle = .fullScreen
                //     self.present(controller, animated: true, completion: nil)
                print("subscription active")
                
            } else {
                // if we don't have a pro subscriber, send them to the upsell screen
                let controller = SwiftPaywall(
                    termsOfServiceUrlString: "http://limelight.io",
                    privacyPolicyUrlString: "https://limelight.io")
                
                controller.titleLabel.text = "Limelight for Artists"
                controller.subtitleLabel.text = "Higher radius, unlimited uploads, personal artist insights and more!"
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
   
    
    
    
    
    func didTapButton(button: TinderButton) {
        
        let currIndex = cardSwiper.focussedCardIndex ?? 0
        print("CurrIndex for tapped button \(currIndex)")
        
        
        guard let currentCard = User.cards[DISCOVERTRACKS]?[currIndex] else {
            return
        }
        
        switch button.tag {
        case 1:
            print("skip 10 seconds")//cardStack.undoLastSwipe(animated: true)
            let generator = UINotificationFeedbackGenerator()
                           generator.notificationOccurred(.success)
           controller.player.seek(to: controller.player.currentTime + 10)
        case 2:
            print("left")//cardStack.swipe(.left, animated: true)
           
          
            if controller.currentSource == DISCOVERTRACKS {
                           let generator = UINotificationFeedbackGenerator()
                           generator.notificationOccurred(.success)
                
                if cardSwiper.swipeCardAwayProgrammatically(at: currIndex, to: .Left) {
                    
                }
                     
                
                
                
                           
            }else {
                       
               let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
           
            
            
        case 3:
            // Success Style Notification with Left View
          
          
            if let currentCard = User.cards[DISCOVERTRACKS]?[currIndex] {
              
                
                controller.addTrackToUserCollectionCompletion(trackId: currentCard.trackId, source: LIBRARYTRACKS, track: currentCard){ (action) in
                      let success = MessageView.viewFromNib(layout: .cardView)
                      var result = "Added to Library"
                    
                    if action == "added" {
                          success.configureTheme(.success)
                    }else {
                          success.configureTheme(.error)
                          result = "Removed from Library"
                    }
                    
                    System.imageDownloader.loadImage(with: URL(string: currentCard.imageUrl), progress: nil) {
                                      (image, error, cacheType, imageURL, progress, data) in
                        let defaultImage = DEFAULTCOVERIMAGE
                        let resizedDefaultImage = defaultImage?.resized(toWidth: 50)
                        let roundedDefaultImage = resizedDefaultImage?.withRoundedCorners(radius: 5)
                        let resizedImage = image?.resized(toWidth: 50)
                        let roundedImage = resizedImage?.withRoundedCorners(radius: 5)
                                
                     // body:"\(currentCard.title) by \(currentCard.artistUsername)"
                        success.configureContent(title: "\(currentCard.title) by \(currentCard.artistUsername)", body: result, iconImage: roundedImage ?? roundedDefaultImage!)
                                                    
                                     // success.backgroundColor = .purple
                                                       success.configureDropShadow()
                                      success.button?.isHidden = true
                                             //.window(windowLevel: UIWindow.Level.normal)
                        SwiftMessages.show(config: self.successConfig, view: success)
                                  }
                  
                }
                
                                 //success.configureContent(title: "Success", body: "Something good happened!")
       
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                //controller.addTrackToUserCollection(trackId: currentCard.trackId, source: LIBRARYTRACKS, track: currentCard)
            }
            print("up")//cardStack.swipe(.up, animated: true)
        case 4:
           
            if controller.currentSource == DISCOVERTRACKS {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                
                if cardSwiper.swipeCardAwayProgrammatically(at: currIndex, to: .Right) {
                     
                }
               
               
                
               
            }
                
            else{
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
            
            print("right")//cardStack.swipe(.right, animated: true)
            
        default:
            break
        }
    }
    
    
    
    //  var geofireRef = Database.database().reference().child("Geofire")
    
    
    
    
    func preloadTrack(index: Int){
        if let track = User.sources[DISCOVERTRACKS]?[index] {
            
            if controller.player.items.indices.contains(index) {
                
                print("Attempting to preload next track")
                
                let concurrentQueue = DispatchQueue(label: "trackPreload", attributes: .concurrent)
                concurrentQueue.sync {
                    controller.player.preload(item: track)
                    print("Next track has been preloaded")
                }
                
                
            }
            
        }else{
            print("ERROR: Unable to preload track")
        }
    }
    
    
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        User.cards[DISCOVERTRACKS]?.count ?? 0
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        // Your action
        
        if controller.currentlyPlaying?.trackSource == DISCOVERTRACKS {
            controller.player.togglePlaying()
        }else{
            controller.playTrack(index: cardSwiper.focussedCardIndex ?? 0, source: DISCOVERTRACKS)
            controller.player.play()
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
            cardSwiper.reloadData()
        }
        
    }
    
    
    
    
    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        
        if let cardCell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "DiscoverCardCell", for: index) as? DiscoverCardCell {
           
            if let card = User.cards[DISCOVERTRACKS]?[index] {
                
                cardCell.trackName.text = card.title
                cardCell.trackUsername.setTitle(String(card.artistUsername), for: .normal)
                cardCell.trackLocation.text = "\(String(card.city).uppercased()), \(String(card.state).uppercased())"
                cardCell.trackCover.sd_setImage(with: URL(string: card.imageUrl))
                cardCell.trackRadius.text = "\(card.radius)km"
                cardCell.trackStreamCount.text = "\(String(card.streamCount)) streams"
                cardCell.trackTimePosted.text = "\(timeSince(from: NSDate(timeIntervalSince1970: TimeInterval(card.uploadDate / 1000))))"
                cardCell.trackGenre.text = card.genre
                cardCell.trackSlider.value = 0.0
                cardCell.trackUid = card.artistUid
                
                if card.socials[SPOTIFY] == "null" || card.socials[SPOTIFY] == "None" || card.socials[SPOTIFY]?.count == 0{
                    cardCell.spotifyIcon.alpha = 0.5
                }else {
                    cardCell.spotifyIcon.alpha = 1
                }
                if card.socials[APPLEMUSIC] == "null" || card.socials[APPLEMUSIC] == "None" || card.socials[APPLEMUSIC]?.count == 0{
                                   cardCell.itunesIcon.alpha = 0.5
                               }else {
                                   cardCell.itunesIcon.alpha = 1
                }
                if card.socials[SOUNDCLOUD] == "null" || card.socials[SOUNDCLOUD] == "None" || card.socials[SOUNDCLOUD]?.count == 0{
                                   cardCell.soundcloudIcon.alpha = 0.5
                               }else {
                                   cardCell.soundcloudIcon.alpha = 1
                               }
                
                
                if card.commentCount == 1 {
                    cardCell.commentsButton.setTitle("View \(card.commentCount) Comment", for: .normal)
                }else{
                    cardCell.commentsButton.setTitle("View \(card.commentCount) Comments", for: .normal)
                }
                
                if controller.currentlyPlaying?.trackSource != DISCOVERTRACKS {
                    cardCell.playPauseImageView.image = UIImage(named: "play")
                    cardCell.playPauseImageView.alpha = 1
                    
                }
                
                
                cardCell.trackCover.sd_setImage(with: URL(string: card.imageUrl), placeholderImage: UIImage(named: "coverDefaultImage"),options: [ .scaleDownLargeImages], completed: { (image, error, cacheType, imageURL) in
                    // Perform operation.
                    
                    Cache.incrementImageCacheCount()
                    cardCell.setRandomBackgroundColor()
                    
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(tapGestureRecognizer:)))
                    cardCell.trackCover.isUserInteractionEnabled = true
                    cardCell.trackCover.addGestureRecognizer(tapGestureRecognizer)
                    //  cardCell.followButton.addTarget(self, action: #selector(self.followUser(_:)), for: .touchUpInside)
                    cardCell.commentsButton.addTarget(self, action: #selector(self.showTrackComments(_:)), for: .touchUpInside)
                    cardCell.trackUsername.addTarget(self, action: #selector(self.showUserProfile(_:)), for: .touchUpInside)
                    cardCell.spotifyIcon.addTarget(self, action: #selector(self.openSpotifyLink(_:)), for: .touchUpInside)
                    cardCell.itunesIcon.addTarget(self, action: #selector(self.openItunesLink(_:)), for: .touchUpInside)
                    cardCell.soundcloudIcon.addTarget(self, action: #selector(self.openSoundcloudLink(_:)), for: .touchUpInside)
                    
                })
                
            }
            
            
            return cardCell
        }
        return CardCell()
    }
    
    @objc func openSoundcloudLink(_ sender: UIButton) {
        
        let currentIndex = cardSwiper.focussedCardIndex ?? 0
               if User.cards[DISCOVERTRACKS]?.indices.contains(currentIndex) ?? false{
                   if let currentCard =  User.cards[DISCOVERTRACKS]?[currentIndex] {
                     let link = currentCard.socials[SOUNDCLOUD] ?? ""
                    print(link)
                    print(link.count)
                    guard let url = URL(string: currentCard.socials[SOUNDCLOUD] ?? "") else {  let generator = UINotificationFeedbackGenerator()
                                           generator.notificationOccurred(.error)
                        return }
                   
                                          
                    
                    if  link != "" &&  link != "None" && link != "null" && link.count != 0{
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        UIApplication.shared.open(url)
                    }else{
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
                    }
                    
                    
                    
                }
        }
        
       
        
        
        
    }
    
     @objc func openSpotifyLink(_ sender: UIButton) {
        
        let currentIndex = cardSwiper.focussedCardIndex ?? 0
                      if User.cards[DISCOVERTRACKS]?.indices.contains(currentIndex) ?? false{
                          if let currentCard =  User.cards[DISCOVERTRACKS]?[currentIndex] {
                           
                           guard let url = URL(string: currentCard.socials[SPOTIFY] ?? "") else {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                            return }
                           let link = currentCard.socials[SPOTIFY] ?? ""
                                                 
                           
                           if  link != "" &&  link != "None" && link != "null" && link.count != 0{
                               let generator = UINotificationFeedbackGenerator()
                               generator.notificationOccurred(.success)
                               UIApplication.shared.open(url)
                           }else{
                               let generator = UINotificationFeedbackGenerator()
                               generator.notificationOccurred(.error)
                           }
                           
                           
                           
                       }
               }
               
        
        
        
        
    }
    @objc func openItunesLink(_ sender: UIButton) {
        let currentIndex = cardSwiper.focussedCardIndex ?? 0
                      if User.cards[DISCOVERTRACKS]?.indices.contains(currentIndex) ?? false{
                          if let currentCard =  User.cards[DISCOVERTRACKS]?[currentIndex] {
                           
                           guard let url = URL(string: currentCard.socials[APPLEMUSIC] ?? "") else {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                            return }
                           let link = currentCard.socials[APPLEMUSIC] ?? ""
                           print(link)
                           
                           if  link != "" &&  link != "None" && link != "null" && link.count != 0{
                               let generator = UINotificationFeedbackGenerator()
                               generator.notificationOccurred(.success)
                               UIApplication.shared.open(url)
                           }else{
                               let generator = UINotificationFeedbackGenerator()
                               generator.notificationOccurred(.error)
                           }
                           
                           
                           
                       }
               }
               
        
        
        
    }
    
    
    @objc func showTrackComments(_ sender: UIButton) {
        
        let currentIndex = cardSwiper.focussedCardIndex ?? 0
        if User.cards[DISCOVERTRACKS]?.indices.contains(currentIndex) ?? false{
            if let currentCard =  User.cards[DISCOVERTRACKS]?[currentIndex] {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let vc = storyboard.instantiateViewController(withIdentifier: "trackComments") as! TrackCommentsViewController
                vc.trackId = currentCard.trackId
                vc.trackTitle = currentCard.title
                vc.trackArtist = currentCard.artistUsername
                vc.track = currentCard
                vc.delegate = self
                
                
                if #available(iOS 13, *) {
                    self.present(vc, animated: true, completion: nil)
                }else {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                // secondViewController.dataString = textField.text!
                
                
            }
            
        }
        
    }
    
    @objc func showUserProfile(_ sender: UIButton){
        let currentIndex = cardSwiper.focussedCardIndex ?? 0
        if User.cards[DISCOVERTRACKS]?.indices.contains(currentIndex) ?? false{
            if let currentCard =  User.cards[DISCOVERTRACKS]?[currentIndex] {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let vc = storyboard.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
                vc.profileUserId = currentCard.artistUid
                vc.username = currentCard.artistUsername //change to reference
                
                // secondViewController.dataString = textField.text!
                // vc.
                self.navigationController?.pushViewController(vc, animated: true)
                //self.present(vc, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    
    func setBackgroundImageWithTransition(url: String ){
        
        
        backgroundImage.sd_imageTransition = .fade
        backgroundImage.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "trackInfo"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            // Perform operation.
            
            if let downloadedImage = image {
                
                //self.backgroundImage.dissolveImage(image: downloadedImage)
                
                UIView.transition(with:self.backgroundImage, duration: 0.33, options: .transitionCrossDissolve, animations: {
                    self.backgroundImage.image = downloadedImage
                }, completion: nil)
            }else{
                print("ERROR: \(error?.localizedDescription)")
                UIView.transition(with:self.backgroundImage, duration: 0.33, options: .transitionCrossDissolve, animations: {
                    self.backgroundImage.image = UIImage(named: "limelightGreenBars")
                }, completion: nil)
            }
            
            
            
            
            
        })
        
        
        
        
    }
    
    func setBackgroundImage(url: String ){
        
        backgroundImage.sd_setImage(with: URL(string: url))
     
    }
    
    
    
    func transitionGradientBackground(){
        
        
        animateGradient()
    }
    
    func animateGradient() {
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.duration = 0.5
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradient.add(gradientChangeAnimation, forKey: "colorChange")
    }
    
    
    func transitionBackgroundColor(color: UIColor){
        
        let backgroundColor = self.view.backgroundColor
        
        if color != backgroundColor {
            UIView.animate(withDuration: 0.5) {
                self.view.backgroundColor = color// UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: [UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1), UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1),UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1), color])
            }
            
            print("Background color has been set")
        }
        
    }
    
    
    
    @IBOutlet private var cardSwiper: VerticalCardSwiper!
    /*
     private var discoverTracks: [Track] = [] /*[
     Track(artistUsername: "", artistUid: "", genre: "", albumTitle: "", description: "", imageUrl: "", socials: [APPLEMUSIC: "",
     SOUNDCLOUD: "",
     SPOTIFY: "",
     LIMELIGHT: ""], socialClicks: [APPLEMUSIC: 0,
     SOUNDCLOUD: 0,
     SPOTIFY: 0,
     LIMELIGHT: 0], radius: 0, streamCount: 0, uploadDate: 0, likeCount: 0, dislikeCount: 0, title: "Welcome", trackUrl: "", trackId: "", latitude: 0.0, longitude: 0.0, city: "", state: "", country: "", trackSource: "",audioItem: DefaultAudioItem(audioUrl: "String(trackURL)", artist: "String(username)", title: "String(trackName)", albumTitle:" String(albumName)", sourceType: .stream ,artwork: #imageLiteral(resourceName: "itunes_13_icon__png__ico__icns__by_loinik_d8wqjzr-pre")), avgCoverColor: UIColor.black, comments: [Comment]())
     
     ]*/
     */
    private let buttonStackView = ButtonStackView()
    
    func setNavBarLogo(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
        imageView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "smallLimelightLogo")
        imageView.image = image
        
        self.navigationItem.titleView = imageView
        
        let height: CGFloat = 50 //whatever height you want to add to the existing height
        let bounds = self.navigationController!.navigationBar.bounds
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
        
        
    }
    
    
    func removeDiscoverCard(index: Int) {
        print("Removed Discover Card At: \(index)")
        
        if User.sources[DISCOVERTRACKS]?.indices.contains(index) ?? false {
            User.sources[DISCOVERTRACKS]?.remove(at: index)
                   User.cards[DISCOVERTRACKS]?.remove(at: index)
                   try? controller.player.removeItem(at: index)
        }
       
        
        print("\(User.cards[DISCOVERTRACKS]?.count ?? 0) Discover Cards Left")
        
        if User.cards[DISCOVERTRACKS]?.count ?? 0 == 0 {
            controller.player.stop()
            controller.player.removeUpcomingItems()
            controller.player.removePreviousItems()
                
            self.searchRadius += 50
            self.pullTracksWithGeofire(latitude: User.location[LATITUDE] as! Double, longitude: User.location[LONGITUDE] as! Double, radius: Double(self.searchRadius))
        }
    }
    
    
    
    
    func addToSource(swipeDirection: SwipeDirection, currIndex: Int, willSwipeCard: Track){
        if swipeDirection == .Left {
            
            controller.addTrackToUserCollection(trackId: willSwipeCard.trackId, source: DISLIKEDTRACKS, track: willSwipeCard)
            print("disliked: \(willSwipeCard.title)")
            
                   print("swipe direction: left: \(currIndex)")
                   if User.cards[DISCOVERTRACKS]?.indices.contains(currIndex) ?? false {
                       if let currentCard = User.cards[DISCOVERTRACKS]?[currIndex] {
                           // User.trackKeys[DISLIKEDTRACKS]?.append(currentCard.trackId)
                         //  controller.addTrackToUserCollection(trackId: currentCard.trackId, source: DISLIKEDTRACKS, track: currentCard)
                       }
                   }
               }else if swipeDirection == .Right {
                   print("swipe direction: right: \(currIndex)")
            
            controller.addTrackToUserCollection(trackId: willSwipeCard.trackId, source: LIKEDTRACKS, track: willSwipeCard)
             print("liked: \(willSwipeCard.title)")
                   
                   if User.cards[DISCOVERTRACKS]?.indices.contains(currIndex) ?? false {
                       if let currentCard = User.cards[DISCOVERTRACKS]?[currIndex] {
                           print("liked: \(currentCard.title)")
                           // User.trackKeys[LIKEDTRACKS]?.append(currentCard.trackId)
                           //controller.addTrackToUserCollection(trackId: currentCard.trackId, source: LIKEDTRACKS, track: currentCard)
                       }
                   }
               }
    }
    
    var willSwipeCard: Track?
    
    func willSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
          
        let currentIndex = index
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        if User.cards[DISCOVERTRACKS]?.indices.contains(currentIndex) ?? false{
            
            //self.changeTrack(index: currentIndex)
            controller.playTrack(index: currentIndex + 1, source: DISCOVERTRACKS)
            controller.preloadTrack(index: currentIndex + 2, source: DISCOVERTRACKS)
        }
        
        
        if  User.cards[DISCOVERTRACKS]?.indices.contains(index) ?? false{
             willSwipeCard = User.cards[DISCOVERTRACKS]?[index]
        }
       
        removeDiscoverCard(index: currentIndex)
       //
        print("will swipe card away: \(index)")
        
    }
    
    
    func didSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
        incrementListenerPoints(value: 2)
        
       
        
        
        UIView.transition(with: self.cardSwiper,
                                                         duration: 0.3,
                                                         options: .transitionCrossDissolve,
                                                         animations: {   if let card = self.willSwipeCard {
                                                            self.addToSource(swipeDirection: swipeDirection, currIndex: index, willSwipeCard: self.willSwipeCard!)
                                                               }
                                                                })
        
        
        
     
        
       
                                                    
        
    }
    
    
    var sideMenu = SideMenuNavigationController(rootViewController: SideMenuViewController())
    
    @IBAction func pushSide(sender: UIButton){
             pushSideMenu()
         }
    
    func setupSideMenu(){
        //  SideMenuPresentationStyle.menuStartAlpha = 1
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenu")
        sideMenu = SideMenuNavigationController(rootViewController: newViewController)
        
        sideMenu.leftSide = true
        sideMenu.presentationStyle = .menuSlideIn
        sideMenu.menuWidth = 300
    }
  
    
   
    @objc func pushSideMenu(){
        present(sideMenu, animated: true, completion: nil)
    }
    
    @objc func backTapped(){
           dismiss(animated: true, completion: nil)
       }
       
    
    func setupNavBarButtons(){
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "profileBack"), for: .normal)
        button.addTarget(self, action:#selector(backTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: button)
        let button2 = UIButton(type: UIButton.ButtonType.custom)
        button2.setImage(UIImage(named: "settings"), for: .normal)
        button2.addTarget(self, action:#selector(pushSideMenu), for: .touchUpInside)
        button2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton2 = UIBarButtonItem(customView: button2)
        self.navigationItem.rightBarButtonItems = [barButton]
        self.navigationItem.leftBarButtonItems = [barButton2]
    }

    
    func didEndScroll(verticalCardSwiperView: VerticalCardSwiperView) {
        // self.transitionGradientBackground()
        
        
        
        
        if controller.currentSource != DISCOVERTRACKS {
            controller.player.stop()
        }
        
        if let currentIndex = cardSwiper.focussedCardIndex {
            
            
            if User.cards[DISCOVERTRACKS]?.indices.contains(currentIndex) ?? false{
                
                //self.changeTrack(index: currentIndex)
                controller.playTrack(index: currentIndex, source: DISCOVERTRACKS)
                controller.preloadTrack(index: currentIndex + 1, source: DISCOVERTRACKS)
                
                let currentCard = User.cards[DISCOVERTRACKS]?[currentIndex]
                
                print("Did End Scroll At: \(currentCard?.title ?? "")")
                DispatchQueue.main.async {
                    // UI Updates here for task complete.
                    if self.controller.currentlyPlaying?.title != currentCard?.title {
                       // self.setListenerPoints()
                        self.incrementListenerPoints(value: 1)
                    }
                    
                }
                
                
                
            }else{
                print("ERROR: Index out of range on Did End Scroll")
            }
            
        }
        
        
    }
    
    private var isScrubbing: Bool = false
    
    func setupBackgroundView(){
        // backgroundImage.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        //blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(blurEffectView)
        self.view.bringSubviewToFront(cardSwiper)
    }
    
    var discoverPlaying: Track?
    var discoverPlayingTitle: String?
    
    func adjustCardForCurrentlyPlaying(){
        if self.controller.currentlyPlaying?.title != discoverPlaying?.title {
            if self.controller.currentlyPlaying?.trackSource == DISCOVERTRACKS {
                self.discoverPlaying = self.controller.currentlyPlaying
                if User.cards[DISCOVERTRACKS]?.indices.contains(controller.currentIndex + 1) ?? false && controller.player.items[controller.currentIndex + 1].getTitle() == discoverPlaying?.title {
                    self.cardSwiper.scrollToCard(at: self.controller.currentIndex + 1, animated: true)
                }else {
                    let index = self.controller.getTrackIndexInSourceByTitle(source: DISCOVERTRACKS, title: controller.player.items[controller.currentIndex + 1].getTitle() ?? "")
                    
                    if index != -1  {
                        self.cardSwiper.scrollToCard(at: index, animated: true)
                    }
                    
                }
                
            }
        }
    }
    
    func handleAudioPlayerStateChange(data: AudioPlayer.StateChangeEventData) {
        // print(data)
        DispatchQueue.main.async {
            // self.setPlayButtonState(forAudioPlayerState: data)
            
            if self.controller.currentlyPlaying?.trackSource == DISCOVERTRACKS  {
                print("scrolling to \(self.controller.player.currentIndex)")
                if self.discoverPlayingTitle != self.controller.player.currentItem?.getTitle() {
                    self.discoverPlayingTitle = self.controller.player.currentItem?.getTitle()
                    self.cardSwiper.scrollToCard(at: self.controller.player.currentIndex, animated: true)
                    
                }
            }
            
            
            //  self.adjustCardForCurrentlyPlaying()
            switch data {
            case .loading:
                print("Track is loading")
                
            case .buffering:
                print("Track is buffering")
            case .ready:
                print("Track is ready")
                
                
                
            case .playing:
                print("Track is playing")
                
                System.tabBarController.popupItem.leftBarButtonItems?[0].image = UIImage(named: "pause-mini")
            case .paused:
                print("Track is paused")
                System.tabBarController.popupItem.leftBarButtonItems?[0].image = UIImage(named: "play-mini")
            case .idle:
                print("Track is idle")
                
            }
            
        }
    }
    
    
    func pushUserProfileViewController(){
        
        // Define the menu
        // SideMenuNavigationController is a subclass of UINavigationController, so do any additional configuration
        // of it here like setting its viewControllers. If you're using storyboards, you'll want to do something like:
        // let menu = storyboard!.instantiateViewController(withIdentifier: "RightMenu") as! SideMenuNavigationController
        present(sideMenu, animated: true, completion: nil)
        
    }
    
    @IBAction func userProfileClicked(sender: UIButton) {
        pushUserProfileViewController()
    }
    
    func setListenerPoints(){
        
        pointsCountButton.setTitle("\(System.formatNumber(User.listenerPoints)) XP", for: .normal)
    }
    func incrementListenerPoints(value: Int){
        
        User.listenerPoints+=value
        pointsCountButton.setTitle("\(System.formatNumber(User.listenerPoints)) XP", for: .normal)
    }
    
    
    func showStatusBar(){
        self.edgesForExtendedLayout = []//Optional our as per your view ladder
        
        let newView = UIView()
        newView.backgroundColor = .red
        self.view.addSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide
            newView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
            newView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            newView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
            newView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        } else {
            NSLayoutConstraint(item: newView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: view, attribute: .top,
                               multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: newView,
                               attribute: .leading,
                               relatedBy: .equal, toItem: view,
                               attribute: .leading,
                               multiplier: 1.0,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: newView, attribute: .trailing,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .trailing,
                               multiplier: 1.0,
                               constant: 0).isActive = true
            
            newView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }
    
     var successConfig = SwiftMessages.defaultConfig
    
    override func viewDidLoad() {
        super.viewDidLoad()
         System.tabBarController = self.tabBarController!
         System.frame = self.view.frame
        //FirebaseManager.updateFcmToken()
        pullUsersWithGeofire(latitude: User.location[LATITUDE] as! Double, longitude: User.location[LONGITUDE] as! Double, radius: 50.0)
        self.tabBarController!.tabBar.layer.borderWidth = 0.50
        self.tabBarController!.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBarController?.tabBar.clipsToBounds = true
       
        successConfig.presentationStyle = .top
        successConfig.duration = .seconds(seconds: 1.5)
        successConfig.presentationContext = .view(self.cardSwiper)
        print("UID: \(User.uid)")
        print("\(User.followingIds.count) Following")
        
        
        if User.uid != BIZLALUID && !User.followingIds.contains(BIZLALUID) {
            
            System.followUser(userFollowed: BIZLALUID, followedByUser: User.uid) { done in
                print(done)
            }
        }
        
       
        controller.player.event.stateChange.addListener(self, handleAudioPlayerStateChange)
        setNavBarLogo()
        //setupBackgroundView()
       

        setupSideMenu()
        setListenerPoints()
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
        
        cardSwiper.isStackingEnabled = true
        cardSwiper.visibleNextCardHeight = 0
        cardSwiper.topInset = 20
        cardSwiper.sideInset = 20
        
      //  cardSwiper.stackedCardsCount = 0
        //cardSwiper.isStackOnBottom = false
        
        cardSwiper.delegate = self
        cardSwiper.datasource = self
        buttonStackView.delegate = self
        
        // register cardcell for storyboard use
        cardSwiper.register(nib: UINib(nibName: "DiscoverCardCell", bundle: nil), forCellWithReuseIdentifier: "DiscoverCardCell")
        layoutButtonStackView()
        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
        
        //  cardSwiper.scrollToCard(at: <#T##Int#>, animated: <#T##Bool#>)
        
         
        
        System.checkIfRevenueCatSubscriber(uid: User.uid) { subscribed in
            if !subscribed && User.isArtist{
                
                 self.showArtistPayWall()
            }
        
        }
            
           
        

    NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .trackUploaded, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(logoutRequested(_:)), name: .logout, object: nil)
           //setNavBarLogo()
          // setTitle("Settings", andImage: UIImage(named: "smallLimelightLogo")!)
           // Do any additional setup after loading the view.
       }
       
       @objc func onDidReceiveData(_ notification:Notification) {
             // Do something now
        self.getBlacklistKeys(uid: User.uid)
    }
    
    @objc func logoutRequested(_ notification:Notification) {
        
        let defaults = UserDefaults.standard
            
        defaults.set("false", forKey: SavedKeys.isSignedIn)
        
        User.cards[DISCOVERTRACKS]?.removeAll()
        User.sources[DISCOVERTRACKS]?.removeAll()
        User.trackKeys[DISCOVERTRACKS]?.removeAll()
        self.controller.player.stop()
        self.controller.player.removePreviousItems()
         self.controller.player.removeUpcomingItems()
       UIView.transition(with: self.cardSwiper,
                                                        duration: 0.35,
                                                        options: .transitionCrossDissolve,
                                                        animations: { self.cardSwiper.reloadData() })
                                                       
        
    
        
     
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "firstView")
                      vc?.modalPresentationStyle = .fullScreen
                                          
                      self.present(vc!, animated: true, completion: nil)
      
    }
    
    func getBlacklistKeys(uid: String){
        print("Getting Blacklisted keys for UID: \(uid)")
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).collection(BLACKLISTTRACKS).getDocuments { (snapshot, error) in
            
            print("Total \(BLACKLISTTRACKS) documents: \(snapshot!.count)")
            if let error = error
            {
                print("Error getting documents from \(BLACKLISTTRACKS): \(error)");
            }
            else
            {
                
                for document in snapshot!.documents {
                    
                    let data = document.data()
                    
                    
                    let trackId = data["trackId"] as? String ?? "None"
                    
                    if !(User.trackKeys[BLACKLISTTRACKS]?.contains(trackId) ?? true){
                        User.trackKeys[BLACKLISTTRACKS]?.append(trackId)
                    }
                    
                    
                }
                
                print("Blacklisted \(User.trackKeys[BLACKLISTTRACKS]?.count ?? 0) \(BLACKLISTTRACKS) Tracks")
                self.pullTracksWithGeofire(latitude: User.location[LATITUDE] as! Double, longitude: User.location[LONGITUDE] as! Double, radius: Double(self.searchRadius))
                
                
            }
            
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        User.location[LATITUDE] = locValue.latitude
        User.location[LONGITUDE] = locValue.longitude
        
        
        
        getBlacklistKeys(uid: User.uid)
        FirebaseManager.updateUserLocation(uid: User.uid)
        
        
        
        
        locationManager.stopUpdatingLocation()
        
        
    }
    
    private func layoutButtonStackView() {
        view.addSubview(buttonStackView)
        buttonStackView.anchor(left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingLeft: 24, paddingBottom: 18, paddingRight: 24)
    }
    
    
    
    
    var loadedTracks = [String]()
    func findCardsAndPopulate(){
        controller.player.stop()
        controller.player.removePreviousItems()
        controller.player.removeUpcomingItems()
        User.cards[DISCOVERTRACKS]?.removeAll()
        User.sources[DISCOVERTRACKS]?.removeAll()
        
        
        var count = 0
        
        
        print("finding cards")
        for trackId in trackKeys{
            if trackId == "KCKtd4KNxCDYKKqpVxpY"{
                print("KC")
                
            }
            
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
                        let backgroundURL = data?["username"] as? String ?? "None"
                        let albumName = data?["album_title"] as? String ?? "None"
                        let trackURL = data?["trackUrl"] as? String ?? "http://www.noiseaddicts.com/samples_1w72b820/2514.mp3"
                        var radius = data?["radius"] as? String ?? "0"
                        
                        var latitude = data?["latitude"] as? String ?? "0.0"
                        var longitude = data?["longitude"] as? String ?? "0.0"
                        
                        
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
                        let Id = document?.documentID
                        let totalLikes =  data?["totalLikes"] as? Int ?? 0
                        let totalDislikes =  data?["totalDisikes"] as? Int ?? 0
                        let limelightLink = "" //need to finish
                        let commentCount = data?["commentCount"] as? Int ?? 0
                        var likePercentage = 0.0
                        
                        
                        
                        if totalLikes != 0 && totalDislikes != 0 {
                            let totalLikeDislikeCount = totalLikes + totalDislikes
                            likePercentage = (Double(totalLikes) / Double(totalLikeDislikeCount))
                            print("\(trackName): \(likePercentage)% [\(totalLikes) + \(totalDislikes) = \(totalLikeDislikeCount)]")
                        }
                        
                        
                        
                        var trackRadius = Int(radius) ?? 0
                        
                        if trackRadius == 0 {
                            trackRadius = data?["radius"] as? Int ?? 0
                        }
                        let trackLatitude = Double(latitude) ?? 0.0
                        let trackLongitude = Double(longitude) ?? 0.0
                        
                        
                        
                        let audioItem = DefaultAudioItem(audioUrl: String(trackURL), artist: String(username), title: String(trackName), albumTitle: String(albumName), sourceType: .stream ,artwork: #imageLiteral(resourceName: "itunes_13_icon__png__ico__icns__by_loinik_d8wqjzr-pre"))
                        
                        let track = Track(artistUsername: username, artistUid: uid, genre: genre, albumTitle: albumName, description: description, imageUrl: coverURL, socials:[APPLEMUSIC: itunesLink,
                                                                                                                                                                                SOUNDCLOUD: soundcloudLink,
                                                                                                                                                                                SPOTIFY: spotifyLink,
                                                                                                                                                                                LIMELIGHT: limelightLink], socialClicks: [APPLEMUSIC: 0,
                                                                                                                                                                                                                          SOUNDCLOUD: 0,
                                                                                                                                                                                                                          SPOTIFY: 0,
                                                                                                                                                                                                                          LIMELIGHT: 0], radius: trackRadius, streamCount: streamCount, uploadDate: unixDate, likeCount: totalLikes, dislikeCount: totalDislikes,commentCount: commentCount, title: trackName, trackUrl: trackURL, trackId: Id ?? "None", latitude: trackLatitude, longitude: trackLongitude, city: city, state: state, country: country, trackSource: DISCOVERTRACKS,audioItem: audioItem, avgCoverColor: UIColor.black, comments: [Comment](), likePercentage: likePercentage, fcmToken: "")
                        
                        
                        //  self.discoverTracks.append(track)
                        if  !self.loadedTracks.contains(track.trackId){
                            self.loadedTracks.append(track.trackId)
                            User.cards[DISCOVERTRACKS]?.append(track)
                          
                        }
                        
                        print("Done For: \(trackId)")
                        count = count + 1
                        //self.cardSwiper.reloadData()
                        
                        if count == self.trackKeys.count {
                            
                            let sortedByLikePercentage = User.cards[DISCOVERTRACKS]?.sorted(by: { Int($0.streamCount) > Int($1.streamCount) })
                            User.cards[DISCOVERTRACKS] = sortedByLikePercentage
                            var i = 0
                            for card in (User.cards[DISCOVERTRACKS])! {
                                
                                if card.artistUid == User.uid {
                                    User.cards[DISCOVERTRACKS]?.remove(at: i)
                                    User.cards[DISCOVERTRACKS]?.insert(card, at: 0)
                                }
                                i = i + 1
                            }
                            
                            FirebaseManager.getUserInfoForTracks(source: DISCOVERTRACKS)
                            //print("FIRST: \(User.cards[DISCOVERTRACKS]?[0].artistUsername)")
                            UIView.transition(with: self.cardSwiper,
                                                  duration: 0.35,
                                                  options: .transitionCrossDissolve,
                                                  animations: { self.cardSwiper.reloadData() })
                                                 
                                              
                           
                            
                            if  User.cards[DISCOVERTRACKS]?.count ?? 0 > 0 {
                                self.controller.addTracksToSource(trackArray: User.cards[DISCOVERTRACKS] ?? [] , source: DISCOVERTRACKS)
                                                           self.controller.loadTracks(source: DISCOVERTRACKS)
                            self.controller.currentlyPlaying = User.cards[DISCOVERTRACKS]?[0]
                            self.discoverPlaying = User.cards[DISCOVERTRACKS]?[0]
                            // self.controller.player.play()
                            self.discoverPlayingTitle = self.controller.player.currentItem?.getTitle()
                                self.cardSwiper.reloadData()
                                
                            }
                            //self.controller.playTrack(index: 0, source: DISCOVERTRACKS)
                            
                        }
                        
                        
                    }
            }
            
        }
        
        // self.controller.loadTracks()
        
    }
    
    
    
    
    
    func increaseRadius(trackId: String){
        //outreach
        //likes
        //dislikes
        //add tp lo
    }
    
    func pullUsersWithGeofire(latitude: Double, longitude: Double, radius: Double){
        
        let center = CLLocation(latitude: latitude, longitude: longitude)
        // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
        let circleQuery = geoFireUsers.query(at: center, withRadius: radius)
        // Query location by region
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: center.coordinate, span: span)
        _ = geoFireUsers.query(with: region)
        
        var count = 0
        
        circleQuery.observeReady({
            print("All initial data has been loaded and events have been fired!")
            
            
            print("Users in \(radius) km radius: \(count)")
            User.outreachIn50km = count
            
            
            
            Analytics.logEvent(OUTREACHEVENT, parameters: [
            "username": User.username,
         
            "location":  "\(User.location[CITY] ?? "N/A"), \(User.location[STATE] ?? "N/A"), \(User.location[COUNTRY] ?? "N/A")",
            "outreach50km": User.outreachIn50km
            ])
            
            
            
            
        })
        
        circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            
            // print("Key '\(key)' entered the search area and is at location '\(location)'")
            
            count = count + 1
        })
    }
    
    func loadPopupDialogSettings(){
        
        // Customize dialog appearance
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont    = UIFont(name: "HelveticaNeue-Light", size: 16)!
        pv.titleColor   = .white
        pv.messageFont  = UIFont(name: "HelveticaNeue", size: 14)!
        pv.messageColor = UIColor(white: 0.8, alpha: 1)
        
        // Customize the container view appearance
        let pcv = PopupDialogContainerView.appearance()
        pcv.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
        pcv.cornerRadius    = 2
        pcv.shadowEnabled   = true
        pcv.shadowColor     = .purple
        pcv.shadowOpacity   = 0.6
        pcv.shadowRadius    = 20
        
        // Customize overlay appearance
        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled     = true
        ov.blurRadius      = 30
        ov.liveBlurEnabled = true
        ov.opacity         = 0.7
        ov.color           = .black
        
        // Customize default button appearance
        let db = DefaultButton.appearance()
        db.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        db.titleColor     = .white
        db.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        db.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
        
        // Customize cancel button appearance
        let cb = CancelButton.appearance()
        cb.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        cb.titleColor     = UIColor(white: 0.6, alpha: 1)
        cb.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        cb.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
        
    }
    
    func showPopup(){
        
        loadPopupDialogSettings()
        
        // Prepare the popup assets
        let title = "Couldn't find music in your city... yet"
        let message = "But we expanded your search radius to \(System.formatNumber(self.searchRadius))KM and we'll show you the best tracks in that radius"
        let image = UIImage(named: "limelightBlackBackground")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, image: image)
        
        
        
        
        let okButton = DefaultButton(title: "OK", height: 60) {
            
            self.findCardsAndPopulate()
        }
        
        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([okButton])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    var searchRadius = 50
    var showedRadiusWarning = false
    
    func pullTracksWithGeofire(latitude: Double, longitude: Double, radius: Double){
        
        let center = CLLocation(latitude: latitude, longitude: longitude)
        // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
        let circleQuery = geoFireTracks.query(at: center, withRadius: radius)
        // Query location by region
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: center.coordinate, span: span)
        _ = geoFireTracks.query(with: region)
        
        var count = 0
        
        circleQuery.observeReady({
            print("All initial data has been loaded and events have been fired!")
            
            
            if self.trackKeys.count <= 1 {
                self.trackKeys.removeAll()
                self.searchRadius += 50
                self.statusTopLabel.text = "Searching for new music \(self.searchRadius)KM away"
                if self.statusTopLabel.alpha != 1 {
                    UIView.animate(withDuration: 0.5) {
                        self.statusTopLabel.alpha = 1
                    }
                }
                
                print("Search Radius: \(self.searchRadius)KM")
                self.getBlacklistKeys(uid: User.uid)
            }else{
                
                if self.statusTopLabel.alpha != 0 {
                    UIView.animate(withDuration: 0.5) {
                        self.statusTopLabel.alpha = 0
                    }
                }
                
                if self.searchRadius >= 250 {
                    //self.showPopup()
                    let error = MessageView.viewFromNib(layout: .tabView)
                    error.configureTheme(.warning)
                    error.configureDropShadow()
                    let title = "Expanded Distance to \(System.formatNumber(self.searchRadius))KM"
                    let message = "We coudn't find any new music near you so we expanded your search radius further to find new music."
                           let image = UIImage(named: "limelightBlackBackground")
                    self.successConfig.duration = .seconds(seconds: 4)
                    

                    let resizedDefaultImage = image?.resizedSquare(toWidth: 50)
                    let roundedDefaultImage = resizedDefaultImage?.withRoundedCorners(radius: 5)
                    error.configureContent(title: title, body: message)
                    //error.button?.setTitle("Stop", for: .normal)
                    error.button?.isHidden = true
                    SwiftMessages.show(config: self.successConfig, view: error)
                     self.successConfig.duration = .seconds(seconds: 1)
                    self.findCardsAndPopulate()
                   
                    
                }else{
                    self.showMessage(title: "Found \(self.trackKeys.count) New Tracks", body: "We found music near \(User.location[CITY] ?? "You")", duration: 3,type: .success)
                    self.findCardsAndPopulate()
                   
                     self.successConfig.duration = .seconds(seconds: 1)
                
                }
                
            
            }
            //  self.findCardsAndPopulate()
            print("Tracks in \(radius) km radius: \(count)")
            
            
            
            
        })
        
        circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            
            // print("Key '\(key)' entered the search area and is at location '\(location)'")
            if !(User.trackKeys[BLACKLISTTRACKS]?.contains(key) ?? true) && !self.trackKeys.contains(key){
                print("\(key ?? "") not in blacklist")
                self.trackKeys.append(key)
                
                
                count = count + 1
            }else{
                print("\(key ?? "") in blacklist")
            }
            
        })
    }
    
    
    func showMessage(title: String, body: String, duration: Double, type: Theme){
        
        let message = MessageView.viewFromNib(layout: .tabView)
                           message.configureTheme(type)
                           message.configureDropShadow()
                         
                                
                           self.successConfig.duration = .seconds(seconds: duration)
                           

                          
                           message.configureContent(title: title, body: body)
                           //error.button?.setTitle("Stop", for: .normal)
                           message.button?.isHidden = true
                            
                           SwiftMessages.show(config: self.successConfig, view: message)
        self.successConfig.duration = .seconds(seconds: 1.5)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func timeSince(from: NSDate, numericDates: Bool = false) -> String {
        let calendar = Calendar.current
        let now = NSDate()
        let earliest = now.earlierDate(from as Date)
        let latest = earliest == now as Date ? from : now
        let components = calendar.dateComponents([.year, .weekOfYear, .month, .day, .hour, .minute, .second], from: earliest, to: latest as Date)
        
        var result = ""
        
        if components.year! >= 2 {
            result = "\(components.year!) years ago"
        } else if components.year! >= 1 {
            if numericDates {
                result = "1 year ago"
            } else {
                result = "Last year"
            }
        } else if components.month! >= 2 {
            result = "\(components.month!) months ago"
        } else if components.month! >= 1 {
            if numericDates {
                result = "1 month ago"
            } else {
                result = "Last month"
            }
        } else if components.weekOfYear! >= 2 {
            result = "\(components.weekOfYear!) weeks ago"
        } else if components.weekOfYear! >= 1 {
            if numericDates {
                result = "1 week ago"
            } else {
                result = "Last week"
            }
        } else if components.day! >= 2 {
            result = "\(components.day!) days ago"
        } else if components.day! >= 1 {
            if numericDates {
                result = "1 day ago"
            } else {
                result = "Yesterday"
            }
        } else if components.hour! >= 2 {
            result = "\(components.hour!) hours ago"
        } else if components.hour! >= 1 {
            if numericDates {
                result = "1 hour ago"
            } else {
                result = "An hour ago"
            }
        } else if components.minute! >= 2 {
            result = "\(components.minute!) minutes ago"
        } else if components.minute! >= 1 {
            if numericDates {
                result = "1 minute ago"
            } else {
                result = "A minute ago"
            }
        } else if components.second! >= 3 {
            result = "\(components.second!) seconds ago"
        } else {
            result = "Just now"
        }
        
        return result
    }
    
    
    
    
}

