//
//  Library.swift
//  Audio Share
//
//  Created by Christian Richmond on 7/4/24.
//

import SwiftUI

struct Library: View {
    //@State private var show_device_connect: Bool = false;
    //private var show_device_connect: Bool
    //private let loginManager = LoginManager.shared;
    public init() {
    
    }
    @State var needs_to_connect = !LoginManager.shared.isConnectedToDevice;
    var body: some View {
        GeometryReader {
            geometry in
            Text("Library");
            Button(action: {
                SpotifySessionManager.shared.initiateSession();
                /*lazy var configuration: SPTConfiguration = {
                    let configuration = SPTConfiguration(clientID: spotifyClientId, redirectURL: redirectUri)
                    // Set the playURI to a non-nil value so that Spotify plays music after authenticating
                    // otherwise another app switch will be required
                    configuration.playURI = ""
                    // Set these url's to your backend which contains the secret to exchange for an access token
                    // You can use the provided ruby script spotify_token_swap.rb for testing purposes
                    configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
                    configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
                    return configuration
                }()

                lazy var sessionManager: SPTSessionManager? = {
                    let manager = SPTSessionManager(configuration: configuration, delegate: self)
                    return manager
                }()*/

            }){
                Text("SPOTIFY")
                    .frame(width: geometry.size.width, height: 48)
                    .font(.headline) // Custom font size
                    .foregroundColor(.white) // Text color
                    .background(Color.blue) // Background color
                    .cornerRadius(8) // Rounded corners
                    .shadow(radius: 10) // Shadow effect
            }

        }
        .sheet(isPresented: self.$needs_to_connect){
            DeviceConnect()
        }
    }
}

