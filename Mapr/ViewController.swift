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
import Dispatch

class CustomAnnotation: MKPointAnnotation {
    
}

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
    
    var timer = Timer()
    var pin: CustomAnnotation?
    
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
        
        // Set up bus icon moving
//        let task = DispatchWorkItem {
//            self.pinBus()
//        }
//        DispatchQueue.global(qos: .background).async(execute: task)
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.pinBus), userInfo: nil, repeats: true)

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
    func getLocation(_ point: [Double]) -> CLLocation {
        return CLLocation(latitude: point[0], longitude: point[1])
    }
    
    @objc func pinBus() {
//        var pins: [MKPointAnnotation] = []
        var points = [[29.717477, -95.408437], [29.716089, -95.407749], [29.716452, -95.406773], [29.714868, -95.405925],
                      [29.718297, -95.397245], [29.718679, -95.397331], [29.719052, -95.396505], [29.719900, -95.396934],
                      [29.719587, -95.397761], [29.719848, -95.398141], [29.716745, -95.406016], [29.718143, -95.406746]]
        var distances: [Double] = []
        for i in 1..<points.count {
            distances.append(getLocation(points[i]).distance(from: getLocation(points[i-1])))
        }
        distances.append(getLocation(points[0]).distance(from: getLocation(points[11])))
//        print("Distances:")
//        print(distances)
        var totalDistance: Double = 0
        for distance in distances {
            totalDistance += distance
        }
        
        let timeInterval: Double = 300
        
        let distancePerTime = totalDistance / timeInterval
//        print("Distance Per Time:")
//        print(distancePerTime)
        
        var time = NSDate().timeIntervalSince1970
        time = time.truncatingRemainder(dividingBy: timeInterval)
        
        let distance = distancePerTime * time
//        print("Time and Distance:")
//        print(time)
//        print(distance)
        var curDistance: Double = 0
        for i in 0..<distances.count {
            if (curDistance + distances[i] + 0.001 >= distance) {
                let firstWeight = (distance - curDistance)/distances[i]
                let secondWeight = 1 - firstWeight
                let nextPoint = (i+1) % distances.count
                let lat: Double = secondWeight*points[i][0] + firstWeight*points[nextPoint][0]
                let long: Double = secondWeight*points[i][1] + firstWeight*points[nextPoint][1]
                
                var previousPin: CustomAnnotation?
                if let ppin = pin {
                    previousPin = pin!
                }
                pin = CustomAnnotation()
                pin!.coordinate = CLLocationCoordinate2D(latitude: lat, longitude:long)
                mapView.addAnnotation(pin!)
                if let ppin = previousPin {
                    mapView.removeAnnotation(previousPin!)
                }
                break
            } else {
                curDistance += distances[i]
            }
        }
    }
    
    
}

