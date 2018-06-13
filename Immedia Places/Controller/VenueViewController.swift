//
//  VenueViewController.swift
//  Immedia Places
//
//  Created by Alexander on 2018/06/13.
//  Copyright © 2018 Alexander Hsiao. All rights reserved.
//

import UIKit

class VenueViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueAddressLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties
    var venueTitle: String = ""
    var venueAddress: String?
    var venue: Venue? {
        didSet {
            getImages()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let venue = self.venue else { fatalError("Venue class did not get passed") }
        
        venueNameLabel.text = venue.title
        venueAddressLabel.text = venue.subtitle ?? ""
    }
    
    func getImages() {
        
    }
}






