//
//  SideSelectorScene.swift
//  DreamScape
//
//  Created by mjhowell on 12/25/16.
//  Copyright © 2016 Morgan. All rights reserved.
//

import UIKit
import SceneKit

class SideSelectorScene: SCNScene {
    //will eventually be generic shape detector
    var cube : SCNBox?
    
    override init() {
        super.init()
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 3.0)

        let cubeGeometry = SCNBox(width: 3.0, height: 3.0, length: 3.0, chamferRadius: 0.25)
        let cubeNode = SCNNode(geometry: cubeGeometry)
        cube = cubeGeometry
            
        //constaining the camera position
        cameraNode.position = SCNVector3(x: -3.0, y: 3.0, z: 3.0)
        let constraint = SCNLookAtConstraint(target: cubeNode)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]

        self.rootNode.addChildNode(cameraNode)
        self.rootNode.addChildNode(cubeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
