//
//  BTDevice.swift
//  BLEDemo
//
//  Created by Jindrich Dolezy on 11/04/2018.
//  Copyright © 2018 Dzindra. All rights reserved.
//

import Foundation
import CoreBluetooth


protocol BTDeviceDelegate: class {
    func deviceConnected()
    func deviceReady()
    func deviceActiveGameChanged(value: Bool)
    func deviceScoreChanged(value: Int)
    func deviceSerialChanged(value: String)
    func deviceDisconnected()

}

class BTDevice: NSObject {
    private let peripheral: CBPeripheral
    private let manager: CBCentralManager
    private var activeGameChar: CBCharacteristic?
    private var scoreChar: CBCharacteristic?
    private var _activeGame: Bool = false
    private var _score: Int = 0
    
    weak var delegate: BTDeviceDelegate?
    
    var activeGame: Bool {
        get {
            return _activeGame
        }
        set {
            guard _activeGame != newValue else { return }
            
            _activeGame = newValue
            if let char = activeGameChar {
                peripheral.writeValue(Data(_: [_activeGame ? 1 : 0]), for: char, type: .withResponse)
            }
        }
    }
    
    var score: Int {
        get {
            return _score
        }
        set {
            guard _score != newValue else { return }
            
            _score = newValue
            if let char = scoreChar {
                peripheral.writeValue(Data(_: [UInt8(_score)]), for: char, type: .withResponse)
            }
        }
    }
    
    var name: String {
        return peripheral.name ?? "Unknown device"
    }
    var detail: String {
        return peripheral.identifier.description
    }
    private(set) var serial: String?
    
    init(peripheral: CBPeripheral, manager: CBCentralManager) {
        self.peripheral = peripheral
        self.manager = manager
        super.init()
        self.peripheral.delegate = self
    }
    
    func connect() {
        manager.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        manager.cancelPeripheralConnection(peripheral)
    }
}

extension BTDevice {
    // these are called from BTManager, do not call directly
    
    func connectedCallback() {
        peripheral.discoverServices([BTUUIDs.blinkService, BTUUIDs.infoService])
        delegate?.deviceConnected()
    }
    
    func disconnectedCallback() {
        delegate?.deviceDisconnected()
    }
    
    func errorCallback(error: Error?) {
        print("Device: error \(String(describing: error))")
    }
}


extension BTDevice: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Device: discovered services")
        peripheral.services?.forEach {
            print("  \($0)")
            if $0.uuid == BTUUIDs.infoService {
                peripheral.discoverCharacteristics([BTUUIDs.infoSerial], for: $0)
            } else if $0.uuid == BTUUIDs.blinkService {
                peripheral.discoverCharacteristics([BTUUIDs.activeGame,BTUUIDs.score], for: $0)
            } else {
                peripheral.discoverCharacteristics(nil, for: $0)
            }
            
        }
        print()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Device: discovered characteristics")
        service.characteristics?.forEach {
            print("   \($0)")
            
            if $0.uuid == BTUUIDs.activeGame {
                self.activeGameChar = $0
                peripheral.readValue(for: $0)
                peripheral.setNotifyValue(true, for: $0)
            } else if $0.uuid == BTUUIDs.score {
                self.scoreChar = $0
                peripheral.readValue(for: $0)
                peripheral.setNotifyValue(true, for: $0)
            } else if $0.uuid == BTUUIDs.infoSerial {
                peripheral.readValue(for: $0)
            }
        }
        print()
        
        delegate?.deviceReady()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Device: updated value for \(characteristic)")
        
        if characteristic.uuid == activeGameChar?.uuid, let b = characteristic.value?.parseBool() {
            _activeGame = b
            delegate?.deviceActiveGameChanged(value: b)
        }
        if characteristic.uuid == scoreChar?.uuid, let s = characteristic.value?.parseInt() {
            _score = Int(s)
            delegate?.deviceScoreChanged(value: _score)
        }
        if characteristic.uuid == BTUUIDs.infoSerial, let d = characteristic.value {
            serial = String(data: d, encoding: .utf8)
            if let serial = serial {
                delegate?.deviceSerialChanged(value: serial)
            }
        }
    }
}


