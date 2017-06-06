//
//  RSUnifiedCodeGenerator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/10/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public class RSUnifiedCodeGenerator: RSCodeGenerator {
    
    public var isBuiltInCode128GeneratorSelected = false
    public var fillColor: UIColor = UIColor.white
    public var strokeColor: UIColor = UIColor.black
    
    public class var shared: RSUnifiedCodeGenerator {
        return UnifiedCodeGeneratorSharedInstance
    }
    
    // MARK: RSCodeGenerator
    
    public func isValid(_ contents: String) -> Bool {
        print("Use RSUnifiedCodeValidator.shared.isValid(contents:String, machineReadableCodeObjectType: String) instead")
        return false
    }
    
    public func generateCode(_ contents: String, inputCorrectionLevel: InputCorrectionLevel, machineReadableCodeObjectType: String) -> UIImage? {
        
        let objectType = machineReadableCodeObjectType
        var codeGenerator: RSCodeGenerator?
        
        switch objectType {
        case AVMetadataObject.ObjectType.qr.rawValue, AVMetadataObject.ObjectType.pdf417.rawValue, AVMetadataObject.ObjectType.aztec.rawValue:
            return RSAbstractCodeGenerator.generateCode(contents, inputCorrectionLevel: inputCorrectionLevel, filterName: RSAbstractCodeGenerator.filterName(machineReadableCodeObjectType))
        case AVMetadataObject.ObjectType.code39.rawValue:
            codeGenerator = RSCode39Generator()
        case AVMetadataObject.ObjectType.code39Mod43.rawValue:
            codeGenerator = RSCode39Mod43Generator()
        case AVMetadataObject.ObjectType.ean8.rawValue:
            codeGenerator = RSEAN8Generator()
        case AVMetadataObject.ObjectType.ean13.rawValue:
            codeGenerator = RSEAN13Generator()
        case AVMetadataObject.ObjectType.interleaved2of5.rawValue:
            codeGenerator = RSITFGenerator()
        case AVMetadataObject.ObjectType.itf14.rawValue:
            codeGenerator = RSITF14Generator()
        case AVMetadataObject.ObjectType.upce.rawValue:
            codeGenerator = RSUPCEGenerator()
        case AVMetadataObject.ObjectType.code93.rawValue:
            codeGenerator = RSCode93Generator()
            // iOS 8 included, but my implementation's performance is better :)
        case AVMetadataObject.ObjectType.code128.rawValue:
            if self.isBuiltInCode128GeneratorSelected {
                return RSAbstractCodeGenerator.generateCode(contents, inputCorrectionLevel: inputCorrectionLevel, filterName: RSAbstractCodeGenerator.filterName(machineReadableCodeObjectType))
            } else {
                codeGenerator = RSCode128Generator()
            }
        case AVMetadataObject.ObjectType.dataMatrix.rawValue:
            codeGenerator = RSCodeDataMatrixGenerator()
        case RSBarcodesTypeExtendedCode39Code:
            codeGenerator = RSISBN13Generator()
        case RSBarcodesTypeISBN13Code:
            codeGenerator = RSISSN13Generator()
        case RSBarcodesTypeExtendedCode39Code:
            codeGenerator = RSExtendedCode39Generator()
        default:
            print("No code generator selected.")
        }
        
        if var cg = codeGenerator {
            cg.fillColor = self.fillColor
            cg.strokeColor = self.strokeColor
            return cg.generateCode(contents, inputCorrectionLevel: inputCorrectionLevel, machineReadableCodeObjectType: objectType)
        } else {
            return nil
        }
    }
    
    public func generateCode(_ contents: String, machineReadableCodeObjectType: String) -> UIImage? {
        return self.generateCode(contents, inputCorrectionLevel: .Medium, machineReadableCodeObjectType: machineReadableCodeObjectType)
    }
    
    public func generateCode(_ machineReadableCodeObject: AVMetadataMachineReadableCodeObject, inputCorrectionLevel: InputCorrectionLevel) -> UIImage? {
        
        guard let objectString = machineReadableCodeObject.stringValue else {
            return nil
        }
        return self.generateCode(objectString, inputCorrectionLevel: inputCorrectionLevel, machineReadableCodeObjectType: machineReadableCodeObject.type.rawValue)
    }
    
    public func generateCode(_ machineReadableCodeObject: AVMetadataMachineReadableCodeObject) -> UIImage? {
        return self.generateCode(machineReadableCodeObject, inputCorrectionLevel: .Medium)
    }
}

let UnifiedCodeGeneratorSharedInstance = RSUnifiedCodeGenerator()
