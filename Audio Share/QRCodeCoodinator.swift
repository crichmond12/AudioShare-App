//
//  QRCodeCoodinator.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/19/24.
//

import AVFoundation
import SwiftUI

class QRCodeCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var parent: QRCodeScanner;
    var previewLayer: AVCaptureVideoPreviewLayer?

    init(parent: QRCodeScanner) {
        self.parent = parent
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let metadataObject = metadataObjects.first else {
                DispatchQueue.main.async {
                    self.parent.qrCodeFrame = .zero
                }
                return
            }
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            if let previewLayer = previewLayer {
                let transformedObject = previewLayer.transformedMetadataObject(for: readableObject)
                if let qrCodeObject = transformedObject as? AVMetadataMachineReadableCodeObject {
                    DispatchQueue.main.async {
                        self.parent.qrCodeFrame = qrCodeObject.bounds
                    }
                }
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            parent.didFindCode(stringValue)
        }
    
    @objc func focusOnTap(sender: UITapGestureRecognizer) {
           guard let previewLayer = previewLayer, let device = AVCaptureDevice.default(for: .video) else { return }
           let location = sender.location(in: sender.view)
           let focusPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: location)

           do {
               try device.lockForConfiguration()
               if device.isFocusPointOfInterestSupported {
                   device.focusPointOfInterest = focusPoint
                   device.focusMode = .autoFocus
               }
               if device.isExposurePointOfInterestSupported {
                   device.exposurePointOfInterest = focusPoint
                   device.exposureMode = .autoExpose
               }
               device.unlockForConfiguration()
           } catch {
               print("Failed to set focus point: \(error)")
           }
       }

}

