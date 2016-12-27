//
//  CanvasView.swift
//  DreamScape
//
//  Created by mjhowell on 12/25/16.
//  Copyright © 2016 Morgan. All rights reserved.
//

import UIKit
@IBDesignable
class CanvasView: UIImageView{
    
    @IBInspectable
    var borderColor : UIColor = UIColor.gray {didSet{setNeedsDisplay()}}
    override func draw(_ rect: CGRect) {
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 3.0

    }
}
