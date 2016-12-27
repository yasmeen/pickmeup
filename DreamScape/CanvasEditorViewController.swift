//
//  CanvasEditorViewController.swift
//  DreamScape
//
//  Created by mjhowell on 12/25/16.
//  Copyright © 2016 Morgan. All rights reserved.
//

import UIKit

class CanvasEditorViewController: UIViewController {
    
    weak var cubeModel : CubeAnnotationsModel?
    var faceId : Int?
    
    @IBOutlet weak var paintButton: UIButton!
    @IBOutlet weak var surfaceLabel: UILabel!
    @IBOutlet weak var undoButton: UIButton!
    @IBInspectable
    var borderColor : UIColor = UIColor.gray
    
    var lastPoint: CGPoint!
    var isSwiping: Bool!
    var currentColor : RGB!
    
    @IBOutlet weak var canvas: UIImageView! {
        didSet {
            canvas.layer.borderColor = borderColor.cgColor
            canvas.layer.borderWidth = 3.0
            restorePreviousMask()
        }
    }
    
    //precondition: the model has been loaded with all six materials owned by the cube
    var currentFace : CubeAnnotationsModel.CubeFace {
        get {
            if faceId != nil {
                return CubeAnnotationsModel.CubeFace(rawValue: faceId!)!
            } else {
                return CubeAnnotationsModel.CubeFace(rawValue: 0)!
            }
        }
    }
    
    //restore the canvas to the selected material -- default/blank is white
    //precondition: the model has been loaded with all six materials owned by the cube
    func restorePreviousMask() {
        if (cubeModel?.cubeTextures[currentFace]!.recycled)! {
            if let material = cubeModel?.cubeTextures[currentFace]?.material {
                canvas.image = material.diffuse.contents as? UIImage
            }
        } else {
            clearCanvas()
        }
    }
    
    //if the user submits their canvas, the new painting will replace the old material
    @IBAction func submitAnnotation(_ sender: UIButton) {
        if faceId != nil && canvas != nil {
            cubeModel?.setFace(currentFace, with: canvas.image!)
        }
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    

    //clear last stroke
    @IBAction func clearCanvas() {
        UIGraphicsBeginImageContext(self.canvas.frame.size)
        UIGraphicsGetCurrentContext()?.setFillColor(UIColor.white.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: self.canvas.frame.size.width, height: self.canvas.frame.size.height))
        canvas.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //we can now safely recycle this material for future manipulations
        cubeModel?.cubeTextures[currentFace]?.recycled = true
    }
    
    
    //dictionary containg color/eraser mappings
    struct RGB {
        let red : CGFloat
        let green: CGFloat
        let blue: CGFloat
    }
    
    let colorMapping: Dictionary<String, RGB> = [
        "black" : RGB(red: 0.0, green: 0.0, blue: 0.0),
        "blue": RGB(red: 0.0, green: 0.0, blue: 255.0),
        "yellow": RGB(red: 240.0, green: 230.0, blue: 0.0),
        "green": RGB(red: 0.0, green: 255.0, blue: 0.0),
        "red": RGB(red: 255.0, green: 0.0, blue: 0.0),
        "eraser": RGB(red: 255.0, green: 255.0, blue: 255.0)
    ]
    
    
    @IBAction func selectColor(_ sender: UIButton) {
        if let nextColor = sender.currentTitle {
            currentColor = colorMapping[nextColor]
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        paintButton.layer.cornerRadius = 10
        paintButton.clipsToBounds = true
        paintButton.layer.borderColor = UIColor.gray.cgColor
        paintButton.layer.borderWidth = 2.0
        undoButton.layer.borderColor = UIColor.gray.cgColor
        undoButton.layer.borderWidth = 2.0
        undoButton.layer.cornerRadius = 10
        undoButton.clipsToBounds = true
        currentColor = colorMapping["black"]
        
        if faceId != nil {
            surfaceLabel.text! += " \(faceId!+1)"
        }
    }
    


    //Touch event listeners
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?){
        isSwiping    = false
        if let touch = touches.first{
            lastPoint = touch.location(in: canvas)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?){
        
        isSwiping = true;
        if let touch = touches.first{
            let currentPoint = touch.location(in: canvas)
            UIGraphicsBeginImageContext(self.canvas.frame.size)
            self.canvas.image?.draw(in: CGRect(x: 0, y: 0, width: self.canvas.frame.size.width, height: self.canvas.frame.size.height))
            UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
            UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
            UIGraphicsGetCurrentContext()?.setLineWidth(9.0)
            if currentColor != nil {
                UIGraphicsGetCurrentContext()?.setStrokeColor(red: currentColor!.red, green: currentColor!.green, blue: currentColor!.blue, alpha: 1.0)
            }
            UIGraphicsGetCurrentContext()?.strokePath()
            canvas.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?){
        if(!isSwiping) {
            // This is a single touch, draw a point
            UIGraphicsBeginImageContext(self.canvas.frame.size)
            canvas.image?.draw(in: CGRect(x: 0, y: 0, width: self.canvas.frame.size.width, height: self.canvas.frame.size.height))
            UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
            UIGraphicsGetCurrentContext()?.setLineWidth(9.0)
            if currentColor != nil {
                UIGraphicsGetCurrentContext()?.setStrokeColor(red: currentColor!.red, green: currentColor!.green, blue: currentColor!.blue, alpha: 1.0)
            }
            UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.strokePath()
            canvas.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }

}
