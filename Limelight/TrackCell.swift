//
//  TrackCell.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-11-09.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import SDWebImage


class TrackCell : UITableViewCell {
    
    var track : Track? {
        didSet {
            trackImage.sd_setImage(with: URL(string: track?.imageUrl ?? "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/eb777e7a-7d3c-487e-865a-fc83920564a1/d7kpm65-437b2b46-06cd-4a86-9041-cc8c3737c6f0.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2ViNzc3ZTdhLTdkM2MtNDg3ZS04NjVhLWZjODM5MjA1NjRhMVwvZDdrcG02NS00MzdiMmI0Ni0wNmNkLTRhODYtOTA0MS1jYzhjMzczN2M2ZjAuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.-bP80wHw6Jb8moQRsxURQxONZvAMnJ6xLDD8Es7mHps"), placeholderImage: UIImage(named: "coverDefaultImage"),options: [ .scaleDownLargeImages], completed: { (image, error, cacheType, imageURL) in
           
            })
            
           // let shadowColor = UIColor.darkGray
            //self.trackImage.layer.borderWidth = 1
           // self.trackImage.layer.borderColor = shadowColor.cgColor
                
            trackNameLabel.text = track?.title
            trackArtistLabel.text = track?.artistUsername
            trackDetailsLabel.text =  "\(track?.streamCount ?? 0) streams"
        }
    }
    
    
    private let trackNameLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont(name: "Poppins", size: 16)
        lbl.textAlignment = .left
        return lbl
    }()
    
    private let trackDetailsLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .lightGray
         lbl.font = UIFont(name: "Poppins", size: 10)
        lbl.textAlignment = .left
        return lbl
    }()
    
    
    public let trackArtistLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(red: 118/255, green: 82/255, blue: 156/255, alpha: 1)
        lbl.font = UIFont(name: "Poppins", size: 15)  
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    /* public let trackArtistLabel : UIButton = {
           let btn = UIButton()
         
           btn.setTitleColor(UIColor(red: 118/255, green: 82/255, blue: 156/255, alpha: 1), for: .normal)
           btn.titleLabel?.font = UIFont(name: "Poppins", size: 15)
           btn.contentHorizontalAlignment = .left
           btn.contentVerticalAlignment = UIControl.ContentVerticalAlignment.top
           btn.titleLabel?.numberOfLines = 0
           return btn
       }()*/
    private let decreaseButton : UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "pass"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFill
        return btn
    }()
    
    private let increaseButton : UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "trackInfo"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    var productQuantity : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = "1"
        label.textColor = .white
        return label
        
    }()
    
    private let trackImage : UIImageView = {
        let imgView = UIImageView(image: #imageLiteral(resourceName: "limelightGreenBarsShadow"))
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius =  2
       
        imgView.clipsToBounds = true
        return imgView
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(trackImage)
        addSubview(trackNameLabel)
        addSubview(trackArtistLabel)
        addSubview(trackDetailsLabel)
        self.backgroundColor = .clear //UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
       // addSubview(decreaseButton)
       // addSubview(productQuantity)
        //ddSubview(increaseButton)
        
        
        trackImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 50, height: 0, enableInsets: false)
        trackNameLabel.anchor(top: topAnchor, left: trackImage.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 5, width: frame.size.width / 2, height: 0, enableInsets: false)
        trackArtistLabel.anchor(top: trackNameLabel.bottomAnchor, left: trackImage.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width:trackArtistLabel.sizeThatFits(trackArtistLabel.frame.size).width, height: 0, enableInsets: false)
        trackDetailsLabel.anchor(top: trackArtistLabel.bottomAnchor, left: trackImage.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width / 2, height: 0, enableInsets: false)
        
        
        let stackView = UIStackView(arrangedSubviews: [decreaseButton,productQuantity,increaseButton])
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.spacing = 5
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: trackNameLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 15, paddingLeft: 5, paddingBottom: 15, paddingRight: 10, width: 0, height: 40, enableInsets: false)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
