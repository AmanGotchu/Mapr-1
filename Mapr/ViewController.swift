//
//  ViewController.swift
//  Mapr
//
//  Created by tianyi on 9/23/17.
//  Copyright © 2017 tianyi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var gestureRecognizer: UILongPressGestureRecognizer!
    
    @IBOutlet weak var arButton: UIButton!
    @IBOutlet weak var navigateButton: UIButton!
    
    var locationManager: CLLocationManager!
    
    var currentLocation: CLLocation?
    var centered = false
    
    var destination: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up map view
        self.mapView.delegate = self
        mapView.showsUserLocation = true
        
        // Set up location manager
        locationManager = CLLocationManager()
        let authStatus = CLLocationManager.authorizationStatus()
        if (authStatus == .notDetermined) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        // Set up press recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressRecognizer.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecognizer)
        
        // Set up buttons
        arButton.layer.cornerRadius = 8
        navigateButton.layer.cornerRadius = 8
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        destination = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let pin = MKPointAnnotation()
        pin.coordinate = destination!
        
        mapView.addAnnotation(pin)
    }
    
    @IBAction func navigate(_ sender: UIButton) {
        print("Navigate pressed")
        if let dest = destination {
            // View navigation to destination
            
        }
    }
}

