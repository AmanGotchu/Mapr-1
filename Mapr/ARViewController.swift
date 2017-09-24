//
//  ARViewController.swift
//  Mapr
//
//  Created by tianyi on 9/23/17.
//  Copyright © 2017 tianyi. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation
import MapKit

class ARViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var addCubeButton: UIButton!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var initLocation: CLLocation?
    
    var destination: CLLocationCoordinate2D?
    var routePolylines: [MKPolyline]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let scene = SCNScene()
        sceneView.scene = scene
        
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal
//        
//        sceneView.session.run(configuration)
        
        // Round buttons
        mapButton.layer.cornerRadius = 8
        addCubeButton.layer.cornerRadius = 8
        
        // Location Manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        addObject()
    }
    
    func addObject(){
        let candle = Marker()
        candle.loadModal()
        
        let xPosCurrent = CLLocation[0]
        let yPosCurrent = CLLocation[1]
        let zPosCurrent = CLLocation[12]
        
        let xPosDes = CLLocationCoordinate2D[0]
        let yPosDes = CLLocationCoordinate2D[1]
        let zPosDes = CLLocationCoordinate2D[2]
        
        candle.position = SCNVector3(xPosCurrent, yPosCurrent, zPosCurrent)
        candle.position = SCNVector3(xPosDes, yPosDes, zPosDes)
        
        sceneView.scene.rootNode.addChildNode(candle)
    }
    
    
    
    func randFloat(min: Float, max: Float) -> Float{
        return (Float(arc4random())/0xFFFFFFFF) * (max - min) + min
    }
    
    @IBAction func addCube(_ sender: Any) {
        
        let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        
        let cc = getCameraCoordinates(sceneView: sceneView)
        cubeNode.position = SCNVector3(cc.x, cc.y, cc.z)
        
        sceneView.scene.rootNode.addChildNode(cubeNode)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning() 
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addCup(_ sender: Any) {
        let cupNode = SCNNode()
        let cc = getCameraCoordinates(sceneView: sceneView)
        cupNode.position = SCNVector3(cc.x, cc.y, cc.z)
        
        guard let virtualObjectScene = SCNScene(named: "cup.scn", inDirectory: "Models.scnassets/cup")
            
            else {
                return
        }
        
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes{
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            wrapperNode.addChildNode(child)
        }
        cupNode.addChildNode(wrapperNode)
        sceneView.scene.rootNode.addChildNode(cupNode)
    }
    
    struct myCameraCoordinates{
        var x = Float()
        var y = Float()
        var z = Float()
    }
    
    func getCameraCoordinates(sceneView: ARSCNView)->myCameraCoordinates{
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        let cameraCoordinates = MDLTransform(matrix: cameraTransform!)
        
        var cc = myCameraCoordinates()
        cc.x = cameraCoordinates.translation.x
        cc.y = cameraCoordinates.translation.y
        cc.z = cameraCoordinates.translation.z
        
        return cc
    }
    
    func getDistance(_ latitude: Double, _ longitude: Double) -> [Double]{
        let x = initLocation!.distance(from: CLLocation(latitude: initLocation!.coordinate.latitude, longitude: longitude)) * ((longitude > initLocation!.coordinate.longitude) ? 1 : -1)
        let z = initLocation!.distance(from: CLLocation(latitude: latitude, longitude: initLocation!.coordinate.longitude)) * ((latitude > initLocation!.coordinate.latitude) ? -1 : 1)
        return [x, z]
    }
}


