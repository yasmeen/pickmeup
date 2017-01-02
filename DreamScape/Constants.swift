//
//  Constants.swift
//  DreamScape
//
//  Created by mjhowell on 12/30/16.
//  Copyright © 2016 Morgan. All rights reserved.
//

import UIKit

public class Constants {
    
    // MARK: - value constants
    public static let MAX_SCALE: CGFloat = 100.0
    public static let MIN_SCALE: CGFloat = 0.0
    public static let DEBUG_MODE: Bool = true
    public static let SPOOF_SERVER: Bool = true //for now, this implies we are only working with cubes
    public static let DEFAULT_BLUE: [Float] = [0.0, 122.0/255.0, 1.0, 1.0]

    // MARK: - Generic shape wrappers and helpers
    public enum Shape {
        case Cube
        case RectangularPrism
        case SquarePyramid
        case TriangularPrism
        case TriangularPyramid
        case Sphere
    }
    
    public static let shapeMaterialCount: Dictionary<Constants.Shape, Int> = [
        Constants.Shape.Cube: 6,
        Constants.Shape.RectangularPrism: 6,
        Constants.Shape.SquarePyramid: 5,
        Constants.Shape.TriangularPrism: 5,
        Constants.Shape.TriangularPyramid: 4,
        Constants.Shape.Sphere: 1
    ]
    
    
    // MARK: - Shape specific face information, raw values correlate to geometric indices
    //Whenever constructing a shape from scratch, ensure each geometry index aligns with these enums' raw values
    //This is necessary for hit tests, so a geometry index owns a specific material consistently
    enum CubeFace : Int {
        case Front, Right, Back, Left, Top, Bottom
    }
    
    
    // MARK: - Default shape sizes (equivalent to scale multiplier = 1.0)
    public static let defaultCubeDimensions: Dictionary<String, CGFloat> = [
        "width": 3.0,
        "height": 3.0,
        "length": 3.0,
        "chamferRadius": 0.25
    ]
    
    public static let defaultCameraPosition: Dictionary<String, Float> = [
        "x": 0,
        "y": 0,
        "z": 15.0,
    ]
    
}
