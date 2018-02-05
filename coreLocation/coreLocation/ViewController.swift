//
//  ViewController.swift
//  coreLocation
//
//  Created by Josh Dobson on 2/2/18.
//  Copyright © 2018 Josh Dobson. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var place :String!
    
    lazy private var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = self.place
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        findLocalPlaces()
        
        //print(self.locationManager.location?.coordinate)
    }
    
    private func findLocalPlaces() {
        guard let location = self.locationManager.location else {
            return
        }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = place
        
        var region = MKCoordinateRegion()
        region.center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            
            if error != nil {
                return
            }
            
            guard let response = response else {
                return
            }
            
            for item in response.mapItems {
                print(item.placemark)
                
                let placeLocation = (item.placemark.location)!
                
            }
        }
        
    }
    

}

