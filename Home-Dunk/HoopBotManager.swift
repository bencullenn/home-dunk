//
//  HoopBotManager.swift
//  Home-Dunk
//
//  Created by Ben Cullen on 1/23/21.
//

import Foundation
import CoreBluetooth

let hoopBot = HoopBotManager()

class HoopBotManager {
    private var manager = BTManager()
    private var hoopBotDevice:BTDevice?
    private var statusString: String = ""
    private var devices: [BTDevice] = [] {
        //Checks if hoop bot was discovered every time array changes
        didSet{
            print("New devices discovered..")
            print(devices)
            if hoopBotDevice == nil{
                for device in self.devices {
                    if device.name == "ESP_Blinky_1800d9" {
                        self.hoopBotDevice = device
                        print("Set hoop_bot to \(String(describing: hoopBotDevice))")
                        hoopBotDevice?.connect()
                        
                    }
                }
            }
        }
    }
    
    required init?() {
        self.hoopBotDevice = nil
        manager.delegate = self
    }
    
    func updateStatusString(){
        statusString = "state: \(manager.state), scan: \(manager.scanning)"
    }
}

extension HoopBotManager: BTManagerDelegate {
    func didChangeState(state: CBManagerState) {
        devices = manager.devices
        updateStatusString()
    }

    func didDiscover(device: BTDevice) {
        print("Entered did discover")
        devices = manager.devices
        print("Found new devices")
        print(devices)
    }

    func didEnableScan(on: Bool) {
        updateStatusString()
    }
}
