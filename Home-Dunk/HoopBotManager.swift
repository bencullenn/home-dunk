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
    private var hoopBotDevice:BTDevice? {
        didSet{
            hoopBotDevice?.delegate = self
        }
    }
    private var managerStatus: String = ""
    private var connectionStatus: String = "Disconnected"
    private var devices: [BTDevice] = [] {
        //Checks if hoop bot was discovered every time array changes
        didSet{
            print("New devices discovered..")
            print(devices)
            if hoopBotDevice == nil{
                for device in self.devices {
                    //FIXME: Update name to be whatever final hoop bot actually ends up being
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
    
    private func updateManagerStatus(){
        managerStatus = "state: \(manager.state), scan: \(manager.scanning)"
    }
    
    private func updateConnectionStatus(_ status:String){
        print("Updating connection status to \(status)")
        connectionStatus = status
    }
    
    func updateBlink(_ status:Bool){
        print("Blink status updated to \(status)")
        hoopBotDevice?.blink = status
    }
    
    func getConnectionStatus() -> String {
        return connectionStatus
    }
    
    func getManagerStatus() -> String {
        return managerStatus
    }
    
    func getDeviceName() -> String {
        return hoopBotDevice?.name ?? "No device name exists"
    }
    
    func getDeviceDetails() -> String {
        return hoopBotDevice?.description ?? "No device description exists"
    }
    
}

extension HoopBotManager: BTManagerDelegate {
    func didChangeState(state: CBManagerState) {
        devices = manager.devices
        updateManagerStatus()
    }

    func didDiscover(device: BTDevice) {
        print("Entered did discover")
        devices = manager.devices
        print("Found new devices")
        print(devices)
    }

    func didEnableScan(on: Bool) {
        updateManagerStatus()
    }
}


extension HoopBotManager: BTDeviceDelegate {
    func deviceSerialChanged(value: String) {
        print("Device serial changed to \(value)")
    }
    
    func deviceSpeedChanged(value: Int) {
        print("Device speed changed to \(value)")
    }
    
    func deviceConnected() {
        updateConnectionStatus("Connecting")
    }
    
    func deviceDisconnected() {
        updateConnectionStatus("Disconnected")
    }
    
    func deviceReady() {
        updateConnectionStatus("Ready")
    }
    
    func deviceBlinkChanged(value: Bool) {
        print("Device blink changed to \(value)")
        
        /*
         Code that could be used to send out notifications from app if needed
        if UIApplication.shared.applicationState == .background {
            let content = UNMutableNotificationContent()
            content.title = "ESP Blinky"
            content.body = value ? "Now blinking" : "Not blinking anymore"
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("DeviceVC: failed to deliver notification \(error)")
                }
            }
        }
        */
    }
}
