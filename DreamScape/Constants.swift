//
//  Constants.swift
//  DreamScape
//
//  Created by mjhowell on 12/30/16.
//  Copyright © 2016 Morgan. All rights reserved.
//

import UIKit
import SceneKit

public class Constants {
    
    // MARK: - value constants
    public static let MAX_SCALE: CGFloat = 100.0
    public static let MIN_SCALE: CGFloat = 0.0
    public static let DEBUG_MODE: Bool = true
    public static let SPOOF_SERVER: Bool = true //for now, this implies we are only working with cubes
    public static let DEFAULT_BLUE: [Float] = [0.0, 122.0/255.0, 1.0, 1.0]
    public static let CUBE_FACE_DIMENSION: Int = 300 //fresh cubes are initialized with 300x300 white materials
    
    // MARK: - Make & Drop v1 API endpoints
    public static let DROP_SHAPE_ENDPOINT = "http://dev-env.i42rmwfkep.us-west-2.elasticbeanstalk.com/api/v1/drop_shape"

    // MARK: - Generic shape wrappers and helpers
    public enum Shape : String {
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
    
    public static let defaultCameraCanvasPosition: Dictionary<String, Float> = [
        "x": -3,
        "y": 3,
        "z": 3,
    ]
    
    //A filledStructre is created from the server response once proximity is indicated or created
    //from the canvas from a fresh structure, which is then sent to the server
    //simplified server model contains shapes with planar faces
    //simplified server response includes: shape type, number of faces, image per face
    struct filledStructure {
        var shape: Constants.Shape
        var faceCount: Int
        var scale: CGFloat
        //Images should not exist without a corresponding geometry index
        //For now the solution will be to ensure that when the saveShape API endpoint is called,
        //materials are uploaded in strictly increasing order, however this has its obvious limitations in an
        //asynchronous environment, thus we need to eventually abstract images on the server to be an exclusive:
        //"image + geometry index" object
        var materialImages: [UIImage]
        var materials: [SCNMaterial]
        
        //initialization from the server
        init(shape: Constants.Shape, ofScale scale: CGFloat, withImages images: UIImage...) {
            self.shape = shape
            self.faceCount = Constants.shapeMaterialCount[shape]!
            
            if scale > Constants.MIN_SCALE && scale < Constants.MAX_SCALE {
                self.scale = scale //this scale is a multiplier on the default sizes defined in Constants.swift
            } else {
                self.scale = 1.0
            }
            
            self.materials = Array()
            self.materialImages = Array()
            for i in 1...Constants.shapeMaterialCount[shape]! {
                if i<=images.count {
                    self.materialImages.append(images[i-1])
                    let material = SCNMaterial()
                    material.diffuse.contents = images[i-1]
                    self.materials.append(material)
                } else {
                    let material = SCNMaterial()
                    let materialImage = UIImage(color: UIColor.white,
                                                size: CGSize(width: Constants.CUBE_FACE_DIMENSION,
                                                             height: Constants.CUBE_FACE_DIMENSION))
                    self.materialImages.append(materialImage!)
                    material.diffuse.contents = materialImage
                    self.materials.append(material)
                }
            }
        }
        
        //initialization from the canvas editor (with raw materials instead of images)
        init(shape: Constants.Shape, ofScale scale: CGFloat, withMaterials materials: [SCNMaterial]) {
            self.shape = shape
            self.faceCount = Constants.shapeMaterialCount[shape]!
            
            if scale > Constants.MIN_SCALE && scale < Constants.MAX_SCALE {
                self.scale = scale //this scale is a multiplier on the default sizes defined in Constants.swift
            } else {
                self.scale = 1.0
            }
            
            self.materialImages = Array()
            self.materials = Array()
            for i in 1...Constants.shapeMaterialCount[shape]! {
                if i<=materials.count, let image = materials[i-1].diffuse.contents as? UIImage {
                    self.materialImages.append(image)
                    self.materials.append(materials[i-1])
                } else {
                    let material = SCNMaterial()
                    let materialImage = UIImage(color: UIColor.white,
                                                size: CGSize(width: Constants.CUBE_FACE_DIMENSION,
                                                             height: Constants.CUBE_FACE_DIMENSION))
                    self.materialImages.append(materialImage!)
                    material.diffuse.contents = materialImage
                    self.materials.append(material)
                    
                }
            }
            
        }
        
        //initialization of a fresh shape
        init(shape: Constants.Shape, ofScale scale: CGFloat) {
            self.init(shape: shape, ofScale: scale, withMaterials: [])
        }
        
    }
    
}

//MARK: - Additional functionality with scenekit's vectors made global, add any applied linear algebra concepts here
public extension SCNVector3 {
    func multiply(factor: Float) -> SCNVector3 {
        return SCNVector3(x: self.x*factor, y: self.y*factor, z: self.z*factor)
    }
}

//MARK: - Additional functionality with UIImages
public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
