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
    
    enum Shape {
        case Cube(face: CubeFace)
        case TriangularPrism(face: Int)
        case RectangularPrism(face: Int)
        case Torus(face: Int)
        case Sphere(face: Int)
    }
    
    enum CubeFace : Int {
        case Front, Right, Back, Left, Top, Bottom
    }
    
    //wrapper for the faces of any object
    struct GenericFace {
        var shape: Shape
        var recycled: Bool
        var material: SCNMaterial
    }
    
    //dictionary of materials pertaining to the current cube in the editor
    var cubeTextures: Dictionary<CubeFace, GenericFace> = [
        .Front: GenericFace(shape: Shape.Cube(face: CubeFace.Front),
                            recycled: false,
                            material: SCNMaterial()),
        .Right: GenericFace(shape: Shape.Cube(face: CubeFace.Right),
                            recycled: false,
                            material: SCNMaterial()),
        .Back: GenericFace(shape: Shape.Cube(face: CubeFace.Back),
                           recycled: false,
                           material: SCNMaterial()),
        .Left: GenericFace(shape: Shape.Cube(face: CubeFace.Left),
                           recycled: false,
                           material: SCNMaterial()),
        .Top: GenericFace(shape: Shape.Cube(face: CubeFace.Top),
                          recycled: false,
                          material: SCNMaterial()),
        .Bottom: GenericFace(shape: Shape.Cube(face: CubeFace.Bottom),
                             recycled: false,
                             material: SCNMaterial())
    ]
    
    //response from canvas editor
    private var responseLoader: canvasResponse?
    
    struct canvasResponse {
        var face : CubeFace
        var material : SCNMaterial
    }
    
    //given an image and a corresponding face, the material will be reset to the given image
    func setFace(_ face: CubeFace, with material: UIImage) {
        if let prevMaterial = cubeTextures[face] {
            prevMaterial.material.diffuse.contents = material
        }
    }
    
    //public accessor for annotation updates
    //optional type because user may cancel annotation or experience interruption
    var faceUpdate : canvasResponse? {
        get {
            return responseLoader
        }
    }
    
    
}
