//
//  Helper.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-11-28.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import Foundation
import UIKit

struct GeoFireUser {
 
    var latitude = 0.0
    var longitude = 0.0
    var uid = ""
    var name = ""
    var alias = ""
   
   
    
    init(latitude: Double, longitude: Double, uid: String, name: String, alias: String) {
           
        
           self.latitude = latitude
           self.longitude = longitude
           self.uid = uid
        self.name = name
        self.alias = alias
           

           
       }
       
}

class Helper {
   
        
               
        
        
    }


    
    


extension UIViewController {
    func setTitle(_ title: String, andImage image: UIImage) {
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.textColor = UIColor.white
        titleLbl.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        let imageView = UIImageView(image: image)
        let titleView = UIStackView(arrangedSubviews: [imageView, titleLbl])
        titleView.axis = .vertical
        titleView.spacing = 10.0
        navigationItem.titleView = titleView
    }
}

extension UIView {


func fadeIn(withDuration duration: TimeInterval = 0.8) {
    UIView.animate(withDuration: duration, animations: {
        self.alpha = 1.0
    })
}

func fadeOut(withDuration duration: TimeInterval = 0.8) {
    UIView.animate(withDuration: duration, animations: {
        self.alpha = 0.0
    })
}
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
@IBDesignable
class GradientSlider: UISlider {

    @IBInspectable var thickness: CGFloat = 20 {
        didSet {
            setup()
        }
    }

    @IBInspectable var sliderThumbImage: UIImage? {
        didSet {
            setup()
        }
    }

    func setup() {
        let minTrackStartColor = UIColor(red: 109/255, green: 38/255, blue: 185/255, alpha: 1)
        let midTrackColor =  UIColor(red: 219/255, green: 75/255, blue: 156/255, alpha: 1)
        let minTrackEndColor = UIColor(red: 66/255, green: 209/255, blue: 245/255, alpha: 1)
        let maxTrackColor = UIColor(red: 215/255, green: 221/255, blue: 234/255, alpha: 0.35)
        do {
            self.setMinimumTrackImage(try self.gradientImage(
            size: self.trackRect(forBounds: self.bounds).size,
            colorSet: [minTrackStartColor.cgColor,midTrackColor.cgColor, minTrackEndColor.cgColor]),
                                  for: .normal)
            self.setMaximumTrackImage(try self.gradientImage(
            size: self.trackRect(forBounds: self.bounds).size,
            colorSet: [maxTrackColor.cgColor, maxTrackColor.cgColor]),
                                  for: .normal)
            self.setThumbImage(sliderThumbImage, for: .normal)
        } catch {
            self.minimumTrackTintColor = minTrackStartColor
            self.maximumTrackTintColor = maxTrackColor
        }
    }

    func gradientImage(size: CGSize, colorSet: [CGColor]) throws -> UIImage? {
        let tgl = CAGradientLayer()
        tgl.frame = CGRect.init(x:0, y:0, width:size.width, height: size.height)
        //tgl.cornerRadius = tgl.frame.height / 2
        tgl.masksToBounds = false
        tgl.colors = colorSet
        tgl.startPoint = CGPoint.init(x:0.0, y:0.5)
        tgl.endPoint = CGPoint.init(x:1.0, y:0.5)

        UIGraphicsBeginImageContextWithOptions(size, tgl.isOpaque, 0.0);
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        tgl.render(in: context)
        let image =

    UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets:
        UIEdgeInsets.init(top: 0, left: size.height, bottom: 0, right: size.height))
        UIGraphicsEndImageContext()
        return image!
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            x: bounds.origin.x,
            y: bounds.origin.y,
            width: bounds.width,
            height: thickness
        )
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    


}
