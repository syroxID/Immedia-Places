//
//  Venue.swift
//  Immedia Places
//
//  Created by Alexander on 2018/06/13.
//  Copyright © 2018 Alexander Hsiao. All rights reserved.
//

import MapKit
import SwiftyJSON

class Venue: NSObject, MKAnnotation {
    var title: String?
    var locationName: String?
    var coordinate: CLLocationCoordinate2D
    var venueID: String?
    var photos: [VenuePhotos]?
    
    init(title: String, locationName: String?, coordinate: CLLocationCoordinate2D, venueID: String?, photos: [VenuePhotos]?) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        self.venueID = venueID
        self.photos = photos
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    class func from(json: JSON, photoUrls: [VenuePhotos]) -> Venue? {
        var title: String
        if let jsonTitle = json["name"].string {
            title = jsonTitle
        } else {
            title = ""
        }
        
        let locationName = json["location"]["address"].string
        let lat = json["location"]["lat"].doubleValue
        let long = json["location"]["lng"].doubleValue
        let venueID = json["id"].string
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        return Venue(title: title, locationName: locationName, coordinate: coordinate, venueID: venueID, photos: photoUrls)
    }
}

class VenuePhotos {
    var url: String
    var createdAt: Int
    var sourceName: String?
    var sourceUrl: String?
    
    init(url: String, createdAt: Int, sourceName: String?, sourceUrl: String?) {
        self.url = url
        self.createdAt = createdAt
        self.sourceName = sourceName
        self.sourceUrl = sourceUrl
    }
}









