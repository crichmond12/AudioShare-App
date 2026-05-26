//
//  SceneDelegate.swift
//  Audio Share
//
//  Created by Christian Richmond on 6/30/24.
//

import Foundation
import UIKit
import SpotifyiOS

/*class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        let url = urlContext.url
        print("SCENE: \(url)")
        let options: [UIApplication.OpenURLOptionsKey : Any] = [
            .sourceApplication: urlContext.options.sourceApplication ?? "",
            .annotation: urlContext.options.annotation as Any
        ]
        
        _ = SpotifySessionManager.shared.sessionManager.application(UIApplication.shared, open: url, options: options)
    }

}*/

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("asdf")
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("asdf")
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("asdf")
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("asdf")
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("asdf")
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("Background");
        // Called as the scene transitions from the foreground to the background.
    }

    // Handle URL callback
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("HAED");
        guard let url = URLContexts.first?.url else { return }
        print(url);
        _ = SpotifySessionManager.shared.sessionManager.application(UIApplication.shared, open: url, options: [:])
    }
}

