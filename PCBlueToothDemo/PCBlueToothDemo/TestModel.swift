//
//  TestModel.swift
//  UserDefultModelSave
//
//  Created by 彭祖鑫 on 2023/7/6.
//
import UIKit
import CoreBluetooth


let modelKey = "modelKey"



extension UserDefaults {
    func saveCodable<T: Codable>(_ value: T, forKey key: String) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(value)
            self.set(encodedData, forKey: key)
        } catch {
            print("Failed to encode \(T.self): \(error)")
        }
    }
    
    func retrieveCodable<T: Codable>(forKey key: String) -> T? {
        if let decodedData = self.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                let decodedObject = try decoder.decode(T.self, from: decodedData)
                return decodedObject
            } catch {
                print("Failed to decode \(T.self): \(error)")
            }
        }
        return nil
    }
}
