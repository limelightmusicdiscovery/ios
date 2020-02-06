//
//  MusicPlayerViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-11-24.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import LNPopupController
import ChameleonFramework
import SwiftAudio
import MarqueeLabel

class MusicPlayerViewController: UIViewController {
 
        @IBOutlet weak var songNameLabel: UILabel!
        @IBOutlet weak var albumNameLabel: UILabel!
    
        @IBOutlet weak var trackSlider: UISlider!
     var controller = AudioController.shared
   
        
        @IBOutlet weak var albumArtImageView: UIImageView!
    
    @IBOutlet weak var trackLocation: UILabel!
       @IBOutlet weak var trackOutreach: UILabel!
       
      @IBOutlet weak var trackCover: UIImageView!
       @IBOutlet weak var trackStreams: UILabel!
         @IBOutlet weak var trackUsername: UILabel!
    @IBOutlet weak var trackPlayButton: UIButton!
        
        let accessibilityDateComponentsFormatter = DateComponentsFormatter()
        
        var timer : Timer?
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
          
            let pause = UIBarButtonItem(image: UIImage(named: "pause-mini"),  style: .plain, target: self, action: #selector(togglePlayPause(_:)))
          let play = UIBarButtonItem(image: UIImage(named: "play-mini"),  style: .plain, target: self, action: #selector(togglePlayPause(_:)))
                   
            pause.accessibilityLabel = NSLocalizedString("Pause", comment: "")
            
            let next = UIBarButtonItem(image: UIImage(named: "next-mini"), style: .plain, target: self, action: #selector(nextTrack(_:)))
            next.accessibilityLabel = NSLocalizedString("Next Track", comment: "")
            
            let oldOS : Bool
            #if !targetEnvironment(macCatalyst)
            oldOS = ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 10
            #else
            oldOS = false
            #endif
           
        //    let spacer = UIBarButtonItem(barButtonSystemItem: ., target: nil, action: nil)
          //  spacer.width = 10
             popupItem.rightBarButtonItems = [ next]
            
            if controller.player.playerState.rawValue != "playing" {
                popupItem.leftBarButtonItems = [play]
            }else{
                popupItem.leftBarButtonItems = [pause]
            }
            
            
           
                  // controller.player.event.stateChange.removeListener(self)
                
              
                  // controller.player.event.fail.removeListener(self)\
          
            //controller.player.event.stateChange.removeListener(self)
            //controller.player.event.fail.removeListener(self)
           // controller.player.event.stateChange.addListener(self, handleAudioPlayerStateChange)
            //controller.player.event.fail.addListener(self, handlePlayerFailure(data:))
            
            if System.addedMPAudioListeners == true {
               
                System.addedMPAudioListeners = false
            }
            
            if System.addedMPAudioListeners != true {
                
                System.addedMPAudioListeners = true
            }
            
          
            
          
            accessibilityDateComponentsFormatter.unitsStyle = .spellOut
        }
    
    
    
    @IBAction func togglePlayMP(sender: UIButton){
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
         controller.player.togglePlaying()
    }
     
    @objc func togglePlayPause(_ sender: UIBarButtonItem) {
       
        
        
        controller.player.togglePlaying()
    }
    
    
    
    @objc func nextTrack(_ sender: UIBarButtonItem) {
           
        try? controller.player.next()
       // songTitle = controller.player.currentItem?.getTitle() ?? "Error Fetching Title"
        //albumTitle = controller.player.currentItem?.getArtist() ?? "Error Fetching Artist"
       }
    
    var currentTrack = ""
    
    func handlePlayerFailure(data: AudioPlayer.FailEventData) {
        if let error = data as NSError? {
            
           
            DispatchQueue.main.async {
                print("Streaming Error: \(error.code)")
                 self.songTitle = "Streaming Error"
                self.albumTitle =  "Code: \(error.code)"
            }
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("MP did disappear")
          System.showingMP = false
    }
       
    func handleAudioPlayerStateChange(data: AudioPlayer.StateChangeEventData) {
           // print(data)
      
           DispatchQueue.main.async {
               // self.setPlayButtonState(forAudioPlayerState: data)
            
            if self.currentTrack != self.controller.player.currentItem?.getTitle() {
                
                self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(MusicPlayerViewController._timerTicked(_:)), userInfo: nil, repeats: true)

                self.songTitle = self.controller.player.currentItem?.getTitle() ?? "Error Fetching Title"
                self.albumTitle = self.controller.player.currentItem?.getArtist() ?? "Error Fetching Artist"
                self.currentTrack = self.controller.player.currentItem?.getTitle() ?? "Error Fetching Title"
                
               
            }
  
               switch data {
               case .loading:
                   print("MP Track is loading")
                   self.trackPlayButton.isEnabled = false
                    self.updateSliderTimeValue()
               case .buffering:
                   print("MP Track is buffering")
                 self.trackPlayButton.isEnabled = false
               case .ready:
                   print("MP Track is ready")
                 self.trackPlayButton.isEnabled = true
                 self.updateSliderTimeValue()
               case .playing:
                   print("MP Track is playing")
                    self.trackPlayButton.isEnabled = true
                   self.popupItem.leftBarButtonItems?[0].image = UIImage(named: "pause-mini")
                   self.trackPlayButton.setImage(UIImage(named: "pause"), for: .normal)
                 self.updateSliderTimeValue()
               case .paused:
                   print("MP Track is paused")
                    self.trackPlayButton.isEnabled = true
                   self.popupItem.leftBarButtonItems?[0].image = UIImage(named: "play-mini")
                   self.trackPlayButton.setImage(UIImage(named: "play"), for: .normal)
                   self.checkIfPlaying()
               case .idle:
                   print("Track is idle")
                 self.trackPlayButton.isEnabled = true
                   
               }
           }
       }
    
    
    func checkIfPlaying(){
        
        if controller.player.playerState == .playing {
            print("fixed no playing event bug")
            self.popupItem.leftBarButtonItems?[0].image = UIImage(named: "pause-mini")
        }
    }
    
    var track : Track? {
           didSet {
             
       
           }
       }
    
   
    
    var coverArtURL: String = "" {
           didSet {
               if isViewLoaded {
                   print("cover art: \(coverArtURL) - line 188")
                   
                   
                   let cover = URL(string:coverArtURL)
                   
                   // self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
                   // self.automaticallyAdjustsScrollViewInsets = false
                   
                 //  albumArtImageView.sd_setImage(with: cover, placeholderImage: UIImage(named: "defaultCoverImage"))
                   
                  // songNameLabel.text = songTitle
               }
               
              // popupItem.title = songTitle
           }
       }
        
        var songTitle: String = "" {
            didSet {
                if isViewLoaded {
                    songNameLabel.text = songTitle
                }
                
                popupItem.title = songTitle
            }
        }
        var albumTitle: String = "" {
            didSet {
                if isViewLoaded {
                    albumNameLabel.text = albumTitle
                }
                #if !targetEnvironment(macCatalyst)
                if ProcessInfo.processInfo.operatingSystemVersion.majorVersion <= 9 {
                    popupItem.subtitle = albumTitle
                }
                #endif
                popupItem.subtitle = albumTitle
            }
        }
    
    var imgUrl = ""
    
    
        var albumArt: UIImage = UIImage() {
            didSet {
                if isViewLoaded {
                    albumArtImageView.sd_setImage(with: URL(string: imgUrl ), placeholderImage: UIImage(named: "coverDefaultImage"),options: [ .scaleDownLargeImages], completed: { (image, error, cacheType, imageURL) in
                        
                       
                       
                        
                    })
                }
                popupItem.image = albumArt
                popupItem.accessibilityImageLabel = NSLocalizedString("Album Art", comment: "")
            }
        }
    
    @IBAction func showTrackComments(_ sender: UIButton) {
            
       //  self.dismiss(animated: true, completion: nil)
          
               
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let vc = storyboard.instantiateViewController(withIdentifier: "trackComments") as! TrackCommentsViewController
         vc.trackId = track?.trackId ?? ""
         vc.trackTitle = track?.title ?? ""
         vc.trackArtist = track?.artistUsername ?? ""
        vc.track = track
                    //vc.delegate = self
                    // secondViewController.dataString = textField.text!
                    self.present(vc, animated: true, completion: nil)
                    
                
                
            
            
        }
    
    var currentIndex = -1
    var currentSource = ""
    var currentPlayingTrack: Track?
    
    func reloadTrack(){
        
        if currentIndex == -1 {
            let (track, index) = controller.getCurrentlyPlayingTrackFromSource(source: controller.currentSource)
           
            currentIndex = index
            currentPlayingTrack = track
             self.track = track
            
            
            
        }
        let title = controller.player.currentItem?.getTitle()
        let artist = controller.player.currentItem?.getArtist()
        
        if User.cards[currentSource]?.indices.contains(currentIndex) ?? false{
            if let track = User.cards[currentSource]?[currentIndex] {
                print("MP Now Playing: \(track.title) - \(currentSource), \(currentIndex)")
                
                if track.title != title {
                    let (track,  index) = controller.getCurrentlyPlayingTrackFromSource(source: controller.currentSource)
                  
                    currentIndex = index
                    currentPlayingTrack = track
                    
                     self.track = track
                    albumArtImageView.sd_setImage(with: URL(string:track.imageUrl ), placeholderImage: UIImage(named: "coverDefaultImage"),options: [ .scaleDownLargeImages], completed: { (image, error, cacheType, imageURL) in
                                Cache.incrementImageCacheCount()
                        self.checkIfMusicPlaying()
                    self.coverArtShadow()
                               
                           })
                  
                }else {
                    albumArtImageView.sd_setImage(with: URL(string:track.imageUrl ), placeholderImage: UIImage(named: "coverDefaultImage"),options: [ .scaleDownLargeImages], completed: { (image, error, cacheType, imageURL) in
                                Cache.incrementImageCacheCount()
                        self.checkIfMusicPlaying()
                   
                               
                           })
                }
                
                
                
            }
        } else{
            let (track, source, index) =  controller.getCurrentlyPlayingTrack()
            currentSource = source
            currentIndex = index
            currentPlayingTrack = track
            self.track = track
            reloadTrack()
        }
    
        
        
       
    
    
      
        
        songNameLabel.text = title
        albumNameLabel.text = artist
        trackLocation.text = "\(track?.city ?? ""), \(track?.state ?? "")"
        trackStreams.text = "\(track?.streamCount ?? 0) STREAMS"
        trackOutreach.text = "\(track?.radius ?? 0)km STREAMS"
        
    }
    
    func reloadTrack2(){
        songNameLabel.text = self.controller.player.currentItem?.getTitle()
        albumNameLabel.text =  self.controller.player.currentItem?.getArtist()
        let currTrack = controller.currentlyPlaying
        trackLocation.text = "\(currTrack?.city ?? ""), \(currTrack?.state ?? "")"
        trackStreams.text = "\(currTrack?.streamCount ?? 0) STREAMS"
        
        albumArtImageView.sd_setImageWithURLWithFade(url: URL(string:currTrack?.imageUrl ?? "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/eb777e7a-7d3c-487e-865a-fc83920564a1/d7kpm65-437b2b46-06cd-4a86-9041-cc8c3737c6f0.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2ViNzc3ZTdhLTdkM2MtNDg3ZS04NjVhLWZjODM5MjA1NjRhMVwvZDdrcG02NS00MzdiMmI0Ni0wNmNkLTRhODYtOTA0MS1jYzhjMzczN2M2ZjAuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.-bP80wHw6Jb8moQRsxURQxONZvAMnJ6xLDD8Es7mHps" ), placeholderImage: UIImage(named: "coverDefaultImage"))
        
         //self.coverArtShadow()
    }
    @IBAction func nextButton(){
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
       
        controller.playTrack(index: controller.currentIndex + 1, source: controller.currentSource)
         controller.preloadTrack(index: controller.currentIndex + 2, source: controller.currentSource)
         currentIndex += currentIndex
       
        reloadTrack2()
    }
    @IBAction func previousButton(){
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
            controller.playTrack(index: controller.currentIndex - 1, source: controller.currentSource)
       
       
        reloadTrack2()
        currentIndex += currentIndex
       }
     
     @IBAction func shareButtonClicked(sender: AnyObject)
     {
         //Set the default sharing message.
         let message = "\(track?.title ?? "") by \(track?.artistUsername ?? "")"
         //Set the link to share.
         if let link = NSURL(string: "http://bit.ly/limelightapp")
         {
             let objectsToShare = [message,link] as [Any]
             let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
             activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
             self.present(activityVC, animated: true, completion: nil)
         }
     }
    
    func checkIfMusicPlaying(){
        if controller.player.playerState == .playing {
                    self.trackPlayButton.setImage(UIImage(named: "pause"), for: .normal)
              }else{
                    self.trackPlayButton.setImage(UIImage(named: "play"), for: .normal)
              }
              
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("MP did appear")
        System.showingMP = true
        let currTrack = controller.currentlyPlaying
          albumArtImageView.sd_setImageWithURLWithFade(url: URL(string:currTrack?.imageUrl ?? "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/eb777e7a-7d3c-487e-865a-fc83920564a1/d7kpm65-437b2b46-06cd-4a86-9041-cc8c3737c6f0.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2ViNzc3ZTdhLTdkM2MtNDg3ZS04NjVhLWZjODM5MjA1NjRhMVwvZDdrcG02NS00MzdiMmI0Ni0wNmNkLTRhODYtOTA0MS1jYzhjMzczN2M2ZjAuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.-bP80wHw6Jb8moQRsxURQxONZvAMnJ6xLDD8Es7mHps" ), placeholderImage: UIImage(named: "coverDefaultImage"))
        controller.preloadTrack(index: controller.currentIndex + 1, source: controller.currentSource)
       checkIfMusicPlaying()
      
       
        
    }
    
    @IBAction func openOptions(sender: UIButton){
        openTrackOptions(track: track!)
    }
    
    func openTrackOptions(track: Track){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                   
               
                      guard let popupNavController = storyboard.instantiateViewController(withIdentifier: "TrackOptions") as? TrackOptionsViewController else { return }
                     // popupNavController.source = LIKEDTRACKS

                                     popupNavController.track = track
                           popupNavController.height = TRACKOPTIONSHEIGHT
                           popupNavController.topCornerRadius = TRACKOPTIONSCORNER
                      popupNavController.presentDuration = TRACKOPTIONSSPEED
                      popupNavController.dismissDuration = TRACKOPTIONSSPEED
                          let generator =  UIImpactFeedbackGenerator(style: .heavy)

                       generator.impactOccurred()
          self.present(popupNavController, animated: true, completion: nil)
    }
    
    func coverArtShadow(){
        albumArtImageView.layer.shadowColor = UIColor(red: 109/255, green: 38/255, blue: 185/255, alpha: 1).cgColor
         albumArtImageView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
         albumArtImageView.layer.shadowRadius = 10.0
         albumArtImageView.layer.shadowOpacity = 0.6
        albumArtImageView.layer.masksToBounds = false
        albumArtImageView.layer.shadowPath = UIBezierPath(roundedRect: albumArtImageView.bounds, cornerRadius:  albumArtImageView.layer.cornerRadius).cgPath
    }
    
    public func updateTimeValue(){
        trackSlider.maximumValue = Float(self.controller.player.duration)
        trackSlider.setValue(Float(self.controller.player.currentTime), animated: true)
    }
    
    func handleAudioPlayerSecondElapsed(data: AudioPlayer.SecondElapseEventData) {
        if !isScrubbing {
            DispatchQueue.main.async {
            
                self.updateSliderTimeValue()
            }
        }
    }
    
    func handleAudioPlayerDidSeek(data: AudioPlayer.SeekEventData) {
        isScrubbing = false
    }
    
    func handleAudioPlayerUpdateDuration(data: AudioPlayer.UpdateDurationEventData) {
        DispatchQueue.main.async {
            self.updateSliderTimeValue()
        }
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
    
    public func updateSliderTimeValue(){
           trackSlider.maximumValue = Float(self.controller.player.duration)
           trackSlider.setValue(Float(self.controller.player.currentTime), animated: true)
       }
    
     private var isScrubbing: Bool = false

        override func viewDidLoad() {
            super.viewDidLoad()
              trackSlider.setValue(Float(self.controller.player.currentTime), animated: true)
            trackLocation.text = "\(track?.city ?? ""), \(track?.state ?? "")"
            trackStreams.text = "\(track?.streamCount ?? 0) STREAMS"
            print("URL: \(track?.imageUrl)")
            currentSource = controller.currentSource
            songNameLabel.text = songTitle
            albumNameLabel.text = albumTitle
            albumArtImageView.image = albumArt
            
           let shadowColor = UIColor.darkGray
                     albumArtImageView.layer.borderWidth = 1
                      albumArtImageView.layer.borderColor = shadowColor.cgColor
            
            self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
           albumNameLabel.textColor = LIMELIGHTPURPLE
            if #available(iOS 13.0, *) {
                //albumArtImageView.layer.cornerCurve = .continuous
            }
            //albumArtImageView.layer.cornerRadius = 16
               self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(MusicPlayerViewController._timerTicked(_:)), userInfo: nil, repeats: true)
            
           
        }

        @objc func _timerTicked(_ timer: Timer) {
             let currentProgress = controller.player.currentTime / controller.player.duration
                   
                   if !currentProgress.isNaN{
                   //print("\(currentProgress)%")
                     
                       //self.updateTimeValues()
                       
                   popupItem.progress = Float(currentProgress)// += 0.0002;
                  
                 
                 //  print(controller.player.currentTime)
                   popupItem.accessibilityProgressLabel = NSLocalizedString("Playback Progress", comment: "")
                   
                   let totalTime = TimeInterval(Float(controller.player.duration))
                  //  print(totalTime)
                   popupItem.accessibilityProgressValue = "\(accessibilityDateComponentsFormatter.string(from: TimeInterval(popupItem.progress) * totalTime)!) \(NSLocalizedString("of", comment: "")) \(accessibilityDateComponentsFormatter.string(from: totalTime)!)"
                   
                   //progressView.progress = popupItem.progress
                   
                   if popupItem.progress >= 1.0 {
                       timer.invalidate()
                       popupItem.progress = 0
                      // popupPresentationContainer?.dismissPopupBar(animated: true, completion: nil)
                   }
            }
                   
    }
}
