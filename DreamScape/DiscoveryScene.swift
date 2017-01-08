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
    var cameraNode: SCNNode
    var lastPosition: Dictionary<String, Float> = ["x":0.0, "y":0.0, "z":0.0]
    
    override init() {
        cameraNode = SCNNode()
        super.init()
        let camera = SCNCamera()
        cameraNode.camera = camera
        
        //loading default values from Constants.swift with appropriate scaling factors
        cameraNode.position = SCNVector3(x: Constants.defaultCameraPosition["x"]!,
                                         y: Constants.defaultCameraPosition["y"]!,
                                         z: Constants.defaultCameraPosition["z"]!)
        self.rootNode.addChildNode(cameraNode)
    }
    
    
    func addDiscoveredShapeToFOV(discoveredShapes shape: Constants.filledStructure) -> SCNNode {
        var shapeGeometry : SCNGeometry? //we can make this a non-optional once we support all types of shapes defined in
        //enum Shape in Constants.swift
        
        switch(shape.shape) {
        case .Cube:
            shapeGeometry = SCNBox(
                width:  Constants.defaultCubeDimensions["width"]! * shape.scale,
                height: Constants.defaultCubeDimensions["height"]! * shape.scale,
                length: Constants.defaultCubeDimensions["length"]! * shape.scale,
                chamferRadius: Constants.defaultCubeDimensions["chamferRadius"]!)
            shapeGeometry!.materials = shape.materials
            
        default:
            print("ERROR - Shape has been discovered that has yet to be implemented")
        }
        
        //animation denoting an "undiscovered" shape
        //once the shape is discovered, rotational axis is reset and animation stops
        let shapeNode = SCNNode(geometry: shapeGeometry!)
        //edit the matrix below to tilt the initial angle of the shape
        //shapeNode.pivot = SCNMatrix4MakeRotation(Float.pi, 50, 20, 5)
        let spin = CABasicAnimation(keyPath: "rotation")
        // Use from-to to explicitly make a full rotation around z
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 5, z: 0, w: Float.pi * 2))
        spin.duration = 3
        spin.repeatCount = .infinity
        shapeNode.addAnimation(spin, forKey: "spin around")
        
        //constaining the camera settings to avoid the gimbal lock problem (unintended offset of the rotational axis)
        //let constraint = SCNLookAtConstraint(target: shapeNode)
        //constraint.isGimbalLockEnabled = true
        //cameraNode.constraints = [constraint]
        
        shapeNode.position = SCNVector3(x: lastPosition["x"]!, y: lastPosition["y"]!, z: lastPosition["z"]!)
        
        lastPosition["x"] = lastPosition["x"]! + 5.0
        lastPosition["z"] = lastPosition["z"]! + 5.0
        
        self.rootNode.addChildNode(shapeNode)
        return shapeNode
    }
    
    
    //**************************************SPOOF SERVER HELPER METHODS******************************************
    //The init methods used below should only be used when debugging, when no server requests are taking place

    init(scale: CGFloat, withShape shape: Constants.Shape, withMaterials materials: [SCNMaterial]) {
        cameraNode = SCNNode()
        super.init()
        let camera = SCNCamera()
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
        
        //animation denoting an "undiscovered" shape
        //once the shape is discovered, rotational axis is reset and animation stops
        let shapeNode = SCNNode(geometry: shapeGeometry!)
        //edit the matrix below to tilt the initial angle of the shape
        //shapeNode.pivot = SCNMatrix4MakeRotation(Float.pi, 50, 20, 5)
        let spin = CABasicAnimation(keyPath: "rotation")
        // Use from-to to explicitly make a full rotation around z
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 5, z: 0, w: Float.pi * 2))
        spin.duration = 3
        spin.repeatCount = .infinity
        shapeNode.addAnimation(spin, forKey: "spin around")
        
        //constaining the camera settings to avoid the gimbal lock problem (unintended offset of the rotational axis)
        //let constraint = SCNLookAtConstraint(target: shapeNode)
        //constraint.isGimbalLockEnabled = true
        //cameraNode.constraints = [constraint]
        
        //constructing node hierachy
        self.rootNode.addChildNode(cameraNode)
        self.rootNode.addChildNode(shapeNode)
//        DiscoveryLensViewController.addCameraNode(camera: cameraNode)
//        DiscoveryLensViewController.addDiscoveredShapeNode(shape: shapeNode)
    }
    
    convenience init(scale: CGFloat, withShape shape: Constants.Shape, withImages images: [UIImage]) {
        var materials: [SCNMaterial] = Array()
        for image: UIImage in images {
            let material: SCNMaterial = SCNMaterial()
            material.diffuse.contents = image
            materials.append(material)
        }
        
        self.init(scale: scale, withShape: shape, withMaterials: materials)
    }
    
    //**************************************************************************************************************

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
