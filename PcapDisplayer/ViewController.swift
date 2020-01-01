//
//  ViewController.swift
//  PcapDisplayer
//
//  Created by Николай Костин on 01.01.2020.
//  Copyright © 2020 Николай Костин. All rights reserved.
//

import UIKit

extension Data {
    enum Endianness {
        case BigEndian
        case LittleEndian
    }
    func scanValue<T: FixedWidthInteger>(at index: Data.Index, endianess: Endianness) -> T {
        let number: T = self.subdata(in: index..<index + MemoryLayout<T>.size).withUnsafeBytes({ $0.pointee })
        switch endianess {
        case .BigEndian:
            return number.bigEndian
        case .LittleEndian:
            return number.littleEndian
        }
    }
    func toUInt32(endianess: Endianness = .LittleEndian) ->UInt32? {
        let retValue = self.scanValue(at: 0, endianess: endianess) as UInt32
        return retValue
    }
    func toUInt16(endianess: Endianness = .LittleEndian) ->UInt16? {
        let retValue = self.scanValue(at: 0, endianess: endianess) as UInt16
        return retValue
    }
    func toInt32(endianess: Endianness = .LittleEndian) ->Int32? {
           let retValue = self.scanValue(at: 0, endianess: endianess) as Int32
           return retValue
    }
    func toUInt8(endianess: Endianness = .LittleEndian) ->UInt8? {
           let retValue = self.scanValue(at: 0, endianess: endianess) as UInt8
           return retValue
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        decodePcap()
    }
    
    func readHeader(file: FileHandle?){
        let magicNumber = file?.readData(ofLength: 4)
        let versionMajor = file?.readData(ofLength: 2)
        let versionMinor = file?.readData(ofLength: 2)
        let thisZone = file?.readData(ofLength: 4)
        let sigFigs = file?.readData(ofLength: 4)
        let snapLen = file?.readData(ofLength: 4)
        let network = file?.readData(ofLength: 4)
        
        
        print(magicNumber?.toUInt32() as Any)
        print(versionMajor?.toUInt16() as Any)
        print(versionMinor?.toUInt16() as Any)
        print(thisZone?.toInt32() as Any)
        print(sigFigs?.toUInt32() as Any)
        print(snapLen?.toUInt32() as Any)
        print(network?.toUInt32() as Any)
    }
    
    func readRecordBody(file: FileHandle?, length: UInt32){
        let body = file?.readData(ofLength: Int(length))
        print(String(decoding: body!, as: UTF8.self))
    }
    
    func readMac(file:FileHandle?) -> String{
        guard let destMac1 = file?.readData(ofLength: 1).toUInt8(),
        let destMac2 = file?.readData(ofLength: 1).toUInt8(),
        let destMac3 = file?.readData(ofLength: 1).toUInt8(),
        let destMac4 = file?.readData(ofLength: 1).toUInt8()
            else{
                return "error"
        }
        return "\(destMac1).\(destMac2).\(destMac3).\(destMac4)"
    }
    
    func readRecordHeader(file: FileHandle?){
        let tvSec = file?.readData(ofLength: 4)
        let tsUsec = file?.readData(ofLength: 4)
        let inclLen = file?.readData(ofLength: 4)
        let origLen = file?.readData(ofLength: 4)
        print(tvSec?.toUInt32() as Any)
        print(tsUsec?.toUInt32() as Any)
        print(inclLen?.toUInt32() as Any)
        print(origLen?.toUInt32() as Any)

        let ip = file?.readData(ofLength: 4).toUInt32(endianess: .BigEndian)
        
        let headerLength = file?.readData(ofLength: 1).toUInt8(endianess: .BigEndian)
//      yes 69 is right
        let congestion = file?.readData(ofLength: 1).toUInt8(endianess: .BigEndian)
        
        
        let totalLen = file?.readData(ofLength: 2).toUInt16(endianess: .BigEndian)
        let identification = file?.readData(ofLength: 2).toUInt16(endianess: .BigEndian)
        let fragmentOffset = file?.readData(ofLength: 2).toUInt16(endianess: .BigEndian)
        let timeToLive = file?.readData(ofLength: 1).toUInt8(endianess: .BigEndian)
        let protocolVersion = file?.readData(ofLength: 1).toUInt8(endianess: .BigEndian)
        let headerSum = file?.readData(ofLength: 2).toUInt16(endianess: .BigEndian)
        
        let sourceMac = readMac(file: file)
        let destMac = readMac(file : file)
        
        let sourcePort = file?.readData(ofLength: 2).toUInt16(endianess: .BigEndian)
        let destPort = file?.readData(ofLength: 2).toUInt16(endianess: .BigEndian)
        let sequenceNumber = file?.readData(ofLength: 4).toUInt32(endianess: .BigEndian)
        let AcknowledgmentNumber = file?.readData(ofLength: 4).toUInt32(endianess: .BigEndian)
        let nonce = file?.readData(ofLength: 1).toUInt8(endianess: .BigEndian)
        let fin = file?.readData(ofLength: 1).toUInt8(endianess: .BigEndian)
        let windowSizeValue = file?.readData(ofLength: 2).toUInt16(endianess: .BigEndian)
        let checkSum = file?.readData(ofLength: 2).toUInt16(endianess: .BigEndian)
        let urgentPointer = file?.readData(ofLength: 2).toUInt16(endianess: .BigEndian)
        let kind1 = file?.readData(ofLength: 1).toUInt8(endianess: .BigEndian)
        let kind2 = file?.readData(ofLength: 1).toUInt8(endianess: .BigEndian)
        let kind3 = file?.readData(ofLength: 1).toUInt8(endianess: .BigEndian)
        if Int(kind3!) == 8 {
            let len = file?.readData(ofLength: 1).toUInt8(endianess: .BigEndian)
            let timeStampVal = file?.readData(ofLength: 4).toUInt32(endianess: .BigEndian)
            let timeStampEchoReply = file?.readData(ofLength: 4).toUInt32(endianess: .BigEndian)
            print("len is \(len)")
            print(timeStampVal as Any)
            print(timeStampEchoReply as Any)
        }
        print(ip as Any)
        print(headerLength as Any)
        print(totalLen as Any)
        print(identification as Any)
        print(fragmentOffset as Any)
        print(timeToLive as Any)
        print(protocolVersion as Any)
        print(headerSum as Any)
        print(sourceMac)
        print(destMac)
        print(sourcePort as Any)
        print(destPort as Any)
        print(sequenceNumber as Any)
        print(AcknowledgmentNumber as Any)
        print(nonce as Any)
        print(fin as Any)
        print(windowSizeValue as Any)
    }
    
    func decodePcap(){
        if let path = Bundle.main.path(forResource: "protected.pcap", ofType: nil) {
            print("[check] FILE AVAILABLE \(path)")
            
            let file: FileHandle? = FileHandle(forReadingAtPath: path)
            
            if file == nil{
                print("Open failed")
            }else{
                readHeader(file: file)
                readRecordHeader(file: file)
            }
        }
        
    }

}

