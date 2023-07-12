//
//  ViewController.swift
//  PCBlueToothDemo
//
//  Created by 彭祖鑫 on 2023/7/7.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,BluetoothManagerDelegate {

    

    @IBOutlet weak var tableView: UITableView!
    
    var isEnable = false
    
    var discoveredPeripheralsArr :[CBPeripheral?] = []

    
    @IBOutlet weak var jumpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        BluetoothManager.shared.delegate = self

        
        
    }
    
    
    @IBAction func jumpToMyPeripheralButtonPressed(_ sender: UIButton) {
        
        let vc : MyPeripheralViewController = UIStoryboard.init(name: "MyPeripheralViewController", bundle: nil).instantiateViewController(withIdentifier: "MyPeripheralViewController") as! MyPeripheralViewController;
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func scanButtonPressed(_ sender: UIButton) {
        
        
        BluetoothManager.shared.startScanning()
        
        
    }
    
    func bluetoothStateChanged(state: CBManagerState) {
        
        switch state {
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
            
            isEnable = true
            
        @unknown default: break
            
        }
        
            
    }
    
    func discoveredPeripheral(peripheral: CBPeripheral) {
        
        
        self.jumpButton.isHidden = false
        //过滤存在的蓝牙外设
             var isExisted = false
             for obtainedPeriphal  in discoveredPeripheralsArr {
                 if (obtainedPeriphal?.identifier == peripheral.identifier){
                     isExisted = true
                 
                 }
             }
             if !isExisted && peripheral.name != nil{
                 discoveredPeripheralsArr.append(peripheral)
                 
                 tableView.reloadData()
             }

        
        
        
    }
    
    func connectedToDevice(peripheral: CBPeripheral) {
        
    }
    
    func receivedData(characteristic: CBCharacteristic) {
        
    }
    
    func sendDataSuccess() {
        
    }
    
    func sendDataFailure(error: Error) {
        
    }
    
    




}

extension ViewController : UITableViewDelegate,UITableViewDataSource {
   
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return discoveredPeripheralsArr.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        let peripheral: CBPeripheral = discoveredPeripheralsArr[indexPath.row]!
        cell.textLabel?.text = peripheral.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let  alert = UIAlertController(title: "提示", message: "是否添加该设备", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "是的", style: .default) { [self] action in
            
            
            debugPrint("是的")
            
            
            let peripheral: CBPeripheral = discoveredPeripheralsArr[indexPath.row]!
            
            peripheralSaveManager().addPeripheral(peripheral: peripheral)
            
//            let peripheral: CBPeripheral = discoveredPeripheralsArr[indexPath.row]!
//
//            UserDefaults.standard.value(forKey: peripheralArray)
//
//            UserDefaults.standard.set("", forKey: peripheralArray)
//
//            savePeripheral(peripheral, forKey: "SavedPeripheral")

            
        }
        let cancel = UIAlertAction(title: "取消", style: .default) { action in
            
            debugPrint("取消")
            let array : Array<String> = peripheralSaveManager().getPeripheralArray()

            let peripheralUUID = UUID(uuidString: array[0])!
            let peripheral = BluetoothManager.shared.centralManager.retrievePeripherals(withIdentifiers: [peripheralUUID]).first
            
            print(peripheral!)

            
            

        }
        
        
        alert.addAction(ok)
        alert.addAction(cancel)

        self.present(alert, animated: true)
        
        
    }
    
}

