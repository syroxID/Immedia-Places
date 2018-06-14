//
//  FullscreenImage.swift
//  Immedia Places
//
//  Created by Alexander on 2018/06/14.
//  Copyright © 2018 Alexander Hsiao. All rights reserved.
//

import UIKit

class FullscreenImage: UIView {
    //MARK: - Properties
    var verticalStackHeight: NSLayoutConstraint?
    
    //MARK: - View Elements
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let verticalStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.alignment = .fill
        sv.spacing = 0
        sv.backgroundColor = UIColor.red
        return sv
    }()
    
    let name: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let url: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let createdAt: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.italicSystemFont(ofSize: 13)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    init(frame: CGRect, image: UIImage?) {
        super.init(frame: frame)
        self.imageView.image = image
        
        self.backgroundColor = UIColor.black
        self.isUserInteractionEnabled = true
        
        addSubview(imageView)
        addSubview(verticalStack)
        verticalStack.addArrangedSubview(name)
        verticalStack.addArrangedSubview(url)
        verticalStack.addArrangedSubview(createdAt)
        
        verticalStack.anchorStraightToAnchors(top: nil, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor)
        verticalStackHeight = verticalStack.heightAnchor.constraint(equalToConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
