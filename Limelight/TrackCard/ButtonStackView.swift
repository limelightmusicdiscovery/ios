//
//  ButtonStackView.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-10-19.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//


import PopBounceButton

protocol ButtonStackViewDelegate {
    func didTapButton(button: TinderButton)
}

class ButtonStackView: UIStackView {
    var delegate: ButtonStackViewDelegate?
    
    private let undoButton: TinderButton = {
        let button = TinderButton()
        button.setImage(UIImage(named: "undo"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 5
        return button
    }()
    
    private let passButton: TinderButton = {
        let button = TinderButton()
        button.setImage(UIImage(named: "thumbsDown"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 2
        button.backgroundColor =  UIColor(red: 31/255, green: 33/255, blue: 36/255, alpha: 1.0)
        button.layer.masksToBounds = true
        return button
    }()
    
    private let addToLibraryButton: TinderButton = {
        let button = TinderButton()
        button.setImage(UIImage(named: "smallLibrary"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 3
        return button
    }()
    
    private let likeButton: TinderButton = {
        let button = TinderButton()
        button.setImage(UIImage(named: "thumbsUp"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 4
        button.backgroundColor =  UIColor(red: 31/255, green: 33/255, blue: 36/255, alpha: 1.0)
         button.layer.masksToBounds = true
        
        
           
        
        
        return button
    }()
    
    private let previousButton: TinderButton = {
        let button = TinderButton()
        button.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        button.setImage(UIImage(named: "previousCard"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 1
       
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        distribution = .equalSpacing
        alignment = .center
        configure()
    }
    
    private func configure() {
        let largeMultiplier: CGFloat = 100/414 //based on width of iPhone 8+
        let smallMultiplier: CGFloat = 54/414 //based on width of iPhone 8+
        let midMultiplier: CGFloat = 60/414
        addArrangedSubview(from: addToLibraryButton, diameterMultiplier: midMultiplier)
       
        addArrangedSubview(from: passButton, diameterMultiplier: largeMultiplier)
         addArrangedSubview(from: likeButton, diameterMultiplier: largeMultiplier)
         addArrangedSubview(from: previousButton, diameterMultiplier: midMultiplier)
       
       // addArrangedSubview(from: boostButton, diameterMultiplier: smallMultiplier)
    }
    
    private func addArrangedSubview(from button: TinderButton, diameterMultiplier: CGFloat) {
        let container = ButtonContainer()
        container.addSubview(button)
        button.anchorToSuperview()
        addArrangedSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: diameterMultiplier).isActive = true
        container.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
    }
    
    
    
    @objc private func handleTap(_ button: TinderButton) {
        delegate?.didTapButton(button: button)
        
       
    }
}

fileprivate class ButtonContainer: UIView {
    override func draw(_ rect: CGRect) {
        applyShadow(radius: 0.2 * bounds.width, opacity: 0.05, offset: CGSize(width: 0, height: 0.15 * bounds.width))
    }
}

