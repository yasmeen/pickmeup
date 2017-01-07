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
    
    func prepareJSONDropPost(latitude lat: String, longitude long: String,
                             withShape shape: Constants.filledStructure, hasSettings settings: Bool) -> Data? {
        var jsonBody = Dictionary<String, Any>()
        jsonBody["latitude"] = lat
        jsonBody["longitude"] = long
        jsonBody["name"] = shape.shape.rawValue
        jsonBody["face_count"] = String(shape.faceCount)
        jsonBody["created_at"] = "TODO"
        jsonBody["public"] = "true"
        jsonBody["owner"] = "TODO"
        jsonBody["materials"] = prepareJSONImageMaterials(with: shape.materialImages)
        
        var jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
        } catch {
            print("ERROR - Formatting JSON for drop request")
        }
       
        return jsonData
    }
    
    //encoding the materials to base64 to be sent to the MakeDrop APIs
    func prepareJSONImageMaterials(with images: [UIImage]) -> Dictionary<String, Any> {
        var imagesJSON = Dictionary<String, Any>()
        
        for i in 0..<images.count {
            var  imageJSON = Dictionary<String, String>()
            let base64Image = UIImageJPEGRepresentation(images[i], 0.9)?.base64EncodedString()
            imageJSON["content_type"] = "image/jpeg"
            imageJSON["filename"] = "image\(i)"
            imageJSON["file_data"] = base64Image ?? ""
            imageJSON["geometry_index"] = String(i)
            imagesJSON["image\(i)"] = imageJSON
        }
        return imagesJSON
    }
    
    
    //helper function useful for debugging JSON payloads
    func printJSONDataReadable(json: Data?) {
        let dictFromJSON = String.init(data: json!, encoding: .ascii)
        print(dictFromJSON ?? "ERROR- inspecting json data")
    }
    
    func makeDropAPIRequestOnCurrentCube() {
        //dropping at current location
        //TODO: option to drop remotely (passing in lat and long here for remote location)
        let jsonData = prepareJSONDropPost(
            latitude: GlobalResources.Location.lat,
            longitude: GlobalResources.Location.long,
            withShape: shapeModel.currentShape,
            hasSettings: false)
        
        printJSONDataReadable(json: jsonData)
        
        if jsonData != nil {
            let url: URL = NSURL(string: Constants.DROP_SHAPE_ENDPOINT)! as URL
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            DispatchQueue.global(qos: .userInitiated).async {
                let task = URLSession.shared.dataTask(with: request as URLRequest) { data,response,error in
                    if error != nil{
                        print("ERROR- \(error?.localizedDescription)")
                        return
                    }
                    do {
                        let response = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                        DispatchQueue.main.async {
                            print("RESPONSE: \(response)")
                        }
                        
                    } catch {
                        print("ERROR - Deserializing the response from the drop request")
                    }
                }
                task.resume()
            }
            
        }
    }
    
    func dropShape(_ swipeRight: UISwipeGestureRecognizer) {
        if ShapeCreatorViewController.shapeInCanvas != nil {
            animateShapeInCanvasBeingThrown()
            makeDropAPIRequestOnCurrentCube()
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
    }
    
    //the user taps on a face (side) of the shape to edit it
    func sendFaceCanvasRequest(_ gesture: UITapGestureRecognizer) {
        let callingView = gesture.location(in: sideSelector)
        let hitResults = sideSelector.hitTest(callingView)
        if let tappedFace = hitResults.first{
            performSegue(withIdentifier: "annotateShape", sender: tappedFace)
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


