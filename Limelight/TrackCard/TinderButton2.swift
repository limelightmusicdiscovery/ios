//
//  TinderButton2.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-11-29.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import PopBounceButton

class TinderButton2: PopBounceButton {
    override init() {
        super.init()
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        adjustsImageWhenHighlighted = false
        backgroundColor =  UIColor(red: 31/255, green: 33/255, blue: 36/255, alpha: 1.0)//.white
        layer.masksToBounds = true
       
              //self.layer.borderWidth = 2
      //  self.layer.borderColor = UIColor.lightGray.cgColor //UIColor(red: 109/255, green: 38/255, blue: 185/255, alpha: 1).cgColor
        
      
    }
    
    func limelightGradient(){
        let gradient = CAGradientLayer()
                          gradient.frame =  CGRect(origin: CGPoint.zero, size: self.frame.size)
                          
                          gradient.startPoint = CGPoint(x:0.0, y:0.5)
                          gradient.endPoint = CGPoint(x:1.0, y:0.5)
                          
                          gradient.colors = [UIColor(red: 109/255, green: 38/255, blue: 185/255, alpha: 1).cgColor, UIColor(red: 219/255, green: 75/255, blue: 156/255, alpha: 1).cgColor,UIColor(red: 66/255, green: 209/255, blue: 245/255, alpha: 1).cgColor]
                          self.layer.cornerRadius = self.frame.height/2

                          let shape = CAShapeLayer()
                          shape.lineWidth = 4
                          shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.frame.height/2).cgPath
                          shape.strokeColor = UIColor.black.cgColor
                          shape.fillColor = UIColor.clear.cgColor
                          
                          gradient.mask = shape
                          

                          self.layer.addSublayer(gradient)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

       
        layer.cornerRadius = frame.width / 2
    }
}
