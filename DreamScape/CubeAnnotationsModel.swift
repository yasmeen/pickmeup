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
