# Audio Share — iOS

The iOS remote for [Audio Share](https://github.com/YOUR_USERNAME/audio-share-server) — open, self-hostable software that turns ordinary speakers into networked, multi-room audio endpoints. The app discovers Audio Share devices on your local network, pairs over an end-to-end encrypted TCP connection, and lets you pick audio and play it to any speaker — no cloud required.

> See **[Product Vision & Roadmap](#product-vision--roadmap)** below for where the project is headed (2026-06 pivot to an open endpoint/receiver model).

> 🖥 **Backend Server:** [Audio Share Server](https://github.com/YOUR_USERNAME/audio-share-server)

---

## Features

- **Automatic server discovery** — uses Bonjour/mDNS to find Audio Share servers on the local network with no manual IP entry
- **QR code device pairing** — scan a QR code displayed on the server to connect instantly; the code embeds a 32-byte pairing secret that binds the session key to the specific device
- **End-to-end encryption** — Curve25519 key exchange + AES-GCM via Apple's CryptoKit
- **Secure key storage** — session and private keys stored in the iOS Keychain
- **Playback control** — pick audio and play it to the connected device; browse and interact with what's available
- **SwiftUI** interface built for iOS 17+
- **Spotify integration** *(legacy, under review)* — browse and control Spotify playback via the Spotify iOS SDK. Being reassessed under the pivot — see the [roadmap](#product-vision--roadmap)

---

## Product Vision & Roadmap

**What Audio Share is becoming:** open, self-hostable software that turns any ordinary (non-smart) speaker or amp into a networked, multi-room audio endpoint. A user flashes/installs the [server](https://github.com/YOUR_USERNAME/audio-share-server) on their own Raspberry Pi (or similar Linux device) — the Volumio / moOde / Home Assistant model, not manufactured hardware. **This iOS app is the remote:** you pick audio on your phone and play it to any speaker on the network. The project doubles as an open-source portfolio/showcase piece.

**The pivot (2026-06):** Audio Share is moving **away from being a streaming-service aggregator** (server-side fetching of Spotify/Apple Music/Pandora/YouTube) and **toward being an open endpoint/receiver**. Server-side streaming of the big platforms isn't viable for an indie/self-hosted product — they forbid raw-audio capture, DRM only decrypts at the player in real time, and Spotify's device program is approved-organizations-only. So instead of *being* a streaming service, the device **becomes a speaker that other apps play *to***, plus a player for open/DRM-free sources. This sidesteps licensing entirely.

**Two ways audio reaches a speaker:**
- **Sources the device plays itself** (DRM-free, legal core, ships first): internet radio, podcasts (RSS), self-hosted libraries (Subsonic/Navidrome, Jellyfin, Plex), and local/phone-relayed files.
- **Receiver protocols** (the phone's existing app streams to the device): AirPlay 2 (via `shairport-sync`), optionally Spotify Connect (via `librespot`) and Chromecast. Gray-area integrations ship as **optional, user-installed plugins**, never bundled.

> ⚠️ Under the pivot, server-side Spotify OAuth and the in-app Spotify integration are likely no longer needed — pairing is the security boundary. This is being revisited before further investment.

### Build plan (ordered)

Sequenced as vertical slices — each phase ends at something demoable.

1. ✅ **First end-to-end audio path** — phone says "play `<url>`", speaker makes sound. Internet radio: HTTP stream → decode → output. *(Server-side complete.)*
2. 🚧 **Independent multi-room** — per-zone registry + routing so each output plays its own independent stream. The headline feature. *(Scaffolding in place.)*
3. **Synchronized multi-room via Snapcast** — grouped, time-aligned playback instead of a hand-rolled clock. *(Building blocks in place, not yet wired in.)*
4. **Receiver protocols** — AirPlay 2 receive so any iPhone app can push audio with zero licensing exposure; Spotify Connect as an optional plugin.
5. **More DRM-free sources** — podcasts (RSS), Subsonic/Jellyfin client, phone-relayed local files.
6. **Product & portfolio polish** — flashable image / one-command installer, zero-config onboarding, jitter/underrun buffering, reconnect resilience, tests, and open-source hygiene (docs, architecture diagram, demo video).

> Detailed gaps are tracked in Jira project **KAN**, which will be reconciled with this plan later.

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
| QR scanning | AVFoundation (camera) |
| Third-party | Spotify iOS SDK *(legacy, under review)* |

---

## Requirements

- iOS 17.4+
- Xcode 15+
- A running [Audio Share server](https://github.com/YOUR_USERNAME/audio-share-server) on the same local network
- (Optional, legacy) Spotify Premium account for the in-app Spotify integration — being reassessed under the pivot

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

### 3. Configure Spotify (optional, legacy)

> ⚠️ The in-app Spotify integration is **legacy and under review** — under the pivot, audio reaches the device via DRM-free sources or receiver protocols (e.g. Spotify Connect), not in-app OAuth. See the [roadmap](#product-vision--roadmap). Skip this step unless you're working on the existing integration.

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

1. **Login** — authenticate with the Audio Share server *(account model may become optional under the pivot — pairing is the security boundary)*
2. **Device Connect** — scan the QR code shown on the server; the app and server perform an X25519 key exchange to establish an encrypted session
3. **Library** — pick audio and play it to the connected speaker; browse what's available on the device
4. **Spotify** *(legacy, under review)* — optionally link your Spotify account to control playback

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
│   └── SpotifySessionManager.swift   # Spotify session (legacy, under review)
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
- **Device binding:** The QR code carries a 32-byte pairing secret alongside the server's serial number. That secret is used as the HKDF salt when deriving the session's symmetric key, so the key is cryptographically tied to the specific device that was paired. An attacker who intercepts the connection but never saw the QR code cannot produce a valid key.
- **Key storage:** Private keys, session keys, and per-device pairing secrets are stored in the iOS Keychain, accessible only when the device is unlocked
- **No cloud dependency:** All data stays on your local network

---

## License

MIT
