//
//  BTDiscovery.swift
//  Hoop-Bot
//
//  Created by Ben Cullen on 1/18/21 using code from tutorial at https://www.raywenderlich.com/2164-arduino-tutorial-integrating-bluetooth-le-and-ios-with-swift
//

import Foundation
import CoreBluetooth

let btDisoverySharedInstance = BTDiscovery()

class BTDiscovery: NSObject, CBCentralManagerDelegate{
    
    fileprivate var centralManager: CBCentralManager?
    fileprivate var peripheralBLE: CBPeripheral?
    
    override init(){
        super.init()
        
        let centralQueue = DispatchQueue(label: "com.bencullen", attributes: [])
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func startScanning() {
        if let central = centralManager {
            central.scanForPeripherals(withServices: [BLEServiceUUID], options: nil)
        }
    }
    
    var bleService: BTService? {
        didSet{
            if let service = self.bleService {
                service.startDiscoveringServices()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
      // Be sure to retain the peripheral or it will fail during connection.
      
      // Validate peripheral information
      if ((peripheral.name == nil) || (peripheral.name == "")) {
        return
      }
      
      // If not already connected to a peripheral, then connect to this one
      if ((self.peripheralBLE == nil) || (self.peripheralBLE?.state == CBPeripheralState.disconnected)) {
        // Retain the peripheral before trying to connect
        self.peripheralBLE = peripheral
        
        // Reset service
        self.bleService = nil
        
        // Connect to peripheral
        central.connect(peripheral, options: nil)
      }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      
      // Create new service class
      if (peripheral == self.peripheralBLE) {
        self.bleService = BTService(initWithPeripheral: peripheral)
      }
      
      // Stop scanning for new devices
      central.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
      
      // See if it was our peripheral that disconnected
      if (peripheral == self.peripheralBLE) {
        self.bleService = nil;
        self.peripheralBLE = nil;
      }
      
      // Start scanning for new devices
      self.startScanning()
    }
    
    // MARK: - Private
    
    func clearDevices() {
      self.bleService = nil
      self.peripheralBLE = nil
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
      switch (central.state) {
      case .poweredOff:
        self.clearDevices()
        
      case .unauthorized:
        // Indicate to user that the iOS device does not support BLE.
        print("Device does not support bluetooth connection ability with robot")
        break
        
      case .unknown:
        // Wait for another event
        break
        
      case .poweredOn:
        self.startScanning()
        
      case .resetting:
        self.clearDevices()
        
      case .unsupported:
        break
      }
    }

  }
