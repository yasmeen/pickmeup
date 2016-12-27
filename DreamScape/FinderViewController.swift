//
//  FinderViewController.swift
//  DreamScape
//
//  Created by mjhowell on 12/26/16.
//  Copyright © 2016 Morgan. All rights reserved.
//

import UIKit

class FinderViewController: UIViewController {

    @IBOutlet var finderSuperView: UIView! {
        didSet {
            //set gestures for tab view control
            let swipeLeftGesture = UISwipeGestureRecognizer (
                target: self,
                action: #selector(FinderViewController.tabRight(_:))
            )
            swipeLeftGesture.direction = .left
            finderSuperView.addGestureRecognizer(swipeLeftGesture)
        }
    }
    
    
    func tabRight(_ swipeLeft: UISwipeGestureRecognizer) {
        self.tabBarController?.selectedIndex += 1
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
