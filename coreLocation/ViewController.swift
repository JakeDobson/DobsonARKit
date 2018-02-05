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
import ARCL

class ViewController: UIViewController, CLLocationManagerDelegate {
	//globals
	var place :String!
	var sceneLocationView = SceneLocationView()
	lazy private var locationManager = CLLocationManager()
	//life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		sceneLocationView.run()
		self.view.addSubview(sceneLocationView)
		
		self.title = self.place
		
		self.locationManager.delegate = self
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.startUpdatingLocation()
		
		findLocalPlaces()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		sceneLocationView.frame = self.view.bounds
	}
	//helpers
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
				let placeLocation = (item.placemark.location)!
				let placeAnnotationNode = PlaceAnnotation(location: placeLocation, title: item.placemark.name!)
				
				DispatchQueue.main.async {
					self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: placeAnnotationNode)
				}
			}
		}
	}
}
