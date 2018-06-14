//
//  VenueViewController.swift
//  Immedia Places
//
//  Created by Alexander on 2018/06/13.
//  Copyright © 2018 Alexander Hsiao. All rights reserved.
//

import UIKit
import Kingfisher
import FoursquareAPIClient
import ChameleonFramework
import SwiftyJSON

class VenueViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueAddressLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textView: UITextView!
    
    
    //MARK: - Properties
    var venueTitle: String = ""
    var venueAddress: String?
    var venue: Venue?
    
    //Foursquare Credentials
    let client = FoursquareAPIClient(clientId: "5XO1ASTKSJ0ETUBVEG3THP0F42JIBV2WNJ3RDWC3GWOPLMUR", clientSecret: "LKTYVS3LQLHDXXOPJNHVCWITAP4FEKGS211AY5KG1SC3H1H4")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let venue = self.venue else { fatalError("Venue class did not get passed") }
        
        venueNameLabel.text = venue.title
        venueAddressLabel.text = venue.subtitle ?? ""
        textView.text = "Loading tips for venue..."
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setMainImage()
        getPhotoVenueMetaData()
    }
    
    func setMainImage() {
        if let imageString = venue!.photos?.first {
            let url = URL(string: imageString.url)
            bgImageView.kf.indicatorType = .activity
            bgImageView.kf.setImage(with: url)
        }
        
        collectionView.backgroundColor = UIColor.flatPlumDark.darken(byPercentage: 0.08)
    }
    
    func getPhotoVenueMetaData() {
        guard let venueId = venue?.venueID else { fatalError() }
        client.request(path: "venues/\(venueId)/tips", parameter: [:]) { (result) in
            
            switch result {
            case let .success(data):
                do {
                    let json = try JSON(data: data)
                    DispatchQueue.main.async {
                        self.textView.text = json["response"]["tips"]["text"].string ?? self.displayTextViewErrorText()
                    }
                } catch {
                    print("Error parsing JSON")
                    DispatchQueue.main.async {
                        self.textView.text = self.displayTextViewErrorText()
                    }
                }
                
            case let .failure(error):
                switch error {
                case let .connectionError(connectionError):
                    print(connectionError)
                case let .apiError(apiError):
                    print(apiError.errorType)
                    print(apiError.errorDetail)
                default:
                    print("Error occured fetching venues, please try again later")
                }
            }
        }
    }
    
    func displayTextViewErrorText() -> String {
        return "No tips are available for this venue"
    }
}

extension VenueViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return venue?.photos?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageGalleryCVCell
        
        if let imageString = venue!.photos?[indexPath.row] {
            let url = URL(string: imageString.url)
            cell.imageView.kf.indicatorType = .activity
            cell.imageView.kf.setImage(with: url)
            
            cell.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomImage(_:))))
        }
        
        return cell
    }
    
    
    
    @objc func zoomImage(_ sender: UITapGestureRecognizer) {
        let sender = sender.view as! UIImageView
        let newImageView = UIImageView(image: sender.image)
        newImageView.frame = CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2, width: 0, height: 0)
        newImageView.backgroundColor = UIColor.black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let dismissView = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage(_:)))
        newImageView.addGestureRecognizer(dismissView)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true

        UIView.animate(withDuration: 0.5) {
            newImageView.frame = UIScreen.main.bounds
        }
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
    
        UIView.animate(withDuration: 0.5, animations: {
            imageView.frame = CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2, width: 0, height: 0)
            self.navigationController?.isNavigationBarHidden = false
        }) { (bool) in
            imageView.removeFromSuperview()
        }
    }
}





