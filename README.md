# Audio Share — iOS

An iOS app that discovers and connects to a self-hosted [Audio Share server](https://github.com/YOUR_USERNAME/audio-share-server) on your local network. All audio data is transmitted over an end-to-end encrypted TCP connection — no cloud required.

> 🖥 **Backend Server:** [Audio Share Server](https://github.com/YOUR_USERNAME/audio-share-server)

---

## Features

- **Automatic server discovery** — uses Bonjour/mDNS to find Audio Share servers on the local network with no manual IP entry
- **QR code device pairing** — scan a QR code displayed on the server to connect instantly
- **End-to-end encryption** — Curve25519 key exchange + AES-GCM via Apple's CryptoKit
- **Secure key storage** — session and private keys stored in the iOS Keychain
- **Spotify integration** — browse and control Spotify playback via the Spotify iOS SDK
- **Audio library** — view and interact with content available on the connected device
- **SwiftUI** interface built for iOS 17+

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5 |
| UI | SwiftUI + UIKit |
| Networking | Network.framework (NWBrowser, NWConnection) |
| Service discovery | Bonjour / `_audioshare._tcp` |
| Encryption | CryptoKit (Curve25519, AES-GCM) |
| Key storage | Keychain Services |
| Audio | AVFoundation / AVAudioEngine |
| Third-party | Spotify iOS SDK |
| QR scanning | AVFoundation (camera) |

---

## Requirements

- iOS 17.4+
- Xcode 15+
- A running [Audio Share server](https://github.com/YOUR_USERNAME/audio-share-server) on the same local network
- (Optional) Spotify Premium account for Spotify features

---

## Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/audio-share-ios.git
cd audio-share-ios
```

### 2. Open in Xcode

```bash
open "Audio Share.xcodeproj"
```

### 3. Configure Spotify (optional)

To enable Spotify integration, add your credentials to `Audio Share/Constants.swift`:

```swift
let spotifyClientId = "YOUR_CLIENT_ID"
let spotifyClientSecretKey = "YOUR_CLIENT_SECRET"
let tokenSwapURL = "https://your-server.com/spotifyAuth"
```

> ⚠️ Never commit real credentials to source control. Use environment variables or a config file excluded from git.

### 4. Build & run

Select your target device or simulator in Xcode and press **⌘R**.

> **Note:** Local network features (mDNS discovery, TCP connection) require a real device — the simulator cannot access local network services.

---

## App Flow

```
Launch
  │
  ├─ Not logged in? → Login Screen
  │
  └─ Logged in
       │
       ├─ No session key? → Device Connect
       │     │
       │     └─ Scan QR code on server
       │           │
       │           └─ X25519 handshake → encrypted session established
       │
       └─ Session active → Library
```

1. **Login** — authenticate with the Audio Share server
2. **Device Connect** — scan the QR code shown on the server; the app and server perform an X25519 key exchange to establish an encrypted session
3. **Library** — browse and stream audio content from the connected server
4. **Spotify** — optionally link your Spotify account to control playback

---

## Project Structure

```
Audio Share/
├── Audio_ShareApp.swift          # App entry point
├── ContentView.swift             # Root view — routes to Login or Library
├── Constants.swift               # App-wide constants & Spotify config
├── Security.swift                # CryptoKit helpers (Curve25519, AES-GCM)
├── LocalNetworkAuthorization.swift
├── QRCodeScanner.swift           # Camera-based QR scanning
├── Controllers/
│   └── Library/                  # Library view controller
├── Managers/
│   ├── Audio Engine.swift        # AVAudioEngine playback
│   ├── ConnectionManager.swift   # TCP socket lifecycle
│   ├── Keychain Manager.swift    # Secure key persistence
│   ├── Login Manager.swift       # Auth state management
│   ├── ServiceDiscovery.swift    # Bonjour mDNS browser
│   ├── SocketManager.swift       # Low-level socket I/O
│   └── SpotifySessionManager.swift
├── Network Handlers/
│   ├── Inbound Handler.swift     # Decrypt & parse incoming messages
│   └── Outbound Handler.swift    # Encrypt & send outgoing messages
├── Login Page/
│   └── LoginPage.swift
├── JSON Encoded Data/            # Codable request/response models
├── Errors/                       # Custom error types
└── Extensions/
```

---

## Security Design

All communication between the iOS app and the server is encrypted:

- **Key exchange:** Curve25519 Elliptic Curve Diffie-Hellman (ephemeral per session)
- **Symmetric encryption:** AES-256-GCM (authenticated encryption via CryptoKit)
- **Key storage:** Private keys and session keys stored in the iOS Keychain, accessible only when the device is unlocked
- **No cloud dependency:** All data stays on your local network

---

## License

MIT
