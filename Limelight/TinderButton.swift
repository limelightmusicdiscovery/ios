//
//  TinderButton.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-10-19.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import PopBounceButton

class TinderButton: PopBounceButton {
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
        backgroundColor = .white
        layer.masksToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = frame.width / 2
    }
}
