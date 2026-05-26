//
//  Constants.swift
//  Audio Share
//
//  Created by Christian Richmond on 6/24/24.
//

import Foundation
import SpotifyiOS

// MARK: - Spotify credentials
// These are injected at build time via Secrets.xcconfig → Info.plist.
// Never hardcode credentials here — edit Secrets.xcconfig instead.
let spotifyClientId: String = {
    guard let value = Bundle.main.infoDictionary?["SpotifyClientId"] as? String, !value.isEmpty else {
        assertionFailure("SpotifyClientId missing from Info.plist — did you create Secrets.xcconfig?")
        return ""
    }
    return value
}()

let spotifyClientSecretKey: String = {
    guard let value = Bundle.main.infoDictionary?["SpotifyClientSecret"] as? String, !value.isEmpty else {
        assertionFailure("SpotifyClientSecret missing from Info.plist — did you create Secrets.xcconfig?")
        return ""
    }
    return value
}()

// MARK: - Other constants
let accessTokenKey = "access-token-key"
let redirectUri = URL(string: "audio_share://")!
let tokenSwapURL = "https://audio-share-068ed037b800.herokuapp.com/spotifyAuth"

/*
Scopes let you specify exactly what types of data your application wants to
access, and the set of scopes you pass in your call determines what access
permissions the user is asked to grant.
For more information, see https://developer.spotify.com/web-api/using-scopes/.
*/
let scopes: SPTScope = [
                            .userReadEmail, .userReadPrivate,
                            .userReadPlaybackState, .userModifyPlaybackState, .userReadCurrentlyPlaying,
                            .streaming, .appRemoteControl,
                            .playlistReadCollaborative, .playlistModifyPublic, .playlistReadPrivate, .playlistModifyPrivate,
                            .userLibraryModify, .userLibraryRead,
                            .userTopRead, .userReadPlaybackState, .userReadCurrentlyPlaying,
                            .userFollowRead, .userFollowModify,
                        ]
let stringScopes = [
                        "user-read-email", "user-read-private",
                        "user-read-playback-state", "user-modify-playback-state", "user-read-currently-playing",
                        "streaming", "app-remote-control",
                        "playlist-read-collaborative", "playlist-modify-public", "playlist-read-private", "playlist-modify-private",
                        "user-library-modify", "user-library-read",
                        "user-top-read", "user-read-playback-position", "user-read-recently-played",
                        "user-follow-read", "user-follow-modify",
                    ]
