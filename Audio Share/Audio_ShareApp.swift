//
//  Audio_ShareApp.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/18/24.
//

import SwiftUI

@main
struct Audio_ShareApp: App {
    @State private var loginManager = LoginManager.shared;
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL{
                    url in
                    let options: [UIApplication.OpenURLOptionsKey : Any] = [:];
                    SpotifySessionManager.shared.sessionManager.application(UIApplication.shared, open: url, options: options);
                }
        }
    }
}
