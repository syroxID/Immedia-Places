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
    let client = FoursquareAPIClient(clientId: "CLIENT_ID", clientSecret: "CLIENT_SECRET")
    
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
        if venue?.photos?.count == 0 {
            return 1
        } else {
            return venue?.photos?.count ?? 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageGalleryCVCell
        
        guard let photoArray = venue!.photos else { fatalError("Photo array not initialized") }
    
        if photoArray.count > 0 {
            let url = URL(string: photoArray[indexPath.row].url)
            cell.imageView.kf.indicatorType = .activity
            cell.imageView.kf.setImage(with: url)
            cell.imageView.tag = indexPath.row
            cell.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomImage(_:))))
        } else {
            cell.imageView.image = UIImage(named: "detail-bg")
            cell.imageView.tag = 9999
            cell.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomImage(_:))))
        }
        
        return cell
    }
    
    @objc func zoomImage(_ sender: UITapGestureRecognizer) {
        let startingFrame = UIScreen.main.bounds
        
        let sender = sender.view as! UIImageView
        let fullscreenView = FullscreenImage(frame: startingFrame, image: sender.image)
        
        let dismissView = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage(_:)))
        fullscreenView.addGestureRecognizer(dismissView)
        
        fullscreenView.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
        self.view.addSubview(fullscreenView)
        
        
        
        if sender.tag == 9999 {
            fullscreenView.name.text = "This is a default image from Pexels"
            fullscreenView.url.text = "https://www.pexels.com"
            fullscreenView.createdAt.text = "Not sure when the picture was taken"
            
        } else {
            fullscreenView.name.text = venue?.photos?[sender.tag].sourceName
            fullscreenView.url.text = venue?.photos?[sender.tag].sourceUrl
            
            let date = Date(timeIntervalSince1970: Double((venue?.photos?[sender.tag].createdAt)!))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MMM-YYYY, mm:hh"
            fullscreenView.createdAt.text = dateFormatter.string(from: date)
        }
        
        
        UIView.animate(withDuration: 0.3, animations: {
            self.navigationController?.isNavigationBarHidden = true
        }) { (bool) in
            UIView.animate(withDuration: 0.5, animations: {
                fullscreenView.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            }) { (bool) in
                //maybe do something further
            }
        }
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        
        let view = sender.view as! FullscreenImage
        
        UIView.animate(withDuration: 0.5, animations: {
            view.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
            self.navigationController?.isNavigationBarHidden = false
        }) { (bool) in
            //Maybe do something
        }
    }
}





