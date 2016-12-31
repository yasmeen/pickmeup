//
//  DiscoveryLensViewController.swift
//  DreamScape
//
//  Created by mjhowell on 12/26/16.
//  Copyright © 2016 Morgan. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import SceneKit

//TODO: size of the scene's frame is interfering with the swipe gestures

class DiscoveryLensViewController: UIViewController {
    
    // change to let and non-static when server-side code is written
    static var discoveryLensModel: DiscoveryLensModel = DiscoveryLensModel()
    
    //session feed state
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var sceneView = SCNView()
    
    @IBOutlet var discoverySuperView: UIView! {
        didSet {
            
            //set gestures for tab view control
            let swipeLeftGesture = UISwipeGestureRecognizer (
                target: self,
                action: #selector(DiscoveryLensViewController.tabRight(_:))
            )
            swipeLeftGesture.direction = .left
            discoverySuperView.addGestureRecognizer(swipeLeftGesture)
            
            let swipeRightGesture = UISwipeGestureRecognizer (
                target: self,
                action: #selector(DiscoveryLensViewController.tabLeft(_:))
            )
            swipeRightGesture.direction = .right
            discoverySuperView.addGestureRecognizer(swipeRightGesture)
            
            discoverySuperView.setNeedsDisplay()
        }
    }
    
    
    @IBOutlet weak var cameraView: CameraDiscoveryLensView!
    
    func tabLeft(_ swipeRight: UISwipeGestureRecognizer) {
        self.tabBarController?.selectedIndex -= 1
    }
    
    func tabRight(_ swipeLeft: UISwipeGestureRecognizer) {
        self.tabBarController?.selectedIndex += 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraViewOverlaySession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Constants.SPOOF_SERVER {
            shapeDiscovered()
        }
        
        //tab bar item appearance under this specific controller
        self.tabBarController?.tabBar.tintColor = UIColor(
            colorLiteralRed: Constants.DEFAULT_BLUE[0],
            green: Constants.DEFAULT_BLUE[1],
            blue: Constants.DEFAULT_BLUE[2],
            alpha: Constants.DEFAULT_BLUE[3])
        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor.white
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneView.removeFromSuperview()
    }
    
    
    //initializing the feed session and affixing it as a sublayer of the CameraDiscoveryLensView layer
    func cameraViewOverlaySession() {
        let deviceSession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInDualCamera,.builtInTelephotoCamera,.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified)
        
        for device in (deviceSession?.devices)! {
            
            if device.position == AVCaptureDevicePosition.back {
                
                do {

                    let input = try AVCaptureDeviceInput(device: device)
                    
                    if captureSession.canAddInput(input){
                        captureSession.addInput(input)
                        
                        if captureSession.canAddOutput(sessionOutput){
                            captureSession.addOutput(sessionOutput)
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                            previewLayer.connection.videoOrientation = .portrait
                            cameraView.layer.addSublayer(previewLayer)
                            previewLayer.position = CGPoint (x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
                            previewLayer.bounds = cameraView.frame
                            captureSession.startRunning()
                        }
                    }
                    
                } catch let avError { print(avError)}
            }
        }
    }
    
    
    //callback from server request when shape or landmark proximity is detected
    //when testing this controller and in the protoype (before server requests) this will be called 
    //to create a static cube in viewDidLoad
    func shapeDiscovered() {
        if let shape = DiscoveryLensViewController.discoveryLensModel.currentDiscoveredShape {
            if(Constants.DEBUG_MODE) {
                print("DEBUG INFO- Cube loaded from Canvas Editor")
            }
            //we create the scene view, which will serve as a container for the actual scene
            sceneView = SCNView()
            sceneView.frame = self.view.bounds
            sceneView.backgroundColor = UIColor.clear
            sceneView.autoenablesDefaultLighting = true
            sceneView.allowsCameraControl = true //in the future, we may want to disable this in discovery mode
            self.view.addSubview(sceneView)
            sceneView.scene = shape.scene
        //loads blank stub shape
        } else if Constants.DEBUG_MODE && Constants.SPOOF_SERVER {
            print("DEBUG INFO- Stub cube loaded into camera view")
            //we create the scene view, which will serve as a container for the actual scene
            sceneView = SCNView()
            sceneView.frame = self.view.bounds
            sceneView.backgroundColor = UIColor.clear
            sceneView.autoenablesDefaultLighting = true
            sceneView.allowsCameraControl = true //in the future, we may want to disable this in discovery mode
            self.view.addSubview(sceneView)
            sceneView.scene = DiscoveryScene(scale: 1.0, withShape: Constants.Shape.Cube, withMaterials: [])
        } else {
            print("No shape could be fetched in the DiscoveryLens Controller from the DiscoveryLens model")
            
        }
    }
    
    //converts the server response format of a shape into our model's format
    func updateModelShape() {
        //pass
        
    }
    
    //only used for server spoof mode to load shapes in from the Canvas Editor's model
    //communication of this form is not proper and will be deleted once the server-side code is written
    public static func updateModel(discoveryLensModel: DiscoveryLensModel) {
        if Constants.DEBUG_MODE && Constants.SPOOF_SERVER {
            DiscoveryLensViewController.discoveryLensModel = discoveryLensModel
        } else {
            print("Error- This model to model communication is not permitted")
        }
    }
    
    
    
}
