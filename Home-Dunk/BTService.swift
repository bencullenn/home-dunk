//
//  BTService.swift
//  Hoop-Bot
//
//  Created by Ben Cullen on 1/18/21 using code Created by Ben Cullen on 1/18/21 using code from tutorial at https://www.raywenderlich.com/2164-arduino-tutorial-integrating-bluetooth-le-and-ios-with-swift
//

import Foundation
import CoreBluetooth

/* Services & Characteristics UUIDs */
let BLEServiceUUID = CBUUID(string: "025A7775-49AA-42BD-BBDB-E2AE77782966")
let PositionCharUUID = CBUUID(string: "F38A2C23-BC54-40FC-BED0-60EDDA139F47")
let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"

class BTService: NSObject, CBPeripheralDelegate {
  var peripheral: CBPeripheral?
  var positionCharacteristic: CBCharacteristic?
  
  init(initWithPeripheral peripheral: CBPeripheral) {
    super.init()
    
    self.peripheral = peripheral
    self.peripheral?.delegate = self
  }
  
  deinit {
    self.reset()
  }
  
  func startDiscoveringServices() {
    self.peripheral?.discoverServices([BLEServiceUUID])
  }
  
  func reset() {
    if peripheral != nil {
      peripheral = nil
    }
    
    // Deallocating therefore send notification
    self.sendBTServiceNotificationWithIsBluetoothConnected(false)
  }
  
  // Mark: - CBPeripheralDelegate
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    let uuidsForBTService: [CBUUID] = [PositionCharUUID]
    
    if (peripheral != self.peripheral) {
      // Wrong Peripheral
      return
    }
    
    if (error != nil) {
      return
    }
    
    if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
      // No Services
      return
    }
    
    for service in peripheral.services! {
      if service.uuid == BLEServiceUUID {
        peripheral.discoverCharacteristics(uuidsForBTService, for: service)
      }
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if (peripheral != self.peripheral) {
      // Wrong Peripheral
      return
    }
    
    if (error != nil) {
      return
    }
    
    if let characteristics = service.characteristics {
      for characteristic in characteristics {
        if characteristic.uuid == PositionCharUUID {
          self.positionCharacteristic = (characteristic)
          peripheral.setNotifyValue(true, for: characteristic)
          
          // Send notification that Bluetooth is connected and all required characteristics are discovered
          self.sendBTServiceNotificationWithIsBluetoothConnected(true)
        }
      }
    }
  }
  
  // Mark: - Private
  
  func writePosition(_ position: UInt8) {
    
    /******** (1) CODE TO BE ADDED *******/
    
  }
  
  func sendBTServiceNotificationWithIsBluetoothConnected(_ isBluetoothConnected: Bool) {
    let connectionDetails = ["isConnected": isBluetoothConnected]
    NotificationCenter.default.post(name: Notification.Name(rawValue: BLEServiceChangedStatusNotification), object: self, userInfo: connectionDetails)
  }
  
}
