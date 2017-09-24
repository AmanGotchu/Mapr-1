//
//  Marker.swift
//  Mapr
//
//  Created by tianyi on 9/23/17.
//  Copyright © 2017 tianyi. All rights reserved.
//

import ARKit

class Marker: SCNNode {
    func loadModal(){
        guard let virtualObjectScene = SCNScene(named: "Models.scnassets/candle.scn") else{return}
        
        let wrapperNode = SCNNode()
        
        for child in virtualObjectScene.rootNode.childNodes{
            wrapperNode.addChildNode(child)
        }
        self.addChildNode(wrapperNode)
    }
}
