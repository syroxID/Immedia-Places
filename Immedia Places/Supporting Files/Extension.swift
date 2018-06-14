//
//  Extension.swift
//  Immedia Places
//
//  Created by Alexander on 2018/06/14.
//  Copyright © 2018 Alexander Hsiao. All rights reserved.
//

import UIKit

extension UIView {
    
    func anchorStraightToAnchors(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil ) {
        
        anchorWithConstantsToTop(top: top, left: left, right: right, bottom: bottom, topConstant: 0, leftConstant: 0, rightConstant: 0, bottomConstant: 0)
    }
    
    func anchorWithConstantsToTop(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, rightConstant: CGFloat = 0, bottomConstant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: leftConstant).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: rightConstant).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: bottomConstant).isActive = true
        }
    }
    
    func addContraintsWithMultiplier(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, width: NSLayoutDimension? = nil, height: NSLayoutDimension? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, rightConstant: CGFloat = 0, bottomConstant: CGFloat = 0, widthMultiplier: CGFloat = 0, heightMultiplier: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: leftConstant).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: rightConstant).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: bottomConstant).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalTo: width, multiplier: widthMultiplier).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalTo: height, multiplier: heightMultiplier).isActive = true
        }
    }
}
