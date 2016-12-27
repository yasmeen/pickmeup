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

class DiscoveryLensViewController: UIViewController {
    
    //session feed state
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    
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
    
    
    @IBOutlet weak var cameraView: UIView!
       
    var newMedia: Bool?
    
    
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
                    
                    
                } catch let avError {
                    print(avError)
                }
                
                
            }
            
        }
        
    }

    
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        //camera session preparation
//        session = AVCaptureSession()
//       // var backCameraDevice: AVCaptureDevice? = nil
//        //var frontCameraDevice: AVCaptureDevice? = nil
//        
//        let backCameraDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
//        
////        for device in [availableCameraDevices!] {
////            if device.position == .back {
////                backCameraDevice = device
////            }
////            //below should be implemented if we want to enable "selfie" mode
//////            else if device.position == .front {
//////                frontCameraDevice = device
//////            }
////        }
//        
//        if backCameraDevice != nil {
//            let backCameraInput = try? AVCaptureDeviceInput(device: backCameraDevice!)
//            if (backCameraInput != nil &&  (self.session?.canAddInput(backCameraInput))!) {
//                self.session?.addInput(backCameraInput)
//            } else {
//                print("Camera Input Malfunction")
//            }
//        }
//        
//        videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: session) as AVCaptureVideoPreviewLayer
//        videoPreviewLayer?.frame = discoverySuperView.bounds
//        //discoverySuperView.layer.addSublayer(videoPreviewLayer!)
//        
//        
//  
//        
//
//            
//            //should not have to worry about the segment below (for now) because permissions is specified in plist
////            let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
////            switch authorizationStatus {
////            case .notDetermined:
////                // permission dialog not yet presented, request authorization
////                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo,
////                                                          completionHandler: { (granted:Bool) -> Void in
////                                                            if granted {
////                                                                // go ahead
////                                                            }
////                                                            else {
////                                                                // user denied, nothing much to do
////                                                            }
////                })
////            case .authorized:
////            // go ahead
////            case .denied, .restricted:
////                // the user explicitly denied camera usage or is not allowed to access the camera devices
////            }
//        
//        
//        
//        
//        
////        //camera session preparation
////        session = AVCaptureSession()
////        session!.sessionPreset = AVCaptureSessionPresetPhoto
////        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
////        var error: NSError?
////        var input: AVCaptureDeviceInput!
////        do {
////            input = try AVCaptureDeviceInput(device: backCamera)
////        } catch let error1 as NSError {
////            error = error1
////            input = nil
////            print(error!.localizedDescription)
////        }
////        
////        //once we have access priveleges, we can attach the input
////        if error == nil && session!.canAddInput(input) {
////            session!.addInput(input)
////            stillImageOutput = AVCapturePhotoOutput()
////            
////            let settings = [AVVideoCodecKey: AVVideoCodecJPEG]
////            
////            
////            let AVCaptureSettings : AVCapturePhotoSettings = AVCapturePhotoSettings(format: settings)
////            
////            
////            stillImageOutput!.
////            
////            if session!.canAddOutput(stillImageOutput) {
////                session!.addOutput(stillImageOutput)
////                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
////                videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
////                videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
////                cameraView.layer.addSublayer(videoPreviewLayer!)
////                session!.startRunning()
////            }
////            
////            
////        }
////        
//        
//        
//    }
//    
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
////        //videoPreviewLayer!.frame = cameraView.bounds
////        if UIImagePickerController.isSourceTypeAvailable(
////            UIImagePickerControllerSourceType.camera) {
////            
////            let imagePicker = UIImagePickerController()
////            
////            imagePicker.delegate = self
////            imagePicker.sourceType =
////                UIImagePickerControllerSourceType.camera
////            imagePicker.mediaTypes = [kUTTypeImage as String]
////            imagePicker.allowsEditing = false
////            
////            self.present(imagePicker, animated: true,
////                         completion: nil)
////            newMedia = true
////        }
//        
//        //camera session preparation
//        session = AVCaptureSession()
//        // var backCameraDevice: AVCaptureDevice? = nil
//        //var frontCameraDevice: AVCaptureDevice? = nil
//        
//        let backCameraDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
//        
//        //        for device in [availableCameraDevices!] {
//        //            if device.position == .back {
//        //                backCameraDevice = device
//        //            }
//        //            //below should be implemented if we want to enable "selfie" mode
//        ////            else if device.position == .front {
//        ////                frontCameraDevice = device
//        ////            }
//        //        }
//        
//        if backCameraDevice != nil {
//            let backCameraInput = try? AVCaptureDeviceInput(device: backCameraDevice!)
//            if (backCameraInput != nil &&  (self.session?.canAddInput(backCameraInput))!) {
//                self.session?.addInput(backCameraInput)
//                print("Session added")
//            } else {
//                print("Camera Input Malfunction")
//            }
//        } else {
//            print("Could not find camera")
//        }
//        
//        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session) as AVCaptureVideoPreviewLayer
//        videoPreviewLayer?.frame = CGRect(origin: CGPoint(x: 0, y :0) , size: cameraView.frame.size)
//            //cameraView.bounds
//        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
//        videoPreviewLayer?.position = CGPoint(x: 0, y :0)
//        cameraView.layer.addSublayer(videoPreviewLayer!)
//        
////        let sublayer = CALayer()
////        sublayer.bounds = cameraView.bounds
////        sublayer.frame = CGRect(origin: CGPoint(x: 0, y :0) , size: cameraView.frame.size)
////        sublayer.contents = UIImage(named: "picker_eraser")?.cgImage
////        sublayer.position = CGPoint(x: 0, y :0)
////        if sublayer.contents == nil {
////            print("SHIT")
////        }
////        cameraView.layer.addSublayer(sublayer)
//        
//        
//        //let rect = CGRect(0,0,320,100)
////        let gradient = CAGradientLayer()
////        let cor1 = UIColor.black.cgColor
////        let cor2 = UIColor.white.cgColor
////        let arrayColors = [cor1, cor2]
////        gradient.colors = arrayColors
//     
////        
////        discoverySuperView.layer.insertSublayer(gradient, at: 0)
//        
//            //.addSublayer(videoPreviewLayer!)
//        //cameraView.setNeedsDisplay()
//    }
//    
////    
////    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
////        
////        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
////        
////        self.dismiss(animated: true, completion: nil)
////        
////        if mediaType.isEqual(to: kUTTypeImage as String) {
////            let image = info[UIImagePickerControllerOriginalImage]
////                as! UIImage
////            
////            cameraView.image = image
////            
////            if (newMedia == true) {
////                UIImageWriteToSavedPhotosAlbum(image, self,
////                                               #selector(DiscoveryLensViewController.image(image:didFinishSavingWithError:contextInfo:)), nil)
////            } else if mediaType.isEqual(to: kUTTypeMovie as String) {
////                // Code to support video here
////            }
////            
////        }
////    }
////    
////    @IBAction func useCameraRoll(_ sender: AnyObject) {
////        
////        if UIImagePickerController.isSourceTypeAvailable(
////            UIImagePickerControllerSourceType.savedPhotosAlbum) {
////            let imagePicker = UIImagePickerController()
////            
////            imagePicker.delegate = self
////            imagePicker.sourceType =
////                UIImagePickerControllerSourceType.photoLibrary
////            imagePicker.mediaTypes = [kUTTypeImage as String]
////            imagePicker.allowsEditing = false
////            self.present(imagePicker, animated: true,
////                         completion: nil)
////            newMedia = false
////        }
////    }
////    
////    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafeRawPointer) {
////        
////        if error != nil {
////            let alert = UIAlertController(title: "Save Failed",
////                                          message: "Failed to save image",
////                                          preferredStyle: UIAlertControllerStyle.alert)
////            
////            let cancelAction = UIAlertAction(title: "OK",
////                                             style: .cancel, handler: nil)
////            
////            alert.addAction(cancelAction)
////            self.present(alert, animated: true,
////                         completion: nil)
////        }
////    }
////    
////    
////    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
////        self.dismiss(animated: true, completion: nil)
////    }
////
//    
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */

}
