//
//  DropSettingsViewController.swift
//  MakeDrop
//
//  Created by mjhowell on 1/3/17.
//  Copyright © 2017 Morgan. All rights reserved.
//

import UIKit

class DropSettingsViewController: UIViewController {
    
    @IBOutlet weak var saveSettings: UIButton! {
        didSet {
            saveSettings.layer.cornerRadius = 10
            saveSettings.clipsToBounds = true
            saveSettings.layer.borderWidth = 2.0
            saveSettings.layer.borderColor = UIColor.gray.cgColor
        }
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
