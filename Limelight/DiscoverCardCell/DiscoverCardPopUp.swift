//
//  DiscoverCardPopUp.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-27.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import SwiftMessages
import SDWebImage
class DiscoverCardPopUp:  MessageView {
    
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
    @IBOutlet weak var soundcloudIcon: UIImageView!
    @IBOutlet weak var spotifyIcon: UIImageView!
    @IBOutlet weak var itunesIcon: UIImageView!
    @IBOutlet weak var userProfileIcon: UIImageView!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var backgroundCardsView: UIView!

  fileprivate static var tacoTitles = [
        1 : "Just one, Please",
        2 : "Make it two!",
        3 : "Three!!!",
        4 : "Cuatro!!!!",
    ]

    var getTacosAction: ((_ count: Int) -> Void)?
    var cancelAction: (() -> Void)?
    
    fileprivate var count = 1 {
        didSet {
            iconLabel?.text = String(repeating: "🌮", count: count)//String(count: count, repeatedValue: )
            bodyLabel?.text = DiscoverCardPopUp.tacoTitles[count] ?? "\(count)" + String(repeating: "!", count: count)
        }
    }
    
    @IBAction func getTacos() {
        //getTacosAction?(Int(tacoSlider.value))
    }

    @IBAction func cancel() {
        cancelAction?()
    }
    
    @IBOutlet weak var tacoSlider: UISlider!
    
    @IBAction func tacoSliderSlid(_ slider: UISlider) {
        count = Int(slider.value)
    }
    
    @IBAction func tacoSliderFinished(_ slider: UISlider) {
        slider.setValue(Float(count), animated: true)
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
