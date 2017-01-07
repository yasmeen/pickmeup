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
    
    //initially contains no discovered shapes, however shapes will eventually populate according to user proximity
    //struct for now because of server spoofing, once the API calls can be made, this below should be an instance variable
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
    
    //timer state for async pinging of the MakeDrop Discovery API
    private let kTimeoutInSeconds:TimeInterval = Constants.PING_DISCOVERY_API_INTERVAL
    private var timer: Timer?
    private var lastRequestReturned = true

    
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
        startSceneKitReferenceConversion()
    }
    
    func startSceneKitReferenceConversion() {
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
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraViewOverlaySession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Constants.SPOOF_SERVER {
            shapeDiscovered()
        } else {
            startFetching()
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
        if !Constants.SPOOF_SERVER {
            stopFetching()
        }
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
        if DiscoveryLensViewController.discoveryLensModel.hasShapesInFieldOfView(){
            //under debugging and server spoof mode, we simply load the shape that is currently in the editor
            if(Constants.DEBUG_MODE && Constants.SPOOF_SERVER) {
                print("DEBUG INFO- Cube loaded from Canvas Editor")
                sceneView = SCNView()
                sceneView.frame = self.view.bounds
                sceneView.backgroundColor = UIColor.clear
                sceneView.autoenablesDefaultLighting = true
                sceneView.allowsCameraControl = true //in the future, we may want to disable this in discovery mode
                self.view.addSubview(sceneView)
                //TODO: scene blow does not contain a cube
                sceneView.scene = DiscoveryLensViewController.discoveryLensModel.scene
            }
            
        //loads blank stub shape
        } else if Constants.DEBUG_MODE && Constants.SPOOF_SERVER {
            print("DEBUG INFO- Stub cube loaded into camera view")
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
    
    
    func formProximityRequest() -> NSMutableURLRequest {
        let jsonBody: Dictionary<String, String> = ["lat": GlobalResources.Location.lat ,
                                                    "long": GlobalResources.Location.long]
        var jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
        } catch {
            print("ERROR - Formatting JSON for drop request")
        }
        
        if(Constants.DEBUG_MODE) {
            Constants.printJSONDataReadable(json: jsonData, to: Constants.DISCOVER_SHAPES_ENDPOINT)
        }
        
        let url: URL = NSURL(string: Constants.DISCOVER_SHAPES_ENDPOINT)! as URL
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    
    //Requesting the MakeDrop Discovery API to send nearby shapes
    func requestProximity() {
        if lastRequestReturned {
            DispatchQueue.global(qos: .utility).async { [weak self] in
                //We are accessing a shared context below, but it is OK if multiple threads enter the critical region below
                //we simply need some sort of throttle in case the network requests take more time than intended
                self?.lastRequestReturned = false
                if let request = self?.formProximityRequest() {
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
                            print("ERROR - Failed to ping the discovery APIs for nearby objects")
                        }
                    }
                    task.resume()
                }
                self?.lastRequestReturned = true
            }
        }
    }
    
    //initiate discovery mode, which pings the MakeDrop API for nearby shapes
    func startFetching() {
        self.timer = Timer.scheduledTimer(timeInterval: self.kTimeoutInSeconds,
                                          target: self,
                                          selector: #selector(DiscoveryLensViewController.requestProximity),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    func stopFetching() {
        self.timer!.invalidate()
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
