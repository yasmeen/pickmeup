//
//  CubeAnnotationsModel.swift
//  DreamScape
//
//  Created by mjhowell on 12/25/16.
//  Copyright © 2016 Morgan. All rights reserved.
//

import UIKit
import SceneKit

class CubeAnnotationsModel {
    //most up to date shape that lives in the canvas (with most recent annotations)
    var currentShape: Constants.filledStructure
    
    
    init(withShape filledStructure: Constants.filledStructure) {
        self.currentShape = filledStructure
    }
    
    //preparing a fresh shape with blank materials
    convenience init(shape: Constants.Shape) {
        switch(shape) {
        case .Cube:
            self.init(withShape: Constants.filledStructure(shape: Constants.Shape.Cube, ofScale: 1.0))
        default:
            print("Error- canvas model currently only works with cubes")
            self.init(withShape: Constants.filledStructure(shape: Constants.Shape.Cube, ofScale: 1.0))
        }
    }
    
    //prearing shape with supplied materials
//    convenience init(suppliedMaterials materials: [SCNMaterial]) {
//        self.init(withShape: Constants.filledStructure(shape: Constants.Shape.Cube, ofScale: 1.0, withMaterials: materials))
//    }
    
    //wrapper for the faces of any object
//    struct GenericFace {
//        var shape: Constants.Shape
//        var recycled: Bool
//        var material: SCNMaterial
//    }
    
    //dictionary of materials pertaining to a brand new cube, which can be edited by looking up the appropriate facial geometry index
//    var cubeTextures: Dictionary<Constants.CubeFace, GenericFace> = [
//        .Front: GenericFace(shape: Constants.Shape.Cube,
//                            recycled: false,
//                            material: SCNMaterial()),
//        .Right: GenericFace(shape: Constants.Shape.Cube,
//                            recycled: false,
//                            material: SCNMaterial()),
//        .Back: GenericFace(shape: Constants.Shape.Cube,
//                           recycled: false,
//                           material: SCNMaterial()),
//        .Left: GenericFace(shape: Constants.Shape.Cube,
//                           recycled: false,
//                           material: SCNMaterial()),
//        .Top: GenericFace(shape: Constants.Shape.Cube,
//                          recycled: false,
//                          material: SCNMaterial()),
//        .Bottom: GenericFace(shape: Constants.Shape.Cube,
//                             recycled: false,
//                             material: SCNMaterial())
//        ]
    
    //response from canvas editor
    private var responseLoader: canvasResponse?
    
    struct canvasResponse {
        var face : Constants.CubeFace
        var material : SCNMaterial
    }
    
    //given an image and a corresponding face, the material will be reset to the given image
    func setFace(faceIndex face: Int, with materialImage: UIImage) {
        if face < Constants.shapeMaterialCount[currentShape.shape]! {
            currentShape.materials[face].diffuse.contents = materialImage
            currentShape.materialImages[face] = materialImage
        } else {
            print("Error - Cube Annotations Model attempted to set a face index that does not exist")
        }
    }
    
    //public accessor for annotation updates
    //optional type because user may cancel annotation or experience interruption
    var faceUpdate : canvasResponse? {
        get {
            return responseLoader
        }
    }
    
    //scene-kit representation of the shape that is loaded from the shape creator view controller
    var sceneView : SCNScene?
}
