//
//  SpotifySessionManager.swift
//  Audio Share
//
//  Created by Christian Richmond on 6/24/24.
//

import Foundation
import UIKit
import SpotifyiOS

class SpotifySessionManager: NSObject, ObservableObject, SPTSessionManagerDelegate {
    static let shared = SpotifySessionManager();
    
    // Uses spotifyClientId from Constants.swift (loaded from Secrets.xcconfig via Info.plist)
    private let SpotifyRedirectURL = URL(string: "audioshare://spotifyAuth")!

    private lazy var configuration = SPTConfiguration(clientID: spotifyClientId, redirectURL: SpotifyRedirectURL)
    
    
    
    public lazy var sessionManager: SPTSessionManager = {
        let server_ip = "192.168.68.60";//ConnectionManager.shared.getLocalServerIPAddress();//"192.168.68.60";//
        let server_port = "8080";//ConnectionManager.shared.getLocalServerPort();//54762;
        guard let infoDictionary = Bundle.main.infoDictionary else {
            return SPTSessionManager(configuration: self.configuration, delegate: self)
        }
        
        guard let host = infoDictionary["APPHost"] as? String else {
            return SPTSessionManager(configuration: self.configuration, delegate: self)
        }
        
        if let tokenSwapURL = URL(string: "\(host)/spotifyAuth"),
           let tokenRefreshURL = URL(string: "\(host)/spotifyTokenRefresh") {
            self.configuration.tokenSwapURL = tokenSwapURL
            self.configuration.tokenRefreshURL = tokenRefreshURL
        }
        
        return SPTSessionManager(configuration: self.configuration, delegate: self)
    }()

    @Published var isAuthenticated = false
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return true;
    }


    func initiateSession() {
        
        let scope: SPTScope = [.userReadPrivate, .userReadEmail, .playlistReadPrivate, .playlistModifyPublic, .playlistModifyPrivate, .userLibraryRead, .userLibraryModify, .userReadPlaybackState, .userModifyPlaybackState, .userReadCurrentlyPlaying, .streaming]
        self.sessionManager.initiateSession(with: scope, options: .default, campaign: nil)
    }

    // MARK: - SPTSessionManagerDelegate
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("Successfully initiated session:", session)
        self.isAuthenticated = true
        
        // Send the authorization code to the Raspberry Pi server
        let accessToken = session.accessToken;
        print("SEND TO SERVER \(accessToken)");
        let hasLocalDevice = LoginManager.shared.isConnectedToDevice;
        if hasLocalDevice {
            let connectionManager = ConnectionManager.shared;
            //connectionManager.sendData(data: );
        }
        //sendAuthorizationCodeToServer(code: accessToken)
        
        /*if let authorizationCode = session.accessToken {
            sendAuthorizationCodeToServer(code: authorizationCode)
        }*/
        
        // Handle successful session initiation
    }

    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("Failed to initiate session:", error)
        // Handle session initiation failure
    }
}
