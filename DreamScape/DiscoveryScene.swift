//
//  DiscoveryScene.swift
//  DreamScape
//
//  Created by mjhowell on 12/30/16.
//  Copyright © 2016 Morgan. All rights reserved.
//

import UIKit
import SceneKit

class DiscoveryScene: SCNScene {

    init(scale: CGFloat, withShape shape: Constants.Shape, withMaterials materials: [SCNMaterial]) {
        super.init()
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        
        //loading default values from Constants.swift with appropriate scaling factors
        cameraNode.position = SCNVector3(x: Constants.defaultCameraPosition["x"]!,
                                         y: Constants.defaultCameraPosition["y"]!,
                                         z: Constants.defaultCameraPosition["z"]!)
        
        var shapeGeometry : SCNGeometry? //we can make this a non-optional once we support all types of shapes defined in
                                         //enum Shape in Constants.swift
        
        switch(shape) {
        case .Cube:
            shapeGeometry = SCNBox(
                width:  Constants.defaultCubeDimensions["width"]! * scale,
                height: Constants.defaultCubeDimensions["height"]! * scale,
                length: Constants.defaultCubeDimensions["length"]! * scale,
                chamferRadius: Constants.defaultCubeDimensions["chamferRadius"]!)
            shapeGeometry!.materials = materials
        default:
            print("ERROR - Shape has been discovered that has yet to be implemented")
        }
        
        
        let shapeNode = SCNNode(geometry: shapeGeometry!)

        
        //constaining the camera settings to avoid the gimbal lock problem (unintended offset of the rotational axis)
        let constraint = SCNLookAtConstraint(target: shapeNode)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        
        //constructing node hierachy
        self.rootNode.addChildNode(cameraNode)
        self.rootNode.addChildNode(shapeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
