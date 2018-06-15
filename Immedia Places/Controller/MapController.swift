//
//  MapController.swift
//  Immedia Places
//
//  Created by Alexander on 2018/06/13.
//  Copyright © 2018 Alexander Hsiao. All rights reserved.
//

import UIKit
import MapKit
import FoursquareAPIClient
import SwiftyJSON
import ChameleonFramework

class MapController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //Foursquare Credentials and Default Parameters
    let client = FoursquareAPIClient(clientId: "5XO1ASTKSJ0ETUBVEG3THP0F42JIBV2WNJ3RDWC3GWOPLMUR", clientSecret: "LKTYVS3LQLHDXXOPJNHVCWITAP4FEKGS211AY5KG1SC3H1H4")
    var limit: Int = 5
    var radius: Int = 100000
    
    //MARK: - Properties
    private let appTitle = "What's around me?"
    var venues = [Venue]()
    var selectedVenueIndex: Int?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = appTitle
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        
        checkLocationServiceAuthentication()
        
        navigationController?.navigationBar.barTintColor = UIColor.flatPlumDark.darken(byPercentage: 0.1)
        navigationController?.navigationBar.tintColor = ContrastColorOf(UIColor.flatPlum, returnFlat: true)
        
    }
    
    private let regionRadius: CLLocationDistance = 1000
    
    func zoomMapTo(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func getVenues(aroundLocation location: CLLocation) {
        let parameters: [String: String] = [
            "ll": "\(location.coordinate.latitude), \(location.coordinate.longitude)",
            "limit": "\(self.limit)",
            "radius": "\(self.radius)"]
        
        client.request(path: "venues/search", parameter: parameters) { [weak self] result in
            
            switch result {
            case let .success(data):
                let json = try? JSON(data: data)
                self?.createVenuesArray(fromData: json)
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
    
    func getVenueImageUrls(venueID: String, completion: @escaping ([VenuePhotos]) -> ()) {
        var photosArray = [VenuePhotos]()
        let path = "venues/\(venueID)/photos"
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        client.request(path: path, parameter: [:]) { [weak self] result in
            switch result {
            case let .success(data):
                if let json = try? JSON(data: data) {
                    if let items = json["response"]["photos"]["items"].array {
                        for each in items {
                            let photoUrl = "\(each["prefix"])1024x1024\(each["suffix"])"
                            let createdAt = each["createdAt"].int
                            let sourceName = each["source"]["name"].string
                            let sourceUrl = each["source"]["url"].string
                            let newPhoto = VenuePhotos(url: photoUrl, createdAt: createdAt ?? 0, sourceName: sourceName, sourceUrl: sourceUrl)
                            photosArray.append(newPhoto)
                        }
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
                    print("Error occured fetching image urls")
                }
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(photosArray)
        }
    }
    
    func createVenuesArray(fromData data: JSON?) {
        guard let json = data else { fatalError("Data did not pull through") }
        let dispatchGroup = DispatchGroup()
        
        if let jsonVenues = json["response"]["venues"].array {
            
            for venue in jsonVenues {
                dispatchGroup.enter()
                getVenueImageUrls(venueID: venue["id"].string!) { (array) in
                    DispatchQueue.main.async {
                        if let newVenue = Venue.from(json: venue, photoUrls: array) {
                            self.venues.append(newVenue)
                        } else {
                            print("problem")
                        }
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.mapView.addAnnotations(self.venues)
        }
    }
    
    //MARK: - Current Location
    var locationManager = CLLocationManager()
    var didFindLocation: Bool = false
    
    func checkLocationServiceAuthentication() {
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func currentLocationPressed(_ sender: UIButton) {
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    //MARK: - Filter View
    lazy var slideFilter: FilterView = {
        let sf = FilterView()
        sf.delegate = self
//        sf.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissFilterView)))
        return sf
    }()
    
    @IBAction func filterPressed(_ sender: UIBarButtonItem) {
        view.addSubview(slideFilter)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.slideFilter.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func dismissFilterView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.slideFilter.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.view.layoutIfNeeded()
//            self.slideFilter.removeFromSuperview()
        }, completion: {(bool) in
            self.slideFilter.removeFromSuperview()
        })
    }
}

extension MapController: returnSelectionsDelegate {
    func passDataToController(radius: Int, venues: Int) {
        self.limit = venues
        self.radius = radius
        self.didFindLocation = false
        self.dismissFilterView()
        self.mapView.removeAnnotations(self.venues)
        self.venues.removeAll()
        checkLocationServiceAuthentication()
    }
    
    func dismissView() {
         self.dismissFilterView()
    }
}

extension MapController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        if didFindLocation == false {
            self.mapView.showsUserLocation = true
            zoomMapTo(location: location)
            getVenues(aroundLocation: location)
            didFindLocation = true
            locationManager.stopUpdatingLocation()
        }
    }
}

extension MapController: MKMapViewDelegate {
    //Would like to add image to the pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Venue {
            let identifier = "pin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                view = dequeuedView
//                view.image = UIImage(named: "chat")
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
//                view.image = UIImage(named: "chat")
            }
            view.animatesDrop = true
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { fatalError() }
        navigationItem.title = annotation.title!
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        navigationItem.title = appTitle
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        selectedVenueIndex = venues.index(where: {($0.coordinate.latitude == view.annotation?.coordinate.latitude) && ($0.coordinate.longitude == view.annotation?.coordinate.longitude)})
        
            performSegue(withIdentifier: "goToVenueDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToVenueDetail" {
            let destinationVC = segue.destination as! VenueViewController
            if let index = selectedVenueIndex {
                destinationVC.venue = venues[index]
            } else {
                fatalError("Venue could not be found")
            }
        }
    }
    
}











