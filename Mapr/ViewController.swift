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
    var destinationPin: MKPointAnnotation?
    
    var routePolylines: [MKPolyline]?
    
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
        longPressRecognizer.minimumPressDuration = 0.5
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
        
        if let pin = destinationPin {
            mapView.removeAnnotation(pin)
        }
        
        if let polylines = routePolylines {
            mapView.removeOverlays(polylines)
        }
        
        destinationPin = MKPointAnnotation()
        destinationPin?.coordinate = destination!
        
        mapView.addAnnotation(destinationPin!)
    }
    
    @IBAction func navigate(_ sender: UIButton) {
        print("Navigate pressed")
        if let source = currentLocation, let dest = destination {
            // View navigation to destination
            let directionRequest = MKDirectionsRequest()
            directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: source.coordinate))
            directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: dest))
            directionRequest.transportType = .walking
            
            let directions = MKDirections(request: directionRequest)
            
            directions.calculate(completionHandler: {(response, error) in
                if (error != nil) {
                    print("Error getting directions")
                } else {
                    self.showRoute(response!)
                }
            })
        }
    }
    
    func showRoute(_ response: MKDirectionsResponse) {
        routePolylines = []
        for route in response.routes {
            routePolylines!.append(route.polyline)
        }
        mapView.addOverlays(routePolylines!, level: .aboveRoads)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showARView") {
            print("Segue to ARView")
            if let dest = segue.destination as? ARViewController {
                dest.destination = self.destination
                dest.initLocation = currentLocation
                dest.routePolylines = self.routePolylines
            }
        }
    }
}

