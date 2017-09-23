//
//  ViewController+CLLocationManagerDelegate.swift
//  Mapr
//
//  Created by tianyi on 9/23/17.
//  Copyright © 2017 tianyi. All rights reserved.
//

import CoreLocation
import MapKit

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
//        print(currentLocation)
        if (!centered) {
            mapView.setRegion(MKCoordinateRegion(center: currentLocation!.coordinate, span: MKCoordinateSpanMake(0.01, 0.01)), animated: false)
            centered = true
        }
    }
} 
