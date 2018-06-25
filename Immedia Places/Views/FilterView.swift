//
//  FilterView.swift
//  Immedia Places
//
//  Created by Alexander on 2018/06/15.
//  Copyright © 2018 Alexander Hsiao. All rights reserved.
//

import UIKit

protocol returnSelectionsDelegate {
    func passDataToController(radius: Int, venues: Int)
    func dismissView()
}

class FilterView: UIView {
    //MARK: - Properties
    var delegate: returnSelectionsDelegate?
    let buttonHeightMultiplier: CGFloat = 0.08
    let leadingTrailingSpace: CGFloat = 16
    let cornerRadius: CGFloat = 10
    
    //MARK: - View Elements
    lazy var cancelBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Cancel", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        b.backgroundColor = .white
        return b
    }()
    
    let applyBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Apply Filter", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        b.backgroundColor = .white
        return b
    }()
    
    let elementWindow: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let verticalStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.alignment = .fill
        return sv
    }()
    
    let radiusLabel: UILabel = {
        let l = UILabel()
        l.text = "Adjust Radius (meters): Default"
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor.darkGray
        return l
    }()
    
    lazy var radiusSlider: UISlider = {
        let s = UISlider()
        s.minimumValue = 0
        s.maximumValue = 100000
        s.value = 100000
        s.tag = 1
        s.tintColor = UIColor.flatPlumDark
        s.addTarget(self, action: #selector(updateLabel(_:)), for: .valueChanged)
        return s
    }()
    
    let numberOfVenuesLabel: UILabel = {
        let l = UILabel()
        l.text = "How many Venues: Default"
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor.darkGray
        return l
    }()
    
    lazy var numberOfVenuesSlider: UISlider = {
        let s = UISlider()
        s.minimumValue = 0
        s.maximumValue = 50
        s.value = 5
        s.tag = 2
        s.tintColor = UIColor.flatPlumDark
        s.addTarget(self, action: #selector(updateLabel(_:)), for: .valueChanged)
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0, alpha: 0.8)
        
//        setupWindow()
    }
    
    override func layoutSubviews() {
        setupWindow()
    }
    
    func setupWindow() {
        addSubview(cancelBtn)
        addSubview(applyBtn)
        addSubview(elementWindow)
        elementWindow.addSubview(verticalStack)
        verticalStack.addArrangedSubview(radiusLabel)
        verticalStack.addArrangedSubview(radiusSlider)
        verticalStack.addArrangedSubview(numberOfVenuesLabel)
        verticalStack.addArrangedSubview(numberOfVenuesSlider)
        
        cancelBtn.anchorWithConstantsToTop(top: nil, left: nil, right: nil, bottom: bottomAnchor, topConstant: 0, leftConstant: 0, rightConstant: 0, bottomConstant: -74)
        cancelBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cancelBtn.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - (leadingTrailingSpace * 2.0)).isActive = true
        cancelBtn.heightAnchor.constraint(equalTo: heightAnchor, multiplier: buttonHeightMultiplier).isActive = true
        
        applyBtn.anchorWithConstantsToTop(top: nil, left: leftAnchor, right: rightAnchor, bottom: cancelBtn.topAnchor, topConstant: 0, leftConstant: leadingTrailingSpace, rightConstant: -(leadingTrailingSpace), bottomConstant: -6)
        applyBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        applyBtn.widthAnchor.constraint(equalToConstant: self.frame.width - (leadingTrailingSpace * 2.0)).isActive = true
        applyBtn.heightAnchor.constraint(equalTo: heightAnchor, multiplier: buttonHeightMultiplier).isActive = true

        elementWindow.anchorWithConstantsToTop(top: nil, left: nil, right: nil, bottom: applyBtn.topAnchor, topConstant: 0, leftConstant: 0, rightConstant: 0, bottomConstant: -12)
        elementWindow.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        elementWindow.widthAnchor.constraint(equalToConstant: self.frame.width - (leadingTrailingSpace * 2.0)).isActive = true
        elementWindow.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true

        verticalStack.anchorWithConstantsToTop(top: elementWindow.topAnchor, left: elementWindow.leftAnchor, right: elementWindow.rightAnchor, bottom: nil, topConstant: 0, leftConstant: 12, rightConstant: -12, bottomConstant: 0)
        verticalStack.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.3).isActive = true

        elementWindow.layer.cornerRadius = self.cornerRadius
        cancelBtn.addTarget(self, action: #selector(dismissBtnPressed), for: .touchUpInside)
        applyBtn.addTarget(self, action: #selector(applyBtnPressed), for: .touchUpInside)
    }
    
    @objc func applyBtnPressed() {
        if let delegate = self.delegate {
            delegate.passDataToController(radius: Int(radiusSlider.value), venues: Int(numberOfVenuesSlider.value))
        }
    }
    
    @objc func dismissBtnPressed() {
        if let delegate = self.delegate {
            delegate.dismissView()
        }
    }
    
    @objc func updateLabel(_ sender: UISlider) {
        if sender.tag == 1 {
            radiusLabel.text = "Adjust Radius (meters): \(Int(sender.value))"
        } else if sender.tag == 2 {
            numberOfVenuesLabel.text = "How many Venues: \(Int(sender.value))"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
