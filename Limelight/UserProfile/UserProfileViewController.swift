//
//  UserProfileViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-11-30.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase
import SwiftAudio
import SideMenu
import FirebaseFirestore

class UserProfileViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    var controller = AudioController.shared
    
    func loadProfile(){
        
        bioLabel.text = self.bio
        usernameLabel.text = self.username
        fullNameLabel.text = self.name
        locationLabel.text = self.location
        profilePicture.sd_setImageWithURLWithFade(url: URL(string: self.imageUrl), placeholderImage:  UIImage(named: "coverDefaultImage"))
        
        
        if self.verified == "true" {
            verifiedIcon.isHidden = false
        }
        
        
        
    }
    var subscriptionId = ""
    
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var commentTextfield: UITextField!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersButton: UILabel!
    @IBOutlet weak var followingButton: UILabel!
    @IBOutlet weak var verifiedIcon: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var pointsCountLabel: UILabel!
    
    @IBOutlet weak var followingStackView: UIStackView!
    @IBOutlet weak var followerStackView: UIStackView!
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var commentMiniPicture: UIImageView!
    @IBOutlet weak var libraryTracksCollectionView: UICollectionView!
    @IBOutlet weak var uploadedTracksCollectionView: UICollectionView!
    @IBOutlet weak var yourTracksLabel: UILabel!
    @IBOutlet weak var libraryTracksLabel: UILabel!
    var wallTableView = UITableView()
    @IBOutlet weak var wallUIView: UIView!
    
    @IBOutlet weak var uploadedTracksCell: UITableViewCell!
    
    @IBOutlet weak var editProfileButton: UIButton!
    
    @IBAction func openEditProfile(sender: UIButton) {
        
        if profileUserId == User.uid {
            let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "EditProfile") as! EditProfileViewController
            // secondViewController.modalPresentationStyle = .fullScreen
            secondViewController.bio = bioLabel.text ?? ""
            secondViewController.location = locationLabel.text ?? ""
            secondViewController.name = fullNameLabel.text ?? ""
            secondViewController.username = usernameLabel.text ?? ""
            secondViewController.imgUrl = User.imageUrl
            
            self.present(secondViewController, animated: true, completion: nil)
        }else{
            
            DispatchQueue.main.async {
                if self.editProfileButton.image(for: .normal) == UIImage(named: "followingButton") {
                    self.editProfileButton.setImage(UIImage(named: "followButton"), for: .normal)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                }else{
                    self.editProfileButton.setImage(UIImage(named: "followingButton"), for: .normal)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                }
            }
            
            System.checkIfFollowing(uidToCheck: profileUserId, uid: User.uid) { (action) in
                
                if action == "follow"{
                    print("followed")
                    self.editProfileButton.setImage(UIImage(named: "followingButton"), for: .normal)
                    self.followerIds.append(User.uid)
                    
                    if User.name != "" {
                        System.push.sendPushNotification(to: self.fcmToken, title: "\(User.username) followed you", body: "\(User.username) has started following you.")
                    }else{
                        System.push.sendPushNotification(to: self.fcmToken, title: "\(User.name) (\(User.username)) followed you", body: "\(User.username) has started following you.")
                    }
                    
                    
                    
                }else if action == "unfollow" {
                    print("unfollowed")
                    self.editProfileButton.setImage(UIImage(named: "followButton"), for: .normal)
                    
                    guard let index = self.followerIds.firstIndex(of: User.uid) else {
                        print("error unfollowing from up")
                        return
                    }
                    
                    
                    
                    
                    
                    
                    
                }else{
                    print("error following")
                }
                
                
            }
            
        }
        
    }
    
    func followAction(followUser: String, followedByUser: String, action: String){
        
        db.collection(followedByUser).document(action).collection("userFollowing").document(followUser).setData([
            "timeAdded": NSDate().timeIntervalSince1970,
            "userFollowed": followUser
            
            
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                
            }
        }
        
        db.collection("followers").document(followedByUser).collection("userFollowers").document(User.uid).setData([
            "time": NSDate().timeIntervalSince1970,
            "userFollowedBy": User.uid
            
            
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                
            }
        }
        
    }
    
    
    var db = Firestore.firestore()
    var libraryRef = LIBRARYTRACKS
    var trackKeysArray =  User.trackKeys[LIKEDTRACKS]
    var trackArray = User.likedTracks
    var libraryRef2 = LIKEDTRACKS
    var trackKeysArray2 = User.trackKeys[LIKEDTRACKS]
    var trackArray2 = User.likedTracks
    var safeArea: UILayoutGuide!
    
    var profileUserId = User.uid
    var username = ""
    var bio = ""
    var verified = ""
    var name = ""
    var location = ""
    var imageUrl = ""
    var uploadedTrackKeys = [String]()
    var libraryTrackKeys = [String]()
    
    
    var uploadedTracks: [Track] = []
    
    
    @IBAction func sendComment(_ sender: UIButton) {
        
        if commentTextfield.text != ""{
            sendComment(text: self.commentTextfield.text ?? "", uid: profileUserId)
            
            
            
        }
        
        
        
        
        
    }
    
    
    
    func incremementProfileImpressionCount(uid: String){
        
        if uid != User.uid {
            db.collection("users").document(uid).setData([
                "profileImpressionCount": FieldValue.increment(Int64(1))
                
                ], merge: true)
            { err in
                if let err = err {
                    print("Error writing profile impression count increment document: \(err)")
                } else {
                    print("profile impression count increment successfully written")
                    
                    
                }
            }
        }
        
        
        
        
    }
    
    
    func setupTableView() {
        
        wallTableView.translatesAutoresizingMaskIntoConstraints = false
        wallTableView.addSubview(wallUIView)
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        wallTableView.leftAnchor.constraint(equalTo: wallUIView.leftAnchor).isActive = true
        wallTableView.bottomAnchor.constraint(equalTo: wallUIView.bottomAnchor).isActive = true
        wallTableView.rightAnchor.constraint(equalTo: wallUIView.rightAnchor).isActive = true
        wallTableView.register(TrackCell.self, forCellReuseIdentifier: "trackCell")
        wallTableView.delegate = self
        wallTableView.dataSource = self
        wallTableView.backgroundColor = .clear
        self.view.backgroundColor = .clear
        
        if profileUserId != User.uid {
            self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
        }
        //
        
        
        
        
    }
    
    
    @IBAction func pushFollowers(sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowersView") as! UserFollowersViewController
        secondViewController.profileUid = profileUserId
        secondViewController.followerIds = followerIds
        secondViewController.followingIds = followingIds
        secondViewController.buttonPressed = "followers"
        secondViewController.datas = ["\(followingIds.count) FOLLOWING", "\(followerIds.count) FOLLOWERS"]
        if profileUserId == User.uid {
            //self.present(secondViewController, animated: true, completion: nil)
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }else {
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        
        
    }
    
    @IBAction func pushFollowing(sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowersView") as! UserFollowersViewController
        secondViewController.profileUid = profileUserId
        secondViewController.followerIds = followerIds
        secondViewController.followingIds = followingIds
        secondViewController.buttonPressed = "following"
        secondViewController.datas = ["\(followingIds.count) FOLLOWING", "\(followerIds.count) FOLLOWERS"]
        if profileUserId == User.uid {
            //self.present(secondViewController, animated: true, completion: nil)
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }else {
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        
        
    }
    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 25.0
    private var fillColor: UIColor = .blue
    
    
    
    func getLibraryTracks(trackKeys: [String]){
        
        print("getting \(libraryRef) tracks")
        print("trackKeys count: \(trackKeys.count)")
        var count = 0
        
        
        for trackId in trackKeys{
            
            
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
                        let commentCount =  data?["commentCount"] as? Int ?? 0
                        let limelightLink = "" //need to finish
                        
                        let trackRadius = Int(radius) ?? 0
                        let trackLatitude = Double(latitude) ?? 0.0
                        let trackLongitude = Double(longitude) ?? 0.0
                        let audioItem = DefaultAudioItem(audioUrl: String(trackURL), artist: String(username), title: String(trackName), albumTitle: String(albumName), sourceType: .stream ,artwork: #imageLiteral(resourceName: "itunes_13_icon__png__ico__icns__by_loinik_d8wqjzr-pre"))
                        
                        var likePercentage = 0.0
                        
                        
                        
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
                                                                                                                                                                                                                          LIMELIGHT: 0], radius: trackRadius, streamCount: streamCount, uploadDate: unixDate, likeCount: totalLikes, dislikeCount: totalDislikes, commentCount: commentCount, title: trackName, trackUrl: trackURL, trackId: Id ?? "None", latitude: trackLatitude, longitude: trackLongitude, city: city, state: state, country: country, trackSource: "", audioItem: audioItem, avgCoverColor: UIColor.black, comments: [Comment](), likePercentage: likePercentage, fcmToken: "")
                        
                        
                        let contains = self.libraryTracks.contains { (card) -> Bool in
                            return card.trackId == track.trackId
                            
                        }
                        if !(contains ?? false) && track.trackUrl != "None"{
                            self.libraryTracks.append(track)
                            self.libraryTracksCollectionView.reloadData()
                        }
                        
                        
                        count = count + 1
                        if count == trackKeys.count {
                            
                            //  self.controller.addTracksToSource(trackArray:  User.cards[DISLIKEDTRACKS] ?? [] , source: DISLIKEDTRACKS)
                            // self.controller.loadTracks(source: DISLIKEDTRACKS)
                            self.libraryTracksCollectionView.reloadData()
                            self.libraryTracksLabel.text = "Library Tracks (\(self.libraryTracks.count ))"
                            // self.userTracksCollectionView.reloadData()
                            
                            //self.yourTracksLabel.text = "Your Tracks (\(count))"
                            
                            //self.controller.player.play()
                            
                        }
                        
                        
                        self.libraryTracksCollectionView.reloadData()
                        //self.userTracksCollectionView.reloadData()
                        
                        
                    }
            }
            
            
            
        }
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("profile did appear")
        
        self.tableView.reloadData()
        if profileUserId == User.uid {
            followingButton.text = "\(User.followingIds.count)"//   User.followingIds.append(self.profileUserId)
            followersButton.text = "\(User.followerIds.count)"
            followerIds = User.followerIds
            followingIds = User.followingIds
            if libraryTracks.count < User.cards[LIBRARYTRACKS]?.count ?? 0 {
                libraryTracks = User.cards[LIBRARYTRACKS] ?? []
                self.libraryTracksLabel.text = "Library Tracks (\(libraryTracks.count ))"
                libraryTracksCollectionView.reloadData()
            }
            
            
            
        }
    }
    func setupProfile(){
        if profileUserId != User.uid {
            editProfileButton.setImage(UIImage(named: "followButton"), for: .normal)
        }
        bioLabel.sizeToFit()
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.borderColor = UIColor.darkGray.cgColor
        
        commentMiniPicture.layer.cornerRadius = commentMiniPicture.frame.height / 2
        commentMiniPicture.layer.masksToBounds = true
        
        usernameLabel.text = username //User.username
        bioLabel.text = User.bio
        
        fullNameLabel.text = User.name
        locationLabel.text = "\(User.location[CITY] ?? "N/A"), \(User.location[STATE] ?? "N/A"), \(User.location[COUNTRY] ?? "N/A") " 
        profilePicture.sd_setImageWithURLWithFade(url: URL(string: User.imageUrl), placeholderImage: UIImage(named: "defaultCoverArt"))
        
        commentMiniPicture.sd_setImageWithURLWithFade(url: URL(string: User.imageUrl), placeholderImage: UIImage(named: "defaultCoverArt"))
        
        
        incremementProfileImpressionCount(uid: profileUserId)
        
    }
    
    
    func sendComment(text: String, uid: String){
        
        System.push.sendPushNotification(to: self.fcmToken, title: "\(User.username) posted on your wall.", body: "\(User.username) posted on your wall.")
        let comment = Comment(text: text, username: User.username, uid: User.uid, profileImage: User.imageUrl, datePosted: Int(NSDate().timeIntervalSince1970), commentId: "", fcmToken: User.fcmToken)
        commentView.wallPosts.append(comment)
        commentTextfield.text = ""
        self.view.endEditing(true)
        self.postsLabel.text = "Posts (\(commentView.wallPosts.count))"
        commentView.tableView.reloadData()
        commentView.scrollToBottom()
        
        System.postToWallByUid(text: text, uid: uid) { (didPost) in
            print("Did post to wall: \(didPost)")
            print("FCM: \(self.fcmToken)")
            
            
            
        }
        
        
    }
    var commentView = UserCommentsViewController()
    
    
    func setNavBarLogo(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = .black
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
        imageView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "smallLimelightLogo")
        imageView.image = image
        
        self.navigationItem.titleView = imageView
    }
    
    var followerIds = [String]()
    var followingIds = [String]()
    
    
    func getUserDetails(profileUid: String){
        print("getting followers")
        System.getFollowerIdsForUid(uid: profileUserId) { (followerIds) in
            
            self.followerIds = followerIds
            self.followersButton.text = "\(followerIds.count)"
            if followerIds.contains(User.uid) && self.profileUserId != User.uid{
                self.editProfileButton.setImage(UIImage(named: "followingButton"), for: .normal)
            }
            
            if self.profileUserId == User.uid {
                User.followerIds = followerIds
            }
        }
        print("getting following")
        System.getFollowingIdsForUid(uid: profileUserId) { (followingIds) in
            self.followingIds = followingIds
            self.followingButton.text = "\(followingIds.count)"
            if self.profileUserId == User.uid {
                User.followingIds = followingIds
            }
        }
        print("getting wall posts")
        System.getWallPosts(uid: profileUserId) { (wallPosts) in
            print("done getting \(wallPosts.count) wall posts")
            self.postsLabel.text = "Posts (\(wallPosts.count))"
            // self.commentView.wallPosts = wallPosts
            //self.commentView.tableView.reloadData()
            self.commentView.getCurrentUserDetailForPosts(trackId: profileUid)
            
            
            
        }
        
    }
    
    @objc func updateUserDetail(){
        bioLabel.text = User.bio
        
        fullNameLabel.text = User.name
        locationLabel.text = "\(User.location[CITY] ?? "N/A"), \(User.location[STATE] ?? "N/A"), \(User.location[COUNTRY] ?? "N/A") "
        profilePicture.sd_setImageWithURLWithFade(url: URL(string: User.imageUrl), placeholderImage: UIImage(named: "defaultCoverArt"))
        
        commentMiniPicture.sd_setImageWithURLWithFade(url: URL(string: User.imageUrl), placeholderImage: UIImage(named: "defaultCoverArt"))
        
        self.commentView.wallPosts.removeAll()
        self.commentView.getCurrentUserDetailForPosts(trackId: profileUserId)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(pushFollowers(sender:)))
        followerStackView.isUserInteractionEnabled = true
        followerStackView.addGestureRecognizer(tap)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(pushFollowing(sender:)))
        followingStackView.isUserInteractionEnabled = true
        followingStackView.addGestureRecognizer(tap2)
        
        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(updateUserDetail),
                name: NSNotification.Name(rawValue: "updateUserDetail"),
                object: nil)
        
        
        
        setNavBarLogo()
        
        self.hideKeyboardWhenTappedAround()
        
        //stackNavBar()
        safeArea = view.layoutMarginsGuide
        
        setupProfile()
        commentView.profileUid = profileUserId
        
        self.addChild(commentView)
        wallUIView.addSubview(commentView.view)
        
        
        if profileUserId == User.uid {
            // setupNavBarButtons()
            //setupSideMenu()
            if User.cards[LIBRARYTRACKS]?.count == 0{
                
                System.getTrackIdsBySource(uid: User.uid, source: LIBRARYTRACKS){ (trackIds) in
                    
                    self.getLibraryTracks(trackKeys: trackIds)
                }
                
            }else {
                libraryTracks = User.cards[LIBRARYTRACKS] ?? []
            }
            
            System.getTrackIdsBySource(uid: profileUserId, source: UPLOADEDTRACKS) { (trackIds) in
                System.getTracksByIdsForSource(source: UPLOADEDTRACKS, trackIds: trackIds) { (tracks) in
                    print("UPLOADED TRACK COUNT: \(tracks.count)")
                    self.yourTracksLabel.text = "Uploaded Tracks (\(tracks.count))"
                    self.uploadedTracks = tracks
                    self.controller.addTracksToSource(trackArray: User.cards[UPLOADEDTRACKS] ?? [] , source: UPLOADEDTRACKS)
                    self.tableView.reloadData()
                    self.uploadedTracksCollectionView.reloadData()
                    
                }
            }
        }else {
            System.getTrackIdsBySource(uid: profileUserId, source: LIBRARYTRACKS){ (trackIds) in
                
                self.getLibraryTracks(trackKeys: trackIds)
            }
            
            System.getTrackIdsBySource(uid: profileUserId, source: UPLOADEDTRACKS) { (trackIds) in
                System.getTracksByIdsForSource(source:UPLOADEDTRACKS, trackIds: trackIds) { (tracks) in
                    print("UPLOADED TRACK COUNT: \(tracks.count)")
                    self.yourTracksLabel.text = "Uploaded Tracks (\(tracks.count))"
                    self.uploadedTracks = tracks
                     self.controller.addTracksToSource(trackArray: User.cards[UPLOADEDTRACKS] ?? [] , source: UPLOADEDTRACKS)
                    self.tableView.reloadData()
                    self.uploadedTracksCollectionView.reloadData()
                }
            }
            
            
        }
        
        
        getUserInfo(uid: profileUserId)
        getUserDetails(profileUid: profileUserId)
        self.view.backgroundColor = .clear
        if profileUserId != User.uid {
            self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1200), andColors: BACKGROUNDGRADIENT)
        }
        
        
        
        
    }
    
    var fcmToken = ""
    
    
    func getUserInfo(uid: String) {
        
        //set User Uid for further reference
        print("UID: \(uid)")
        
        
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                
                let data = document.data()
                
                let city = data?["city"] as? String ?? "None"
                let state = data?["state"] as? String ?? "None"
                let listenerPoints = data?["listenerPoints"] as? Int ?? 0
                let country = data?["country"] as? String ?? "None"
                let profilePhoto = data?["photoUrl"] as? String ?? "None"
                let username = data?["username"] as? String ?? ""
                let subscriptionId = data?["subscriptionId"] as? String ?? "None"
                let fcmToken =  data?["fcmToken"] as? String ?? "None"
                //let subscriptionId = data?["subscriptionId"] as? String ?? "None"
                let bio = data?["bio"] as? String ?? ""
                let verified = data?["verified"] as? String ?? "false"
                //let coverPhoto = data?["coverPhotoUrl"] as? String ?? "" NOT USED YET
                let name = data?["name"] as? String ?? ""
                _ = data?["spotify"] as? String ?? ""
                _ = data?["applemusic"] as? String ?? ""
                _ = data?["soundcloud"] as? String ?? ""
                _ = data?["twitter"] as? String ?? ""
                _ = data?["instagram"] as? String ?? ""
                _ = data?["spotifyClicks"] as? Int ?? 0
                _ = data?["soundcloudClicks"] as? Int ?? 0
                _ = data?["applemusicClicks"] as? Int ?? 0
                _ = data?["twitterClicks"] as? Int ?? 0
                _ = data?["instagramClicks"] as? Int ?? 0
                _ = data?["listenerPoints"] as? Int ?? 0
                
                //not sure if below will work
                
                if subscriptionId == "None" {
                    
                    self.pointsLabel.text = "LIMELIGHT XP"
                    self.pointsCountLabel.text = System.formatNumber(listenerPoints)
                }else {
                    self.pointsLabel.text = "OUTREACH"
                    self.pointsCountLabel.text = System.formatNumber(listenerPoints)
                }
                
                
                
                self.location = "\(city.uppercased()), \(state.uppercased()), \(country.uppercased()) "
                self.imageUrl = profilePhoto
                self.username = username
                self.bio = bio
                self.name = name
                self.verified = verified
                self.subscriptionId = subscriptionId
                self.fcmToken = fcmToken
                
                self.loadProfile()
                
                
                //User.socials["spotify"] = spotify
                //User.socials["applemusic"] = appleMusic
                //User.socials["soundcloud"] = soundcloud
                // User.socials["twitter"] = twitter
                // User.socials["instgram"] = instagram
                //add limelight social link
                
                
                //not sure if below will work
                // User.followers = followers ?? [String]()
                // User.following = following ?? [String]()
                
                
                
            }
        }
    }
    
    
    
    
    
    var sideMenu = SideMenuNavigationController(rootViewController: SideMenuViewController())
    
    func setupSideMenu(){
        //  SideMenuPresentationStyle.menuStartAlpha = 1
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenu")
        sideMenu = SideMenuNavigationController(rootViewController: newViewController)
        
        sideMenu.leftSide = true
        sideMenu.presentationStyle = .menuSlideIn
        sideMenu.menuWidth = 300
    }
    
    
    @objc func backTapped(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func pushSideMenu(){
        present(sideMenu, animated: true, completion: nil)
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
    
    @IBAction func pushSide(sender: UIButton){
        pushSideMenu()
    }
    
    @IBAction func backTap(sender: UIButton){
        backTapped()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if false{//profileUserId == User.uid {
            
            let headerView = UIView()
            headerView.backgroundColor = UIColor.black
            
            let headerLabel = UILabel(frame: CGRect(x: headerView.frame.width / 2, y: headerView.frame.height / 2, width:
                tableView.bounds.size.width, height: tableView.bounds.size.height))
            headerLabel.font = UIFont(name: "Poppins", size: 10)
            headerLabel.textColor = UIColor.white
            headerLabel.text = "Profile Visits"
            headerLabel.textAlignment = .center
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
            return headerView
        }
        
        
        
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            
            if false{//profileUserId == User.uid {
                return 30
            }else{
                return 1
            }
            
            //Now section 0's header is hidden regardless of the new behaviour in iOS11.
        }
        
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //remove uploaded tracks if is not artist
        if indexPath.row == 0 {
            return 213
        }
        
        if indexPath.row == 1 {
            if self.uploadedTracks.count > 0 {
                return 194
            }else {
                return 0
            }
        }
        
        if indexPath.row == 2 {
            return 194
        }
        
        
        if indexPath.row == 3 {
            return 375
        }
        if indexPath.row == 4 {
            return 68
        }
        
        return 100
    }
    
    
    lazy var libraryTracks = [Track]()
    
    
    //add viewdidappear methods for cards that show uo later
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == uploadedTracksCollectionView{
            return self.uploadedTracks.count
        }
        
        return libraryTracks.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = libraryTracksCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TrackCollectionViewCell
        
        
        if libraryTracks.indices.contains(indexPath.row) {
            let card = libraryTracks[indexPath.row]
            cell.trackArtist.text = card.artistUsername
            cell.trackName.text = card.title
            cell.trackCover.sd_setImage(with: URL(string:  card.imageUrl ), placeholderImage: UIImage(named: "coverDefaultImage"),options: [ .scaleDownLargeImages], completed: { (image, error, cacheType, imageURL) in
                // Perform operation.
                
                Cache.incrementImageCacheCount()
            })
            // set the corner radius
           // cell.trackCover.layer.cornerRadius = 3.0
           // cell.trackCover.layer.masksToBounds = true
                // cell.trackCover.layer.borderWidth = 1
          //  cell.trackCover.layer.borderColor = UIColor.darkGray.cgColor
            
            
        }
        
        
        if collectionView == uploadedTracksCollectionView {
            
            let cell2 = uploadedTracksCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TrackCollectionViewCell
            
            if self.uploadedTracks.indices.contains(indexPath.row) {
                let card = self.uploadedTracks[indexPath.row]
                cell2.trackArtist.text = card.artistUsername
                cell2.trackName.text = card.title
                cell2.trackCover.sd_setImage(with: URL(string:  self.uploadedTracks[indexPath.row].imageUrl ?? ""), placeholderImage: UIImage(named: "coverDefaultImage"),options: [ .scaleDownLargeImages], completed: { (image, error, cacheType, imageURL) in
                    // Perform operation.
                    
                    Cache.incrementImageCacheCount()
                })
                cell2.trackCover.layer.cornerRadius = 3.0
                cell2.trackCover.layer.masksToBounds = true
               // cell2.trackCover.layer.borderWidth = 1
               // cell2.trackCover.layer.borderColor = UIColor.darkGray.cgColor
                
            }
            
            
            return cell2
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        if collectionView == libraryTracksCollectionView  && controller.currentlyPlaying!.artistUid != profileUserId {
            if controller.currentSource != LIBRARYTRACKS {
                controller.player.stop()
                controller.player.removeUpcomingItems()
                System.getTrackIdsBySource(uid: profileUserId, source: LIBRARYTRACKS) { (trackIds) in
                    System.getTracksByIdsForSource(source: LIBRARYTRACKS, trackIds: trackIds) { (tracks) in
                       
                       
                        self.controller.addTracksToSource(trackArray: User.cards[LIBRARYTRACKS] ?? [] , source: LIBRARYTRACKS)
                        self.controller.loadTracks(source: LIBRARYTRACKS)
                        self.controller.playTrack(index: indexPath.row, source: LIBRARYTRACKS)
                        //self.tableView.reloadData()
                            // self.uploadedTracksCollectionView.reloadData()
                        
                    }
                }
            }else {
                 controller.playTrack(index: indexPath.row, source: LIBRARYTRACKS)
            }
            controller.profileUid = profileUserId
           
        }
        if collectionView == uploadedTracksCollectionView {
            let cell2 = uploadedTracksCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TrackCollectionViewCell
            print("curr artist: " + controller.currentlyPlaying!.artistUid)
            print("curr profile: " + profileUserId)
            if controller.currentSource != UPLOADEDTRACKS {
                controller.player.stop()
            }
            
            if controller.currentSource == UPLOADEDTRACKS && controller.currentlyPlaying!.artistUid != profileUserId {
                controller.player.stop()
                controller.player.removeUpcomingItems()
                System.getTrackIdsBySource(uid: profileUserId, source: UPLOADEDTRACKS) { (trackIds) in
                    System.getTracksByIdsForSource(source: UPLOADEDTRACKS, trackIds: trackIds) { (tracks) in
                       
                        self.uploadedTracks = tracks
                        self.controller.addTracksToSource(trackArray: User.cards[UPLOADEDTRACKS] ?? [] , source: UPLOADEDTRACKS)
                        self.controller.loadTracks(source: UPLOADEDTRACKS)
                        self.controller.playTrack(index: indexPath.row, source: UPLOADEDTRACKS)
                        //self.tableView.reloadData()
                            // self.uploadedTracksCollectionView.reloadData()
                        
                    }
                }
               
                //controller.playTrack(index: indexPath, source: <#T##String#>)
                controller.profileUid = profileUserId
            }else{
                cell2.trackCover.layer.cornerRadius = 3.0
                                          cell2.trackCover.layer.masksToBounds = true
                     //                     cell2.trackCover.layer.borderWidth = 1
                      //                    cell2.trackCover.layer.borderColor = UIColor.purple.cgColor
                           //controller.profileUid = profileUserId
                           controller.playTrack(index: indexPath.row, source: UPLOADEDTRACKS)
            }
            
        
            
            
           
        }
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
