//
//  ContentView.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/18/24.
//

import SwiftUI
import Network
//import Combine;

struct ContentView: View {
    @State private var isAuthorized: Bool?;
    @State private var service: NWBrowser.Result?;
    @State private var scannedCode: String?;
    @State private var mediaServerData: [String: String]?;
    @StateObject private var serviceManager = ServiceDiscoveryManager();
    @StateObject private var loginManager = LoginManager.shared;
    @State private var show_device_connect: Bool = false;
    private let keychainManager = KeychainManager();
    var body: some View {
        NavigationStack{
            if (loginManager.isLoggedIn){
                Library()
                    .onAppear() {
                        //If the user isn't connected to a audio share device
                        guard let user = loginManager.getUser() else {
                            print("Error getting user from login manager")
                            return;
                        }
                        
                        if (user.session_key == nil){
                            self.show_device_connect = true;
                        }
                    }
            }
            else {
                LoginScreen();
            }

        }
    }
    func requestAuthorization() {
        let authManager = LocalNetworkAuthorization()
        authManager.requestAuthorization { authorized in
            DispatchQueue.main.async {
                self.isAuthorized = authorized
            }
        }
    }
    
}

#Preview {
    ContentView()
}
/*Text("Hello World")
    .onAppear{
        //discoverService();
        //let ServiceManager = ServiceDiscoveryManager();
        print(self.serviceManager.services.count);
        self.serviceManager.discoverService();
    }
if (scannedCode == nil && serviceManager.services.count != 0){
    Button(action: {
        showQRScanner.toggle();
    }){
        Text("Scan QR Code")
    }

    }

}*/
