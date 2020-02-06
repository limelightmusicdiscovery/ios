//
//  CardCell.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-11-08.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import Foundation
import UIKit
import VerticalCardSwiper
import SDWebImage
import SwiftAudio

class DiscoverCardCell: CardCell {
    
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var trackFeatures: UILabel!
    @IBOutlet weak var trackAlbum: UILabel!
    @IBOutlet weak var trackGenre: UILabel!
    @IBOutlet weak var trackTimePosted: UILabel!
    @IBOutlet weak var trackCover: SDAnimatedImageView!
    @IBOutlet weak var trackRadius: UILabel!
    @IBOutlet weak var trackUsername: UIButton!
    @IBOutlet weak var trackLocation: UILabel!
    @IBOutlet weak var trackStreamCount: UILabel!
    @IBOutlet weak var playPauseImageView: UIImageView!
    @IBOutlet weak var trackInfoButton: UIButton!
    @IBOutlet weak var soundcloudIcon: UIButton!
    @IBOutlet weak var spotifyIcon: UIButton!
    @IBOutlet weak var itunesIcon: UIButton!
    @IBOutlet weak var userProfileIcon: UIImageView!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    var trackUid: String?
    
    @IBOutlet weak var trackSlider: UISlider!
     @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    var trackId = ""
    
    /**
     We use this function to calculate and set a random backgroundcolor.
     */
    
    var borderFlashTimer: Timer?
    var controller = AudioController.shared
    private var lastLoadFailed: Bool = false
    
    public func setRandomBackgroundColor() {

        //self.backgroundColor = UIColor(red: 31/255, green: 33/255, blue: 36/255, alpha: 1.0)
      //  trackCover.image?.averageColor
        
   //    let shadowColor = trackCover.image?.averageColor
        //trackCover.dropShadow(color: shadowColor ?? .green, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
        
      //  self.layer.borderWidth = 3
       // self.layer.borderColor = shadowColor?.cgColor
        
       
    }
    
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView

        // Your action
    }
    
    @objc func followUser(_ sender: UIButton){
        
        guard let uid = trackUid else{
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }
        
        DispatchQueue.main.async {
            if self.followButton.image(for: .normal) == UIImage(named: "followingButton") {
                self.followButton.setImage(UIImage(named: "followButton"), for: .normal)
                let generator = UINotificationFeedbackGenerator()
                       generator.notificationOccurred(.success)
                       
            }else{
                self.followButton.setImage(UIImage(named: "followingButton"), for: .normal)
                let generator = UINotificationFeedbackGenerator()
                       generator.notificationOccurred(.success)
                       
            }
        }
       
        
        System.checkIfFollowing(uidToCheck: uid, uid: User.uid) { (action) in
            
            if action == "follow"{
                print("followed")
                self.followButton.setImage(UIImage(named: "followingButton"), for: .normal)
            }else if action == "unfollow" {
                print("unfollowed")
                self.followButton.setImage(UIImage(named: "followButton"), for: .normal)
            }else{
                print("error following")
            }
        }
       
        
    }

    
    func handlePlayerFailure(data: AudioPlayer.FailEventData) {
        if let error = data as NSError? {
            
            lastLoadFailed = true
            DispatchQueue.main.async {
                print("Streaming Error: \(error.code)")
                self.trackName.text = "Streaming Error: Please Skip Track - "
                self.trackUsername.setTitle("ERROR: \(error.code)", for: .normal)
            }
            
        }
    }
    
    public func updateTimeValue(){
        trackSlider.maximumValue = Float(self.controller.player.duration)
        trackSlider.setValue(Float(self.controller.player.currentTime), animated: true)
    }
    

    override func prepareForReuse() {
        super.prepareForReuse()

    }
    
    @IBAction func startScrubbing(_ sender: UISlider) {
           isScrubbing = true
       }
       
       @IBAction func scrubbing(_ sender: UISlider) {
           controller.player.seek(to: Double(trackSlider.value))
       }
       
       @IBAction func scrubbingValueChanged(_ sender: UISlider) {
           let value = Double(trackSlider.value)
         //  elapsedTimeLabel.text = value.secondsToString()
          // remainingTimeLabel.text = (controller.player.duration - value).secondsToString()
       }
    
     private var isScrubbing: Bool = false
    
    func handleAudioPlayerStateChange(data: AudioPlayer.StateChangeEventData) {
        //print(data)
        DispatchQueue.main.async {
            //self.setPlayButtonState(forAudioPlayerState: data)
            
            switch data {
            case .loading:
                self.loadIndicator.startAnimating()
               
                self.updateTimeValue()
            case .buffering:
                self.loadIndicator.startAnimating()
              
            case .ready:
                self.loadIndicator.stopAnimating()
               
                self.updateTimeValue()
            case .paused:
                self.loadIndicator.stopAnimating()
                self.playPauseImageView.image = UIImage(named: "play")
                 self.playPauseImageView.alpha = 1
                
            case .playing, .idle:
                self.loadIndicator.stopAnimating()
                self.updateTimeValue()
                 self.playPauseImageView.image = UIImage(named: "pause")
                
                UIView.animate(withDuration: 1.5) {
                 self.playPauseImageView.alpha = 0.0
                   
                }
                  //self.animateOffScreen(angle:  CGFloat(0.12235315438411627))
                     
            }
           
            
        }
    }
    
    var isSwiped = false
    
    public func animateCard(direction: SwipeDirection) {
         let angle = CGFloat(0.14385075637184003)
           print("Angle: \(angle)")
           

           var transform = CATransform3DIdentity
           

           transform = CATransform3DRotate(transform, angle, 0, 0, 1)

           switch direction {
           case .Left:
               transform = CATransform3DTranslate(transform, -(self.frame.width * 2), 0, 1)
           case .Right:
               transform = CATransform3DTranslate(transform, (self.frame.width * 2), 0, 1)
           default:
               break
           }
         //self.delegate?.willSwipeAway(cell: self, swipeDirection: direction)

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
               self?.layer.transform = transform
           }, completion: { _ in
               self.isHidden = true
            
             //  self.delegate?.didSwipeAway(cell: self, swipeDirection: direction)
           })
    }
    
    func handleAudioPlayerSecondElapsed(data: AudioPlayer.SecondElapseEventData) {
        if !isScrubbing {
            DispatchQueue.main.async {
            
                self.updateTimeValue()
            }
        }
    }
    
    func handleAudioPlayerDidSeek(data: AudioPlayer.SeekEventData) {
        isScrubbing = false
    }
    
    func handleAudioPlayerUpdateDuration(data: AudioPlayer.UpdateDurationEventData) {
        DispatchQueue.main.async {
            self.updateTimeValue()
        }
    }
    
    @IBAction func togglePlay(_ sender: Any) {
           if !controller.audioSessionController.audioSessionIsActive {
               try? controller.audioSessionController.activateSession()
               
           }
          
           if lastLoadFailed, let item = controller.player.currentItem {
               lastLoadFailed = false
               //errorLabel.isHidden = true
               try? controller.player.load(item: item, playWhenReady: true)
           }
           else {
               controller.player.togglePlaying()
           
           }
       }
    
    
    

    

    override func layoutSubviews() {

        self.layer.cornerRadius = 3
    
        super.layoutSubviews()
        
        
        //removing listeners for every card has dropped cpu, but has also maybe caused cards to load slower
     
        controller.player.event.secondElapse.removeListener(self)
         controller.player.event.stateChange.removeListener(self)
        controller.player.event.updateDuration.removeListener(self)
         controller.player.event.seek.removeListener(self)
         controller.player.event.fail.removeListener(self)
       
        controller.player.event.stateChange.addListener(self, handleAudioPlayerStateChange)
        controller.player.event.updateDuration.addListener(self, handleAudioPlayerUpdateDuration)
        controller.player.event.seek.addListener(self, handleAudioPlayerDidSeek)
        controller.player.event.fail.addListener(self, handlePlayerFailure)
        if controller.currentlyPlaying?.trackSource == DISCOVERTRACKS {
            
             controller.player.event.secondElapse.addListener(self, handleAudioPlayerSecondElapsed)
            
        }

     trackSlider.setValue(Float(self.controller.player.currentTime), animated: true)
       // System.addedCardAudioListeners = true
        if System.addedCardAudioListeners != true {

        }
        
        
        
        if User.followingIds.contains(trackUid ?? ""){
            self.followButton.setImage(UIImage(named: "followingButton"), for: .normal)
        }else{
              self.followButton.setImage(UIImage(named: "followButton"), for: .normal)
        }
        
        followButton.addTarget(self, action: #selector(self.followUser(_:)), for: .touchUpInside)
      
        
        self.contentView.layer.cornerRadius = 2.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.cornerRadius = 5.0
        

        self.layer.shadowColor = UIColor(red: 109/255, green: 38/255, blue: 185/255, alpha: 1).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 10.0 // 3
        self.layer.shadowOpacity = 0.3 //0.6
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        
        //trackCover.dropShadow(color: trackCover.averageColor?.cgColor, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 5, scale: true)
    }
    
    
}

