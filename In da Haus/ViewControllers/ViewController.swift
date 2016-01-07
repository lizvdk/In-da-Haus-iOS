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
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
        initMap()

        self.locationManager.startMonitoringForRegion(CLCircularRegion(center: CLLocationCoordinate2DMake(42.3673379, -71.0809888), radius: 100, identifier: "Intrepid"))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .AuthorizedAlways)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError: \(error.description)")
        let alertController = UIAlertController(title: "Error", message: "We could not determine your location.", preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
        }
        
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true) {
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updating")
    }
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered")
        sendMessageToSlack()
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("Monitoring")
        print(region)
    }
     func locationManager(manager: CLLocationManager,
        monitoringDidFailForRegion region: CLRegion?,
        withError error: NSError) {
            print("Something went wrong")
    }
    
    func sendMessageToSlack() {
        let parameters = [
            "text": "Liz is at The Mothership!",
        ]
        
        Alamofire.request(.POST, "https://hooks.slack.com/services/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", parameters: parameters, encoding: .JSON)
    }

}

