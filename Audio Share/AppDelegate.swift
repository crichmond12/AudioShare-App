//
//  AppDelegate.swift
//  Audio Share
//
//  Created by Christian Richmond on 6/17/24.
//

import Foundation
import UIKit
import SpotifyiOS
import SwiftUI

//@UIApplicationMain
import UIKit

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    

        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            return true
        }
    
    func applicationWillResignActive(_ application: UIApplication) {
         // Sent when the application is about to move from active to inactive state.
     }

     func applicationDidEnterBackground(_ application: UIApplication) {
         print("HERE");
         // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     }

     func applicationWillEnterForeground(_ application: UIApplication) {
         // Called as part of the transition from the background to the active state.
     }

     func applicationDidBecomeActive(_ application: UIApplication) {
         // Restart any tasks that were paused (or not yet started) while the application was inactive.
     }

     func applicationWillTerminate(_ application: UIApplication) {
         // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
     }

     // Handle URL callback
     func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
         return SpotifySessionManager.shared.sessionManager.application(app, open: url, options: options)
     }


    /*func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }*/
}

/*class AppDelegate: UIResponder, UIApplicationDelegate, SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
      print("success", session)
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
      print("fail", error)
    }
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
      print("renewed", session)
    }
    
    var window: UIWindow?
    // spotifyClientId is loaded from Secrets.xcconfig → Info.plist (see Constants.swift)
    let SpotifyRedirectURL = URL(string: "audio_share:spotifyAuth")!

    lazy var configuration = SPTConfiguration(
      clientID: spotifyClientId,
      redirectURL: SpotifyRedirectURL
    )
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("ASEF")
        // Spotify
        if SpotifySessionManager.shared.sessionManager.application(app, open: url, options: options) {
            return true
        }

        return false
    }

    // Other AppDelegate methods like application(_:didFinishLaunchingWithOptions:) can be added here
}*/
