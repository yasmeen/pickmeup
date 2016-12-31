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
    
    //wrapper for the faces of any object
    struct GenericFace {
        var shape: Constants.Shape
        var recycled: Bool
        var material: SCNMaterial
    }
    
    //dictionary of materials pertaining to a brand new cube, which can be edited by looking up the appropriate facial geometry index
    var cubeTextures: Dictionary<Constants.CubeFace, GenericFace> = [
        .Front: GenericFace(shape: Constants.Shape.Cube,
                            recycled: false,
                            material: SCNMaterial()),
        .Right: GenericFace(shape: Constants.Shape.Cube,
                            recycled: false,
                            material: SCNMaterial()),
        .Back: GenericFace(shape: Constants.Shape.Cube,
                           recycled: false,
                           material: SCNMaterial()),
        .Left: GenericFace(shape: Constants.Shape.Cube,
                           recycled: false,
                           material: SCNMaterial()),
        .Top: GenericFace(shape: Constants.Shape.Cube,
                          recycled: false,
                          material: SCNMaterial()),
        .Bottom: GenericFace(shape: Constants.Shape.Cube,
                             recycled: false,
                             material: SCNMaterial())
        ]
    
    //response from canvas editor
    private var responseLoader: canvasResponse?
    
    struct canvasResponse {
        var face : Constants.CubeFace
        var material : SCNMaterial
    }
    
    //given an image and a corresponding face, the material will be reset to the given image
    func setFace(_ face: Constants.CubeFace, with materialImage: UIImage) {
        if let prevMaterial = cubeTextures[face] {
            prevMaterial.material.diffuse.contents = materialImage
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
