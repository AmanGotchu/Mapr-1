//
//  ARViewController+CLLocationManagerDelegate.swift
//  Mapr
//
//  Created by tianyi on 9/23/17.
//  Copyright © 2017 tianyi. All rights reserved.
//

import Foundation
import CoreLocation

extension ARViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        if (initLocation == nil) {
            initLocation = currentLocation
        }
    }
}
