//
//  ViewController.swift
//  In da Haus
//
//  Created by Liz Vanderkloot on 1/7/16.
//  Copyright © 2016 lizvdk. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
	
	// MARK: Properties
	
	var locationManager = CLLocationManager()
	
	let intrepidMothershipCoordinates = (latitude: 42.3673379, longitude: -71.0809888)
	let intrepidRogersCoordinates = (latitude: 42.366471, longitude: -71.078118)
	let monitoringRadius = 50.0
	
	@IBOutlet weak var mapView: MKMapView!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initLocationTracking()
		initRegionMonitoring()
		initMap()
		
	}
	
	// MARK: Map
	
	func initMap() {
		let initialLocation = CLLocation(latitude: 42.3673379, longitude: -71.0809888)
		let regionRadius: CLLocationDistance = 500
		func centerMapOnLocation(location: CLLocation) {
			let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
				regionRadius * 2.0, regionRadius * 2.0)
			mapView.setRegion(coordinateRegion, animated: true)
		}
		centerMapOnLocation(initialLocation)
	}
	
	// MARK: Location Tracking
	
	func initLocationTracking() {
		self.locationManager.delegate = self
		self.locationManager.requestAlwaysAuthorization()
		self.locationManager.distanceFilter = kCLDistanceFilterNone
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.startUpdatingLocation()
	}
	
	func initRegionMonitoring() {
		self.locationManager.startMonitoringForRegion(CLCircularRegion(center: CLLocationCoordinate2DMake(intrepidMothershipCoordinates.latitude, intrepidMothershipCoordinates.longitude), radius: monitoringRadius, identifier: "The Mothership"))
		self.locationManager.startMonitoringForRegion(CLCircularRegion(center: CLLocationCoordinate2DMake(intrepidRogersCoordinates.latitude, intrepidRogersCoordinates.longitude), radius: monitoringRadius, identifier: "Rogers"))
	}
	
	// MARK: CLLocationManagerDelegate
	
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		mapView.showsUserLocation = (status == .AuthorizedAlways)
	}
	
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		print("didFailWithError: \(error.description)")
		
		let alertController = UIAlertController(title: "Error", message: "We could not determine your location.", preferredStyle: .Alert)
		let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
		}
		alertController.addAction(okAction)
		
		self.presentViewController(alertController, animated: true) {
		}
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
	}
	
	func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
		print("Entered \(region.identifier)")
		alertOfficeEntered(region.identifier)

	}
	
	func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
		print("Monitoring \(region.identifier)")
	}
	
	func locationManager(manager: CLLocationManager,
		monitoringDidFailForRegion region: CLRegion?,
		withError error: NSError) {
			print("Something went wrong")
	}
	
	// MARK: Office Entered Alert
	
	func alertOfficeEntered(office: String) {
		let alertController = UIAlertController(title: "Entered \(office)", message: "Tell Slack?", preferredStyle: .Alert)
		let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
			self.sendMessageToSlack(office)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
		}
		alertController.addAction(okAction)
		alertController.addAction(cancelAction)
		
		self.presentViewController(alertController, animated: true) {
		}
	}
	
	// MARK: Slack
	
	func sendMessageToSlack(office: String) {
		let parameters = [
			"text": "Liz is at \(office)!",
		]
		
		Alamofire.request(.POST, "https://hooks.slack.com/services/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", parameters: parameters, encoding: .JSON)
			.responseString { response in
				if response.result.isFailure {
					print("To do: alert slack error")
				}
		}
	}
	
}

