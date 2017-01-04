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
    var discoveredShapes: [Constants.filledStructure] = Array()
    
    //will eventually support multiple shapes and pass in all shapes to a DiscoveryScene constructor
    var scene : SCNScene {
        get {
            return DiscoveryScene(scale: discoveredShapes.first!.scale,
                                  withShape: discoveredShapes.first!.shape,
                                  withMaterials: discoveredShapes.first!.materials)
        }
    }
    
    func hasShapesInFieldOfView() -> Bool {
        return discoveredShapes.count > 0
    }
    
//    //A shape is created from the server response once proximity is indicated
//    //simplified server model contains shapes with planar faces
//    //simplified server response includes: shape type, number of faces, image per face
//    struct DiscoveredShape {
//        var shape: Constants.Shape
//        var faceCount: Int
//        var scale: CGFloat
//        //Images should not exist without a corresponding geometry index
//        //For now the solution will be to ensure that when the saveShape API endpoint is called,
//        //materials are uploaded in strictly increasing order, however this has its obvious limitations in an
//        //asynchronous environment, thus we need to eventually abstract images on the server to be an exclusive:
//        //"image + geometry index" object
//        var materialImages: [UIImage]
//        var materials: [SCNMaterial]
//        
//        //initialization from the server
//        init(shape: Constants.Shape, ofSize scale: CGFloat, withImages images: UIImage...) {
//            self.shape = shape
//            self.faceCount = Constants.shapeMaterialCount[shape]!
//            
//            if scale > Constants.MIN_SCALE && scale < Constants.MAX_SCALE {
//                self.scale = scale //this scale is a multiplier on the default sizes defined in Constants.swift
//            } else {
//                self.scale = 1.0
//            }
//            
//            self.materialImages = images
//            self.materials = Array()
//            for image : UIImage in images {
//                let material : SCNMaterial = SCNMaterial()
//                material.diffuse.contents = image
//                materials.append(material)
//            }
//            
//        }
//        
//        //initialization from the canvas editor (with raw materials instead of images)
//        init(shape: Constants.Shape, ofSize scale: CGFloat, withMaterials materials: [SCNMaterial]) {
//            self.shape = shape
//            self.faceCount = Constants.shapeMaterialCount[shape]!
//            
//            if scale > Constants.MIN_SCALE && scale < Constants.MAX_SCALE {
//                self.scale = scale //this scale is a multiplier on the default sizes defined in Constants.swift
//            } else {
//                self.scale = 1.0
//            }
//            
//            self.materialImages = Array() //empty array, reverse conversion from material to image unecessary
//            //order in geometric indices should be consistent since materials were added manually in the canvas editor
//            self.materials = materials
//            
//        }
//        
//        var scene : SCNScene {
//            get {
//                let s: SCNScene = DiscoveryScene(scale: self.scale, withShape: self.shape, withMaterials: self.materials)
//                return s
//            }
//        }
//        
//    }

}
