//
//  ShapeCreatorViewController.swift
//  DreamScape
//
//  Created by mjhowell on 12/25/16.
//  Copyright © 2016 Morgan. All rights reserved.
//

import UIKit
import SceneKit
import CoreLocation

class ShapeCreatorViewController: UIViewController, CAAnimationDelegate {
    

    @IBOutlet weak var sideSelector: SCNView! {
        didSet {
            sideSelector.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(ShapeCreatorViewController.sendFaceCanvasRequest(_:))
            ))
        }
    }
    
    @IBOutlet weak var upArrowSprite: UIImageView!
    
    //nodes in scenekit hierarchy that represent the shape we are currently editing and the camera that shows this shape
    static var shapeInCanvas: SCNNode?
    static var sceneKitCamera: SCNNode?
    

//TODO: swipe gestures do not work within the SCNView... We may need to disable user interactivity in scenekit and implement
    //custom pan gestures if this seems like a huge inconvenience for the users
//    func panScene(gestureRecognize: UIPanGestureRecognizer) {
//        //translation within shape
//        let translation = gestureRecognize.translation(in: gestureRecognize.view!)
//        
//        let x = Float(translation.x)
//        let y = Float(-translation.y)
//        
//        let anglePan = sqrt(pow(x,2)+pow(y,2))*(Float)(M_PI)/180.0
//        
//        var rotationVector = SCNVector4()
//        rotationVector.x = -y
//        rotationVector.y = x
//        rotationVector.z = 0
//        rotationVector.w = anglePan
//        
//        geometryNode.rotation = rotationVector
//        
//        
//        if(gestureRecognize.state == UIGestureRecognizerState.Ended) {
//            //
//        }
//    }
//    
    
    @IBOutlet var shapeCreatorSuperView: UIView! {
        didSet {
            //linking swipe right gesture with tab left
            let swipeRightGesture = UISwipeGestureRecognizer (
                target: self,
                action: #selector(ShapeCreatorViewController.tabLeft(_:))
            )
            swipeRightGesture.direction = .right
            shapeCreatorSuperView.addGestureRecognizer(swipeRightGesture)
            
            //linking swipe up gesture with dropping the shape
            let swipeUpGesture = UISwipeGestureRecognizer (
                target: self,
                action: #selector(ShapeCreatorViewController.dropShape(_:))
            )
            swipeUpGesture.direction = .up
            shapeCreatorSuperView.addGestureRecognizer(swipeUpGesture)
        }
    }
    
    //when called the shape within the canvas editor appears to be thrown
    func animateShapeInCanvasBeingThrown() {
        //give the shape the appearance of being "thrown"
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.setValue("rotation", forKey: "title")
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 5, y: 0, z: 0, w: Float.pi * 2))
        spin.duration = 3.0
        spin.repeatCount = 3.0
        ShapeCreatorViewController.shapeInCanvas?.addAnimation(spin, forKey: "spin around")
        ShapeCreatorViewController.sceneKitCamera?.position = SCNVector3(x: Constants.defaultCameraPosition["x"]!,
                                                                         y: Constants.defaultCameraPosition["y"]!,
                                                                         z: Constants.defaultCameraPosition["z"]!-20.0)
        
        //give the shape the appearance of growing smaller
        let scale = CABasicAnimation(keyPath: "scale")
        let originalScale = NSValue(scnVector3: ShapeCreatorViewController.shapeInCanvas!.scale)
        let scaledDownVector = ShapeCreatorViewController.shapeInCanvas!.scale.multiply(factor: 0)
        ShapeCreatorViewController.shapeInCanvas?.scale = scaledDownVector
        scale.setValue("scale", forKey: "title")
        scale.fromValue = originalScale//NSValue(scnVector3: ShapeCreatorViewController.shapeInCanvas!.scale)
        scale.toValue = scaledDownVector // NSValue(scnVector3: scaledDownVector)
        scale.duration = 2.0
        scale.repeatCount = 1.0
        scale.delegate = self
        ShapeCreatorViewController.shapeInCanvas?.addAnimation(scale, forKey: "scale down")
      
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let animationIdentifier = anim.value(forKey: "title") as? String {
            switch animationIdentifier {
            case "rotation":
                break
            case "scale":
                ShapeCreatorViewController.shapeInCanvas?.removeFromParentNode()
                ShapeCreatorViewController.shapeInCanvas = nil
                prepareFreshShape()
            default:
                break
            }
        }
    }
    
//    func prepareJSONDropPost(latitude: String, longitude longitude: String, withShape shape: )
//    
//    func makeDropAPIRequestOnCurrentCube() {
//        let jsonPost: Dictionary<String, String> = prepareJSONDropPost(
//            latitude:
//            longitude:
//            withShape:
//            hasSettings: false)
//        
//    }
    
    func dropShape(_ swipeRight: UISwipeGestureRecognizer) {
        if ShapeCreatorViewController.shapeInCanvas != nil {
            animateShapeInCanvasBeingThrown()
            //makeDropAPIRequestOnCurrentCube()
        }
    }
    
    func tabLeft(_ swipeRight: UISwipeGestureRecognizer) {
        self.tabBarController?.selectedIndex -= 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //tab bar item appearance under this specific controller
        self.tabBarController?.tabBar.tintColor = UIColor(
            colorLiteralRed: Constants.DEFAULT_BLUE[0],
            green: Constants.DEFAULT_BLUE[1],
            blue: Constants.DEFAULT_BLUE[2],
            alpha: Constants.DEFAULT_BLUE[3])
        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor.gray
    }
    
    //prototype contains only cube structures and is initially blank when not loaded from the discovery lens
    //TODO: Hold down shape in discovery lens to load up the shape model below
    var shapeModel = CubeAnnotationsModel(withShape: Constants.filledStructure(shape: .Cube, ofScale: 1))

    override func viewDidLoad() {
        super.viewDidLoad()
        animateArrowUpSprites()
        prepareFreshShape() //TODO: we only prepare fresh if we have not selected a discovered shape from the discovery lens
    }
    
    //prepare fresh cube to be annotated
    func prepareFreshShape() {
        //default for single cube upon fresh reload
        //TODO: Loading cube up from discovery mode
        shapeModel = CubeAnnotationsModel(withShape: Constants.filledStructure(shape: .Cube, ofScale: 1))
        sideSelector.scene = SideSelectorScene(withShape: shapeModel.currentShape)
        sideSelector.autoenablesDefaultLighting = true
        sideSelector.backgroundColor = UIColor.black
        sideSelector.allowsCameraControl = true
//        if let currentShapeInCanvas = ShapeCreatorViewController.shapeInCanvas?.geometry {
//            currentShapeInCanvas.materials.removeAll()
//            if let box = currentShapeInCanvas as? SCNBox {
//                //we must ensure materials have an order consistent with their geometric index for hit tests
//                box.materials.append(shapeModel.cubeTextures[.Front]!.material)
//                box.materials.append(shapeModel.cubeTextures[.Right]!.material)
//                box.materials.append(shapeModel.cubeTextures[.Back]!.material)
//                box.materials.append(shapeModel.cubeTextures[.Left]!.material)
//                box.materials.append(shapeModel.cubeTextures[.Top]!.material)
//                box.materials.append(shapeModel.cubeTextures[.Bottom]!.material)
//            }
//        }
    }
    
    //the user taps on a face (side) of the shape to edit it
    func sendFaceCanvasRequest(_ gesture: UITapGestureRecognizer) {
        let callingView = gesture.location(in: sideSelector)
        let hitResults = sideSelector.hitTest(callingView)
        if let tappedFace = hitResults.first{
            performSegue(withIdentifier: "annotateShape", sender: tappedFace)
//            let face = Constants.CubeFace(rawValue: tappedFace.geometryIndex)
//            if face != nil {
//                performSegue(withIdentifier: "annotateShape", sender: tappedFace)
//            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let annotator = segue.destination as? CanvasEditorViewController {
            annotator.navigationItem.title = "Editor"
            annotator.cubeModel = shapeModel
            if let faceEditRequest = sender as? SCNHitTestResult {
                annotator.faceId = faceEditRequest.geometryIndex
            } else {
                print("ERROR- while performing prep for segue to the canvas editor, we received an invalid hit test")
            }
        }
    }
    
    func animateArrowUpSprites() {
        //preparing swipe up arrow animation
        let arrowSprites = ["arrow1", "arrow2", "arrow3"]
        var arrowImageSprites = [UIImage]()
        for i in 0..<arrowSprites.count {
            let image = UIImage(named: arrowSprites[i])
            arrowImageSprites.append(image!)
        }
        upArrowSprite.animationImages = arrowImageSprites
        upArrowSprite.animationDuration = 1.0
        upArrowSprite.startAnimating()
    }
    
    
    
}


