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
    // A DRM-free internet-radio stream the device can fetch+decode directly
    // (SomaFM Groove Salad). Editable — this is just a convenient default.
    @State private var streamURL: String = "https://ice1.somafm.com/groovesalad-128-mp3";
    @State private var reconnecting = false;
    @State private var statusMessage = "";
    var body: some View {
        VStack(spacing: 20) {
            Text("Library")
                .font(.headline)

            VStack(spacing: 10) {
                TextField("Stream URL", text: $streamURL)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)

                HStack(spacing: 12) {
                    Button("Play") {
                        ConnectionManager.shared.sendTask(
                            "play",
                            data: ["url": streamURL, "zone": "default"]
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(streamURL.isEmpty)

                    Button("Stop") {
                        ConnectionManager.shared.sendTask("stop", data: ["zone": "default"])
                    }
                    .buttonStyle(.bordered)
                }

                Button(reconnecting ? "Reconnecting…" : "Reconnect") {
                    reconnecting = true
                    statusMessage = ""
                    Task {
                        let ok = await ConnectionManager.shared.reconnect()
                        await MainActor.run {
                            reconnecting = false
                            statusMessage = ok ? "Reconnected" : "Reconnect failed — is the device on?"
                        }
                    }
                }
                .buttonStyle(.bordered)
                .disabled(reconnecting)

                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Button(action: {
                SpotifySessionManager.shared.initiateSession();
            }){
                Text("SPOTIFY")
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .font(.headline) // Custom font size
                    .foregroundColor(.white) // Text color
                    .background(Color.blue) // Background color
                    .cornerRadius(8) // Rounded corners
                    .shadow(radius: 10) // Shadow effect
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: self.$needs_to_connect){
            DeviceConnect()
        }
    }
}

