//
//  QRCameraManager.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/27/24.
//

import Foundation

class QRCameraManager: ObservableObject{
    static let shared = QRCameraManager();
    @Published var open_camera: Bool = false;
    
    private init(){
    }
    
    public func openCamera() {
        self.open_camera = true;
    }
    
    public func closeCamera() {
        self.open_camera = false;
    }
}
