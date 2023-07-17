//
//  BluetoothManager.swift
//  BlueToothTest
//
//  Created by 彭祖鑫 on 2023/7/4.
//

import Foundation
import CoreBluetooth
import UserNotifications

@objc protocol BluetoothManagerDelegate: AnyObject {
    @objc optional func bluetoothStateChanged(state: CBManagerState)
    func discoveredPeripheral(peripheral: CBPeripheral)
    func connectedToDevice(peripheral: CBPeripheral)
    @objc optional func discoveredCharacteristic(service: CBService)
    func receivedData(characteristic: CBCharacteristic)
    func sendDataSuccess()
    func sendDataFailure(error: Error)
}


class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    static let shared = BluetoothManager()

     var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    
    weak var delegate: BluetoothManagerDelegate?
    
    

    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth is not enabled.")
            return
        }
//        centralManager.scanForPeripherals(withServices: nil, options: nil)

        centralManager.scanForPeripherals(withServices: [CBUUID.init(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")], options: nil)
//        centralManager.scanForPeripherals(withServices: [CBUUID.init(string: "0xFF01")], options: nil)

    }
    
    func stopScanning() {
        centralManager.stopScan()
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            connectedPeripheral = nil
        }
    }
    
    func sendBluetoothDisconnectedNotification() {
           let content = UNMutableNotificationContent()
           content.title = "蓝牙连接断开"
           content.body = "蓝牙连接已断开，请重新连接设备。"
           content.sound = .default
           
           let request = UNNotificationRequest(identifier: "BluetoothDisconnectedNotification", content: content, trigger: nil)
           UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
       }
    
    func sendData(data: Data, characteristicUUID: CBUUID) {
        if let peripheral = connectedPeripheral {
            if let characteristic = findCharacteristic(peripheral: peripheral, serviceUUID: nil, characteristicUUID: characteristicUUID) {
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            } else {
                // 特征未找到
                delegate?.sendDataFailure(error: NSError(domain: "YourApp", code: 0, userInfo: [NSLocalizedDescriptionKey: "Characteristic not found"]))
            }
        } else {
            // 外设未连接
            delegate?.sendDataFailure(error: NSError(domain: "YourApp", code: 0, userInfo: [NSLocalizedDescriptionKey: "Peripheral not connected"]))
        }
    }

    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .unknown:
            print("未知的")
        case .resetting:
            print("重置中")
        case .unsupported:
            print("不支持")
        case .unauthorized:
            print("无权限")
        case .poweredOff:
            print("未启动")
        case .poweredOn:
            print("可用")
        @unknown default: break
            
        }
        delegate?.bluetoothStateChanged?(state: central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        delegate?.discoveredPeripheral(peripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        connectedPeripheral = peripheral
        delegate?.connectedToDevice(peripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        centralManager.connect(peripheral)

        sendBluetoothDisconnectedNotification()

//        connectedPeripheral = nil
    }
    
    
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                print("service = \(service.uuid)")

                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        delegate?.discoveredCharacteristic?(service: service)
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                
                
                if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                    
                    print(" read characteristic = \(characteristic.uuid)")

                }
                if characteristic.properties.contains(.notify) {
        
                        print(" notify characteristic = \(characteristic)")
                        peripheral.setNotifyValue(true, for: characteristic)
                        

                }
                
                
             
                
                        

            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
//        print("characteristic = \(characteristic)")
        delegate?.receivedData(characteristic: characteristic)

    
        
    }
    
    // Peripheral代理方法 - 写数据操作的响应
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("发送数据错误: \(error.localizedDescription)")

        } else {
            print("数据发送成功")
        }
    }
    
    
    // MARK: - Helper Methods
    
    func findCharacteristic(peripheral: CBPeripheral, serviceUUID: CBUUID?, characteristicUUID: CBUUID) -> CBCharacteristic? {
        if let services = peripheral.services {
            for service in services {
                if serviceUUID == nil || service.uuid == serviceUUID {
                    if let characteristics = service.characteristics {
                        for characteristic in characteristics {
                            if characteristic.uuid == characteristicUUID {
                                return characteristic
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
}
