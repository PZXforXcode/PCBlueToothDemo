//
//  peripheralSaveManager.swift
//  PCBlueToothDemo
//
//  Created by 彭祖鑫 on 2023/7/7.
//

import Foundation
import UIKit
import CoreBluetooth


let peripheralArray = "peripheralArray"


class peripheralSaveManager {
    
    func getPeripheralArray() -> Array<String>{
        
        let array : Array = UserDefaults.standard.value(forKey: peripheralArray) as? Array<String> ?? []
        print(array);
        
        return array
        
        
        
    }
    
    func addPeripheral(peripheral : CBPeripheral){
        
                
        var array : Array = UserDefaults.standard.value(forKey: peripheralArray) as? Array<String> ?? []
        ///不加入重复值
        if (array.contains(peripheral.identifier.uuidString)) {
            return
        }
            array.append(peripheral.identifier.uuidString)
        UserDefaults.standard.set(array, forKey: peripheralArray)

    }

    
}
