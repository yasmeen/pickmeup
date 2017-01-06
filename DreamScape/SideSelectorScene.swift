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
    
    init(withShape structure: Constants.filledStructure) {
        super.init()
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        
        //loading default values from Constants.swift with appropriate scaling factors
        cameraNode.position = SCNVector3(x: Constants.defaultCameraCanvasPosition["x"]!,
                                         y: Constants.defaultCameraCanvasPosition["y"]!,
                                         z: Constants.defaultCameraCanvasPosition["z"]!)
        
        var shapeGeometry : SCNGeometry? //we can make this a non-optional once we support all types of shapes defined in
        //enum Shape in Constants.swift
        
        switch(structure.shape) {
        case .Cube:
            shapeGeometry = SCNBox(
                width:  Constants.defaultCubeDimensions["width"]! * structure.scale,
                height: Constants.defaultCubeDimensions["height"]! * structure.scale,
                length: Constants.defaultCubeDimensions["length"]! * structure.scale,
                chamferRadius: Constants.defaultCubeDimensions["chamferRadius"]!)
            shapeGeometry!.materials = structure.materials
            
        default:
            print("ERROR - Shape has been discovered that has yet to be implemented")
        }
        
        //constaining rotational axes for ease in user side selection
        let shapeNode = SCNNode(geometry: shapeGeometry!)
        cameraNode.position = SCNVector3(x: -3.0, y: 3.0, z: 3.0)
        let constraint = SCNLookAtConstraint(target: shapeNode)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        
        
        //constructing node hierachy
        self.rootNode.addChildNode(cameraNode)
        self.rootNode.addChildNode(shapeNode)
        ShapeCreatorViewController.shapeInCanvas = shapeNode
        ShapeCreatorViewController.sceneKitCamera = cameraNode
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
