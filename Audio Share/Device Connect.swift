//
//  Device Connect.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/26/24.
//

import SwiftUI
import CodeScanner

struct DeviceConnect: View {
    //let private loginManager = LoginManager();
    @StateObject private var cameraManager = QRCameraManager.shared;
    private let keychainManager = KeychainManager();
    @StateObject private var serviceManager = ServiceDiscoveryManager();

    var body: some View {
        if (cameraManager.open_camera) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "Something"){ response in
                let connectionManager = ConnectionManager.shared;
                switch response {
                case .success(let result):
                    let netService = self.serviceManager.matchSerialNumber(serial_code: result.string);
                    let host_data = self.serviceManager.getHostData(netService: netService!);
                    if (host_data != nil){
                        let (ip_address, port) = host_data!;
                        let loginManager = LoginManager.shared;
                        let User = loginManager.getUser();
                        if (User == nil){
                            print("Can't find user.")
                            return;
                        }
                        let username = User!.username;
                        let public_key = keychainManager.loadPublicKey(tag: "\(username!)_audioshare_pubkey");
                        Task{
                            await connectionManager.connect(ip_address: ip_address, port: port);
                            
                        }
                        //self.connectionManager = ConnectionManager(ip_address: ip_address, port: port);
                        //self.connectionManager!.connect();
                        //let (public_key, private_key) = generateKeyPair() ?? (nil, nil);
                        //let data = "Whatup Biatch".data(using: public_key.data();
                        //let signature = signMessage(message: "Create User".data(using: .utf8)!, privateKey: private_key!)
                        //let data = public_key
                        //self.connectionManager!.sendData(data: data!);
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
