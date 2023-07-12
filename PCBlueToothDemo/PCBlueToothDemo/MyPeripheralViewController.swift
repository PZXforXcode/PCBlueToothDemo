//
//  MyPeripheralViewController.swift
//  PCBlueToothDemo
//
//  Created by 彭祖鑫 on 2023/7/7.
//

import UIKit
import CoreBluetooth
import Alamofire


class MyPeripheralViewController: UIViewController,BluetoothManagerDelegate {
    
    
    let frameLength = 400//每一帧的长度
    
    
    
    // 定义需要发送的数据和当前发送的索引
    var dataToSend: Data = Data()
    var currentChunkIndex = 0
    
    
    func discoveredPeripheral(peripheral: CBPeripheral) {
        
    }
    
    
    
    func connectedToDevice(peripheral: CBPeripheral) {
        
        debugPrint("连接成功")
        self.tableView.reloadData()
        
    }
    
    func decimalToBinary(_ decimal: Int) -> String {
        let binaryString = String(decimal, radix: 2)
        let paddingCount = max(4 - binaryString.count, 0)
        let paddedBinaryString = String(repeating: "0", count: paddingCount) + binaryString
        return paddedBinaryString
    }

    
    
    
    func receivedData(characteristic: CBCharacteristic) {
        
        if let receivedData = characteristic.value {
            
            
            if (characteristic.uuid == CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")) {
                //实时数据监控
//                let byteArray = [UInt8](characteristic.value!)
//                let hexArray = byteArray.map { String(format: "%02X", $0) }
//                print(byteArray)
//                print(hexArray)
//                let Button_STATE = decimalToBinary(Int(byteArray[0]))
//                let characters = Button_STATE.map { String($0) }
//                print("Button_STATE = \(Button_STATE)")
//                print("总开 = \(characters[0])")
//                print("AC = \(characters[1])")
//                print("DC = \(characters[2])")
//                print("Mppt = \(characters[3])")
//                
//                print("总输入功率 = \(UInt16(byteArray[1]) * 256 + UInt16(byteArray[2]))")
//                print("总输出功率 = \(UInt16(byteArray[3]) * 256 + UInt16(byteArray[4]))")
//                print("交流输入功率 = \(UInt16(byteArray[5]) * 256 + UInt16(byteArray[6]))")
//                print("交流输出功率 = \(UInt16(byteArray[7]) * 256 + UInt16(byteArray[8]))")
//                print("直流输入功率 = \(UInt16(byteArray[9]) * 256 + UInt16(byteArray[10]))")
//                print("直流输出功率 = \(UInt16(byteArray[11]) * 256 + UInt16(byteArray[12]))")
//                print("MPPT输入功率 = \(UInt16(byteArray[13]) * 256 + UInt16(byteArray[14]))")
//                
//                print("A口总输出功率   = \(byteArray[15])")
//                print("C口总输出功率   = \(byteArray[16])")
//                print("12V输出功率 （单位：W）   = \(byteArray[17])")
//                print("电池剩余电量   = \(byteArray[18])")
//                print("电池温度  （有正负号，单位：0.01摄氏度） = \(UInt16(byteArray[19]) * 256 + UInt16(byteArray[20]))")
//
//                print("AC 开关状态 0:关  1：开  = \(byteArray[21])")
//                print("DC 开关状态 0:关  1：开  = \(byteArray[22])")
//                print("LED灯状态  = \(byteArray[23])")

                
                
            }else if (characteristic.uuid == CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")) {
                //远程控制/参数配置
                
                let byteArray = [UInt8](characteristic.value!)
                let hexArray = byteArray.map { String(format: "%02X", $0) }
                print(byteArray)
                print(hexArray)
                
                print("AC状态   = \(byteArray[0])")
                print("DC状态   = \(byteArray[1])")
                print("充电上限   = \(byteArray[2])")
                print("放电下限   = \(byteArray[3])")
                print("按键声音   = \(byteArray[4])")
                print("设备待机时间（分钟） = \(UInt16(byteArray[5]) * 256 + UInt16(byteArray[6]))")
                print("息屏时间（秒）   = \(UInt16(byteArray[7])*256 + UInt16(byteArray[8]))")
                print("交流待机时间（分钟） = \(UInt16(byteArray[9]) * 256 + UInt16(byteArray[10]))")
                print("LED状态   = \(byteArray[11])")
                print("温度单位（00代表摄氏度  01代表华氏度）   = \(byteArray[12])")
                
                
                
            }else if (characteristic.uuid == CBUUID(string: "FF04")) {
                //OTA升级包
                
                // 解析接收到的数据
                let receivedResult = receivedData.last
                
                let byteArray = [UInt8](characteristic.value!)
                
                let hexArray = byteArray.map { String(format: "%02X", $0) }
                
                
                //接受数据的码才进这个
                if (receivedData.first == 0xDC) {
                    //判断接收结果
                    JudgeSendResult(receivedResult)
                }else if (receivedData.first == 0xDB) {
                    //反馈硬件信息 是否可以升级
                    print(byteArray)
                    print(hexArray)
                    //["DC", "00", "00", "01"]就可以升级
                    
                    
                }else if (receivedData.first == 0xDD) {
                    
                    //反馈校验结果
                    print(byteArray)
                    print(hexArray)
                    
                    let receivedResult = receivedData[1]
                    if receivedResult == 0x01 {
                        
                        print("校验成功！！！！！")
                    }
                    
                    
                }
                
                
            }
            
        }
    }
    
    
    
    func sendDataSuccess() {
        
    }
    
    func sendDataFailure(error: Error) {
        
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var peripheralArray : Array<String>?
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        BluetoothManager.shared.delegate = self
        setSubviews()
        fillData()
        loadFile()
    }
    //MARK: – UI
    // subviews
    func setSubviews(){
        
        
    }
    //MARK: – request
    // 获取服务数据
    
    //MARK: – 填充数据
    // 填充数据
    func fillData(){
        
        self.peripheralArray =  peripheralSaveManager().getPeripheralArray()
        
        self.tableView.reloadData()
    }
    
    //MARK: – 点击事件
    
    @IBAction func GetInitialData(_ sender: UIButton) {
        
        let byteArray: [UInt8] = [0xED,0xED]
        let data = Data(byteArray)
        BluetoothManager.shared.sendData(data: data, characteristicUUID: CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"))
        
    }
    @IBAction func sendDataButtonPressed(_ sender: UIButton) {
        sendData()
    }
    
    @IBAction func sendUpdateButtonPressed(_ sender: UIButton) {
        canUpdate()
    }
    //MARK: – Public Method
    // 公有方法
    func loadFile(){
        
        AF.download("https://mp-41d1323b-20c4-4238-b163-0d0d53f11543.cdn.bspapp.com/cloudstorage/9088c082-1518-4c53-8dca-bf372eea9b42.bin").downloadProgress { speed in
            //                        downloadProgress(speed.fractionCompleted)
            print(speed.fractionCompleted)
        }.responseData { [self] response in
            
            
            switch response.result {
                
            case .success(let json):
                
                print("下载成功 :\(json)")
                print("文件地址 :\(String(describing: response.fileURL ?? URL(string: "---")))")
                
                if let fileUrl = response.fileURL {
                    do {
                        let data = try Data(contentsOf: fileUrl)
                        // 使用获取到的data进行处理
                        dataToSend = data
                        
                        // ...
                    } catch {
                        print("Failed to load data from file: \(error)")
                    }
                }
                
            case .failure(let errMsg):
                print("下载失败 :\(errMsg)")
            }
        }
        
    }
    
    func canUpdate(){
        //判断是否可以升级
        
        let decimalValue: UInt32 = UInt32(dataToSend.count)  // 十进制数值
        var byteArray: [UInt8] = [
            UInt8(truncatingIfNeeded: decimalValue >> 24),  // 高字节
            UInt8(truncatingIfNeeded: decimalValue >> 16),
            UInt8(truncatingIfNeeded: decimalValue >> 8),
            UInt8(truncatingIfNeeded: decimalValue)           // 低字节
        ]
        byteArray.insert(0xCB, at: 0)  // 固定的首位值
        //添加帧数片值 3037片 最后一片80字节
        byteArray.append(contentsOf: [0x0b,0xdd])
        //添加版本号
        byteArray.append(contentsOf: [0x00,0x00,0x27,0x12])
        print(byteArray)
        let hexArray = byteArray.map { String(format: "%02X", $0) }
        print(hexArray)
        
        
        let data = Data(byteArray)
        BluetoothManager.shared.sendData(data: data, characteristicUUID: CBUUID(string: "FF04"))
        
        
    }
    
    // 发送数据
    func sendData() {
        
        
        // 计算本次发送的数据块范围
        let frame = dataToSend.count/frameLength ;
        
        var per:Float = Float(currentChunkIndex * frameLength)/Float(dataToSend.count)
        if (per > 1){
            per = 1;
        }
        print("百分比:\(String(format: "%.2f", per*100))%")
        
        if (currentChunkIndex < frame) {
            
            sendNomalByte()
            
        } else {//最后一片还剩不到400个字节处理
            print("发送剩余80xx字节")
            //            print(currentChunkIndex)
            sendLastByte()
            
            
            
        }
        
    }
    
    func sendNomalByte(){
        
        if (currentChunkIndex == 3036) {
            
            print("3036")
            
        }
        
        // 每次发送的字节数
        let chunkSize = frameLength
        
        let startIndex = currentChunkIndex * chunkSize
        let endIndex = min(startIndex + chunkSize, dataToSend.count)
        let chunkData = dataToSend[startIndex..<endIndex]
        
        let frame = hexChange(num: currentChunkIndex)
        // 将 UInt32 值转换为 UInt16 类型，并添加到 command 数组中
        // 创建指令数据
        //这个可以测试成功
        let command: [UInt16] = [0xCC, frame, 0x0190]
        var commandData = Data()
        command.enumerated().forEach { index, value in
            if index == 0 {  // 第一个元素，单字节
                let valueByte: UInt8 = UInt8(truncatingIfNeeded: value)
                commandData.append(valueByte)
            } else {  // 其他元素，双字节
                let valueBytes: [UInt8] = [
                    UInt8(truncatingIfNeeded: value >> 8),  // 高字节
                    UInt8(truncatingIfNeeded: value)        // 低字节
                ]
                commandData.append(contentsOf: valueBytes)
            }
        }
        
        // 合并指令数据和数据块数据
        var fullData = commandData
        fullData.append(chunkData)
        
        //        let bytes:[UInt8] = [UInt8](fullData)
        //        print(bytes)
        //
        //        let hexArray = bytes.map { String(format: "%02X", $0) }
        //        print(hexArray)
        
        // 发送数据块给蓝牙模块
        BluetoothManager.shared.sendData(data: fullData, characteristicUUID: CBUUID(string: "FF04"))
    }
    
    func sendLastByte(){
        
        let chunkSize = dataToSend.count - (currentChunkIndex * frameLength)
        
        let startIndex = currentChunkIndex * frameLength
        let endIndex = startIndex + chunkSize
        let chunkData = dataToSend[startIndex..<endIndex]
        
        
        let frame =  hexChange(num: currentChunkIndex)
        //长度转换
        let length = hexChange(num: chunkSize)
        
        // 创建指令数据
        let command: [UInt16] = [0xCC, frame, length]
        var commandData = Data()
        
        command.enumerated().forEach { index, value in
            if index == 0 {  // 第一个元素，单字节
                let valueByte: UInt8 = UInt8(truncatingIfNeeded: value)
                commandData.append(valueByte)
            } else {  // 其他元素，双字节
                let valueBytes: [UInt8] = [
                    UInt8(truncatingIfNeeded: value >> 8),  // 高字节
                    UInt8(truncatingIfNeeded: value)        // 低字节
                ]
                commandData.append(contentsOf: valueBytes)
            }
        }
        
        // 合并指令数据和数据块数据
        var fullData = commandData
        fullData.append(chunkData)
        
        let bytes: [UInt8] = [UInt8](fullData)
        print(bytes)
        
        let hexArray = bytes.map { String(format: "%02X", $0) }
        print(hexArray)
        
        // 发送数据块给蓝牙模块
        BluetoothManager.shared.sendData(data: fullData, characteristicUUID: CBUUID(string: "FF04"))
    }
    
    func sendVerify(){
        
        let command: [UInt8] = [0xCD,0x01]
        let data = Data(command)
        BluetoothManager.shared.sendData(data: data, characteristicUUID: CBUUID(string: "FF04"))
        
        
        
    }
    
    //MARK: – Private Method
    // 私有方法
    fileprivate func JudgeSendResult(_ receivedResult: Data.Element?) {
        // 判断接收结果
        if receivedResult == 0x01 {
            print("数据接受成功，发送下一条数据")
            // 接收成功，发送下一帧数据
            currentChunkIndex += 1
            if (currentChunkIndex <= ((dataToSend.count / frameLength))){
                //大于最大数据就不发了
                sendData()
            } else {
                print("发送完成")
                ///延迟三秒调取反馈结果
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3) {
                    self.sendVerify()
                }
                
            }
            
        } else {
            // 接收失败，处理错误
            // ...
            print("数据接受失败，currentChunkIndex = \(currentChunkIndex)")
            
        }
    }
    
    func hexChange(num:Int )->UInt16{
        
        let decimal: UInt16 = UInt16(num)  // 十进制数值
        let hexString = String(format: "0x%04X", decimal)  // 转
        let scanner = Scanner(string: hexString)
        var value: UInt64 = 0
        
        // 将十六进制字符串转换为 UInt32 类型的值
        scanner.scanHexInt64(&value)
        
        let result = UInt16(truncatingIfNeeded: value)
        
        return result
        
    }
    
    
    
    
}


extension MyPeripheralViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripheralArray?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        let peripheralUUID = UUID(uuidString: peripheralArray?[indexPath.row] ?? "")!
        let peripheral = BluetoothManager.shared.centralManager.retrievePeripherals(withIdentifiers: [peripheralUUID]).first
        
        
        cell.textLabel?.text = peripheral?.name
        
        if (peripheral?.state == .connected) {
            cell.textLabel?.text = (peripheral?.name ?? "-") + "（已连接）"
            
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let peripheralUUID = UUID(uuidString: peripheralArray?[indexPath.row] ?? "")!
        
        guard let peripheral = BluetoothManager.shared.centralManager.retrievePeripherals(withIdentifiers: [peripheralUUID]).first else { return  }
        BluetoothManager.shared.connect(to: peripheral)
        
        
    }
    
}
