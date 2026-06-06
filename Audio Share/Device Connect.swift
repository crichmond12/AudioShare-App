//
//  Device Connect.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/26/24.
//

import SwiftUI
import CodeScanner

// QR code payload format: {"s":"<serial_number>","ps":"<base64_pairing_secret>"}
private struct QRPayload: Decodable {
    let s: String   // serial number — used for mDNS service matching
    let ps: String  // pairing secret (base64) — used as HKDF salt to prevent MITM
}

struct DeviceConnect: View {
    @StateObject private var cameraManager = QRCameraManager.shared;
    private let keychainManager = KeychainManager();
    @StateObject private var serviceManager = ServiceDiscoveryManager();

    var body: some View {
        if (cameraManager.open_camera) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "Something"){ response in
                let connectionManager = ConnectionManager.shared;
                switch response {
                case .success(let result):
                    guard
                        let payloadData = result.string.data(using: .utf8),
                        let qrPayload = try? JSONDecoder().decode(QRPayload.self, from: payloadData),
                        let pairingSecretData = Data(base64Encoded: qrPayload.ps),
                        pairingSecretData.count == 32
                    else {
                        print("Invalid QR code format — expected {\"s\":\"...\",\"ps\":\"...\"}")
                        return
                    }

                    let serialNumber = qrPayload.s
                    keychainManager.savePairingSecret(pairingSecretData, for: serialNumber)

                    guard let netService = self.serviceManager.matchSerialNumber(serial_code: serialNumber) else {
                        print("No mDNS service found for serial: \(serialNumber)")
                        return
                    }
                    guard let host_data = self.serviceManager.getHostData(netService: netService) else {
                        return
                    }
                    let (ip_address, port) = host_data

                    guard LoginManager.shared.getUser() != nil else {
                        print("Can't find user.")
                        return
                    }

                    Task {
                        await connectionManager.connect(ip_address: ip_address, port: port, serialNumber: serialNumber)
                    }

                    print("Found code: \(result.string)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .onAppear {
                self.serviceManager.discoverService();
            }
            .onDisappear(){
            }

        }
        else {
            ZStack{
                LinearGradient(gradient: Gradient(colors: [Color(hex: "DCDCDC"), Color(hex: "591E7D")]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    Button(action: {
                        let loginManager = LoginManager.shared;
                        let User = loginManager.getUser();
                        
                        if (User != nil){
                            let qrManager = QRCameraManager.shared;
                            qrManager.openCamera();
                        }
                    }){
                        Text("Connect your Audio Share Device")
                            .frame(height: 50)
                            .padding(.horizontal, 20)
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)

                    }

                }
            }

        }
    }
}

struct SkipButton:View {
    var body: some View {
        Button(action: {
            
        }){
            HStack(spacing:0){
               Text("Skip")
                Image(systemName: "chevron.forward")
                    .fontWeight(.bold);
            }
        }

    }
}
