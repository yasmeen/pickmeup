//
//  ShapeCreatorViewController.swift
//  DreamScape
//
//  Created by mjhowell on 12/25/16.
//  Copyright © 2016 Morgan. All rights reserved.
//

import UIKit
import SceneKit

class ShapeCreatorViewController: UIViewController {
    
    
    @IBOutlet weak var sideSelector: SCNView! {
        didSet {
            sideSelector.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(ShapeCreatorViewController.sendFaceCanvasRequest(_:))
            ))
        }
    }
    
    @IBOutlet var shapeCreatorSuperView: UIView! {
        didSet {
            //tab view controlled by swipe gesture
            let swipeRightGesture = UISwipeGestureRecognizer (
                target: self,
                action: #selector(ShapeCreatorViewController.tabLeft(_:))
            )
            swipeRightGesture.direction = .right
            shapeCreatorSuperView.addGestureRecognizer(swipeRightGesture)
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
    
    //prototype contains only cube structures
    let shapeModel = CubeAnnotationsModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //preparing materials for fresh cube
        //TODO: Loading cube up from discovery mode
        if sideSelector != nil {
            sideSelector.scene = SideSelectorScene()
            sideSelector.autoenablesDefaultLighting = true
            sideSelector.backgroundColor = UIColor.black
            sideSelector.allowsCameraControl = true
            if let sideSelect = sideSelector.scene as? SideSelectorScene {
                if sideSelect.cube != nil {
                    sideSelect.cube?.materials.removeAll()
                    //we must ensure materials have an order consistent with their geometric index for hit tests
                    sideSelect.cube?.materials.append(shapeModel.cubeTextures[.Front]!.material)
                    sideSelect.cube?.materials.append(shapeModel.cubeTextures[.Right]!.material)
                    sideSelect.cube?.materials.append(shapeModel.cubeTextures[.Back]!.material)
                    sideSelect.cube?.materials.append(shapeModel.cubeTextures[.Left]!.material)
                    sideSelect.cube?.materials.append(shapeModel.cubeTextures[.Top]!.material)
                    sideSelect.cube?.materials.append(shapeModel.cubeTextures[.Bottom]!.material)
                }
            }
            
        }
    }
    
    //the user taps on a face (side) of the shape to edit it
    func sendFaceCanvasRequest(_ gesture: UITapGestureRecognizer) {
        let callingView = gesture.location(in: sideSelector)
        let hitResults = sideSelector.hitTest(callingView)
        if let tappedFace = hitResults.first{
            let face = Constants.CubeFace(rawValue: tappedFace.geometryIndex)
            if face != nil {
                performSegue(withIdentifier: "annotateShape", sender: tappedFace)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let annotator = segue.destination as? CanvasEditorViewController {
            annotator.navigationItem.title = "Editor"
            annotator.cubeModel = shapeModel
            if let faceEditRequest = sender as? SCNHitTestResult {
                annotator.faceId = faceEditRequest.geometryIndex
            }
        }
    }
    
    
    
}
