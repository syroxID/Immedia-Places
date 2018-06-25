//
//  FullscreenImage.swift
//  Immedia Places
//
//  Created by Alexander on 2018/06/14.
//  Copyright © 2018 Alexander Hsiao. All rights reserved.
//

import UIKit

//Not best practice to have UIView as a delegate, best would be to contain a VC

class FullscreenImage: UIView, UIScrollViewDelegate {
    //MARK: - Properties
    var imageViewHeight: NSLayoutConstraint?
    var imageViewWidth: NSLayoutConstraint?
    var verticalStackHeight: NSLayoutConstraint?
    
    //MARK: - View Elements
    let scrollview = UIScrollView()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
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
        scrollview.delegate = self
        
        scrollview.minimumZoomScale = 1.0
        scrollview.maximumZoomScale = 10.0
        scrollview.zoomScale = 1.0
        
        self.backgroundColor = UIColor.black
        self.isUserInteractionEnabled = true
        
        addSubview(scrollview)
        scrollview.addSubview(imageView)
        
        scrollview.anchorStraightToAnchors(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor)
        scrollview.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        addVerticalStack()
        
        imageView.anchorStraightToAnchors(top: scrollview.topAnchor, left: nil, right: nil, bottom: verticalStack.topAnchor)
        imageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1.64).isActive = true
        imageView.widthAnchor.constraint(equalTo: scrollview.widthAnchor).isActive = true
    }
    
    func addVerticalStack() {
        scrollview.addSubview(verticalStack)
        verticalStack.addArrangedSubview(name)
        verticalStack.addArrangedSubview(url)
        verticalStack.addArrangedSubview(createdAt)
        verticalStack.anchorStraightToAnchors(top: nil, left: scrollview.leftAnchor, right: scrollview.rightAnchor, bottom: scrollview.bottomAnchor)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        verticalStack.removeFromSuperview()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale == 1.0 {
            scrollView.addSubview(verticalStack)
            verticalStack.anchorStraightToAnchors(top: imageView.bottomAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, bottom: scrollView.bottomAnchor)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
