//
//  DiscoveryLensModel.swift
//  DreamScape
//
//  Created by mjhowell on 12/30/16.
//  Copyright © 2016 Morgan. All rights reserved.
//

import UIKit
import SceneKit

class DiscoveryLensModel {
    
    //all shapes that are currently in the field of view
    var discoveredShapes = Dictionary<Constants.filledStructure, SCNNode>()
    
    //scenekit nodes for state manipulation 
    var cameraNode: SCNNode?
    var sceneView: SCNView
    var discoveredShapesCount = 0
    
    init(scene sceneView: SCNView) {
        self.sceneView = sceneView
        if let scene = sceneView.scene as? DiscoveryScene {
            self.cameraNode = scene.cameraNode
        }
    }
    
    
    //will eventually support multiple shapes and pass in all shapes to a DiscoveryScene constructor
//    var scene : SCNScene {
//        get {
//            return DiscoveryScene(scale: discoveredShapes.first!.scale,
//                                  withShape: discoveredShapes.first!.shape,
//                                  withMaterials: discoveredShapes.first!.materials)
//        }
//    }
    
    func hasShapesInFieldOfView() -> Bool {
        return discoveredShapes.count > 0
    }
    
    func addShapeToFieldOfView(shape: Constants.filledStructure) {
        if discoveredShapes[shape] == nil {
            if let scene = sceneView.scene as? DiscoveryScene {
                if(Constants.DEBUG_MODE) {
                    print("DEBUG- ADDING SHAPE: \(shape.id ?? -1) TO FIELD OF VIEW")
                }
                discoveredShapes[shape] = scene.addDiscoveredShapeToFOV(discoveredShapes: shape)
            }
        } else {
            print("collision")
        }
    }
    
}
