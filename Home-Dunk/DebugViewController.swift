//
//  DebugViewController.swift
//  Home-Dunk
//
//  Created by Ben Cullen on 1/23/21.
//

import UIKit

class DebugViewController: UIViewController {
    
    @IBOutlet weak var devNameLabel: UILabel!
    @IBOutlet weak var devDescriptionLabel: UILabel!
    @IBOutlet weak var managerLabel: UILabel!
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var blinkSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func updateBlinkStatus(_ sender: Any) {
        hoopBot?.updateBlink(blinkSwitch.isOn)
    }
    
    @IBAction func updateInformation(_ sender: Any) {
        print("Checking for more updated information")
        devNameLabel.text = hoopBot?.getDeviceName()
        devDescriptionLabel.text = hoopBot?.getDeviceDetails()
        managerLabel.text = hoopBot?.getManagerStatus()
        connectionLabel.text = hoopBot?.getConnectionStatus()
    }
}
