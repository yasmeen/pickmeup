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
import CoreMotion

//TODO: size of the scene's frame is interfering with the swipe gestures

class DiscoveryLensViewController: UIViewController {
    
    // change to let and non-static when server-side code is written
    static var discoveryLensModel: DiscoveryLensModel = DiscoveryLensModel()
    
    //session feed state
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var sceneView = SCNView()
    
    //core motion state
    var motionManager: CMMotionManager = CMMotionManager()
    var motionDisplayLink: CADisplayLink?
    var motionLastYaw: Float?
    var motionQueue: OperationQueue = OperationQueue()
    
    //sample to play with more basic AR with 2D images
    //@IBOutlet weak var imageView: UIImageView!
    
    //nodes in scenekit hierarchy that represent discovered shapes and the single
    //camera node that should align with the video feed and approximate user movement adjustments
    static var discoveredShapes: [SCNNode]?
    static var sceneKitCamera: SCNNode?
    
    
    
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
    
//    func motionRefresh(_ sender: Any?) {
//        
//        let quat: CMQuaternion = self.motionManager.deviceMotion!.attitude.quaternion
//        let yaw: Double = asin(2*(quat.x*quat.z - quat.w*quat.y));
//        
//        //Kalman-filter implementation for smoother yaw values
//        if (self.motionLastYaw == 0) {
//            self.motionLastYaw = Float(yaw);
//        }
//        
//        let q: Float = 0.1;   // process noise
//        let r: Float = 0.1;   // sensor noise
//        var p: Float = 0.1;   // estimated error
//        var k: Float = 0.5;   // kalman filter gain
//        
//        var x: Float = self.motionLastYaw ?? 0.0;
//        p = p + q;
//        k = p / (p + r);
//        x = x + k*(Float(yaw) - x);
//        p = (1 - k)*p;
//        self.motionLastYaw = x;
//        print("YAW: \(self.motionLastYaw)")
//        
//    }
    
    
    func motionRefresh(gyroData: CMGyroData?, hasError error: Error?) {
        print(gyroData?.rotationRate.y ?? 0.0)
    }
    
    
    //convert from the core motion reference frame to the scene kit's reference frame
    func orientationFromCMQuaternion(q: CMQuaternion) -> SCNQuaternion {
        let gq1: GLKQuaternion =  GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(-90), 1, 0, 0) // add a rotation of the pitch 90 degrees
        let gq2: GLKQuaternion =  GLKQuaternionMake(Float(q.x), Float(q.y), Float(q.z), Float(q.w)) // the current orientation
        let qp: GLKQuaternion  =  GLKQuaternionMultiply(gq1, gq2) // get the "new" orientation
        let rq: CMQuaternion =   CMQuaternion(x: Double(qp.x), y: Double(qp.y), z: Double(qp.z), w: Double(qp.w))
        return SCNVector4Make(Float(rq.x), Float(rq.y), Float(rq.z), Float(rq.w));
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.motionManager.startDeviceMotionUpdates(to: motionQueue) {
            [weak self] (motion: CMDeviceMotion?, error: Error?) in
            let attitude: CMAttitude = motion!.attitude
            //lock scene kit mutex
            SCNTransaction.begin()
            SCNTransaction.disableActions = true
            let quaternion: SCNQuaternion = self!.orientationFromCMQuaternion(q: attitude.quaternion)
            DiscoveryLensViewController.sceneKitCamera?.orientation = quaternion
            SCNTransaction.commit()
        }
        
        //self.motionManager.deviceMotionUpdateInterval = 0.02 // 50Hz
        
//        self.motionDisplayLink = CADisplayLink(target: self,
//                                               selector: #selector(DiscoveryLensViewController.motionRefresh(_:)))
//        
//        self.motionDisplayLink?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
//        
//        if self.motionManager.isDeviceMotionAvailable {
//            self.motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryZVertical)
//        }
        
//        if self.motionManager.isGyroAvailable {
//            self.motionManager.gyroUpdateInterval = 0.1
//            self.motionManager.startGyroUpdates(to: OperationQueue.main, withHandler: self.motionRefresh)
//            
//        }
        
        
        
//        if self.motionManager.isAccelerometerAvailable {
//            self.motionManager.accelerometerUpdateInterval = 0.01
//            self.motionManager.startAccelerometerUpdates(to: OperationQueue.main) {
//                [weak self] (data: CMAccelerometerData?, error: Error?) in
//                if let acceleration = data?.acceleration {
//                    let rotation = atan2(acceleration.x, acceleration.y) - M_PI
//                    
//                    
//                    if let nodes : [SCNNode] = DiscoveryLensViewController.discoveredShapes {
//                        for node : SCNNode in nodes {
//                            //node.transform = SCNMatrix4MakeRotation(<#T##angle: Float##Float#>, <#T##x: Float##Float#>, <#T##y: Float##Float#>, <#T##z: Float##Float#>)
//                                //CGAffineTransform(rotationAngle: CGFloat(rotation))
//                            
//                            //node.eulerAngles = SCNVector3(
//                        }
//                    }
//                    
//                    
//                }
//            }
//        }
        
//        if self.motionManager.isDeviceMotionAvailable {
//            self.motionManager.deviceMotionUpdateInterval = 0.01
//            self.motionManager.startDeviceMotionUpdates(to: OperationQueue.main) {
//                /*[weak self]*/ (motion: CMDeviceMotion?, error: Error?) in
//                
//                if let currentAttitude = motion?.attitude {
//                    let roll = Float(currentAttitude.roll) + (0.5*Float.pi)
//                    let yaw = Float(currentAttitude.yaw)
//                    let pitch = Float(currentAttitude.pitch)
//                    print("roll \(roll)")
//                    print("yaw \(yaw)")
//                    print("pitch \(pitch)")
//                    
//                    DiscoveryLensViewController.sceneKitCamera!.eulerAngles = SCNVector3(
//                        x: -roll*0.25,
//                        y: yaw*0.25,
//                        z: -pitch*0.25)
//                    
//                } else {
//                    print("Error unwrapping motion")
//                }
        
        
//                if let gravity = data?.gravity {
//                        print("x: \(gravity.x)")
//                        print("y: \(gravity.y)")
//                        print("z: \(gravity.z)")
//
//                    if let gravity = data?.gravity {
//                        let rotation = Float(atan2(gravity.x, gravity.y)) - Float.pi
//                        
//                        self?.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
//                        
//
//                    } else {
//                        //TODO: Add an option to play in Non-AR mode
//                        print("Error retrieving gravity")
//                    }
//            }
//        }
        
        
        

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraViewOverlaySession()
        //sending test image views to front
        //cameraView.bringSubview(toFront: imageView)
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
            //testing default cube with images affixed as materials
            var images: [UIImage] = Array()
            images.append(UIImage(named: "AR_Sample")!)
            images.append(UIImage(named: "AR_Sample2")!)
            sceneView.scene = DiscoveryScene(scale: 1.0, withShape: Constants.Shape.Cube, withImages: images)
        } else {
            print("No shape could be fetched in the DiscoveryLens Controller from the DiscoveryLens model")
            
        }
    }
    
    //link nodes from scene blueprint to Discovery Lens Controller
    public static func addDiscoveredShapeNode(shape: SCNNode) {
        if DiscoveryLensViewController.discoveredShapes == nil {
            DiscoveryLensViewController.discoveredShapes = Array()
        }
        DiscoveryLensViewController.discoveredShapes?.append(shape)
    }
    
    public static func addCameraNode(camera: SCNNode) {
        DiscoveryLensViewController.sceneKitCamera = camera
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
