//
//  ViewController+MapViewDelegate.swift
//  Mapr
//
//  Created by tianyi on 9/23/17.
//  Copyright © 2017 tianyi. All rights reserved.
//

import UIKit
import MapKit

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor
        overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation){
            print("NOT REGISTERED AS MKPOINTANNOTATION");
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "busIdentifier")
        if(annotationView == nil){
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "busIdentifier")
            annotationView!.canShowCallout = true
        }
        else{
            annotationView!.annotation = annotation;
        }
        
        annotationView!.image = UIImage(named: "bus.png")
        
        return annotationView;
    }
}
