//
//  ConnectionManager.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/23/24.
//

import Foundation
import Network

class ConnectionManager{
    static let shared = ConnectionManager();
    private let keychainManager = KeychainManager();
    private var User: User?;
    private var connected: Bool = false;
    private var ip_address: String = "";
    private var port: Int = -1;
    private var currentSerialNumber: String = "";

    private var connection: NWConnection?;
    
    func getLocalServerIPAddress() -> String {
        return self.ip_address;
    }
    
    func getLocalServerPort() -> Int {
        return self.port;
    }
    
    public static func post(method: String, formData: [String: String]) async -> [String: Any]? {
        // Build the URL. Points at the device server's account-auth stub (the
        // Rust audioshare_device now serves /authenticateUser + /createUser on
        // 8080; the standalone Go service is gone). This is the Pi's LAN IP —
        // it's hardcoded because login happens before mDNS device discovery, so
        // reserve the Pi's DHCP lease if this changes.
        guard let url = URL(string: "http://192.168.68.68:8080/\(method)") else {
            print("Invalid URL")
            return nil
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Convert parameters to JSON
        var jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: formData, options: [])
        } catch {
            print("Error converting data to JSON: \(error)")
            return nil
        }
        
        request.httpBody = jsonData;

        // Create a URL session
        let session = URLSession.shared

        do {
            // Use `data(for:request:)` for making a POST request instead of `upload(for:from:)`
            let (data, response) = try await session.data(for: request)
            
            // Check if the response is an HTTPURLResponse and has a valid status code
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                // Try to parse the response JSON
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Response JSON: \(json)")
                    return json
                } else {
                    print("Failed to parse JSON")
                }
            } else {
                print("Failed response: \(response)")
            }
        } catch {
            print("Error: \(error)")
        }

        return nil
    }

    
   /* public static func post(method:String, formData:[String:String]) async -> [String: Any]? {
        guard let url = URL(string: "http://192.168.68.68:8080/\(method)") else { return nil}

        // Create the request
        var request = URLRequest(url: url)
        var data:Data = Data();
        request.httpMethod = "POST"
    
        // Convert parameters to JSON
        do {
            let encoder = JSONEncoder()
            data = try encoder.encode(formData)
            //request.httpBody = data;
        } catch let error {
            print("Error converting data: \(error)");
            return nil;
        }

        // Set the headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create a URL session
        let session = URLSession.shared
        
        do {
            // Create the task
            let (data, response) = try await session.upload(for: request, from: data)

            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Response JSON: \(json)")
                return json
            }
        } catch let err {
            print(err)
        }
        
        return nil;
    }*/
    
    func connect(ip_address: String, port: Int, serialNumber: String) async {
        self.ip_address = ip_address;
        self.port = port;
        self.currentSerialNumber = serialNumber;
        let loginManager = LoginManager.shared;
        guard var User = loginManager.getUser() else {
            print("No User Logged in.")
            return;
        }
        //var user_uuid: UUID?;
        if (User.UUID == nil) {
            guard var User = await self.requestDeviceSessionID(ip_address: ip_address, port: port, User: User) else {
                print("Error finding session id.")
                return;
            }
        }

        if (self.connection == nil){
            self.start(ip_address: ip_address, port: port);
        }
        
        self.User = User;
        //self.receiveData();
    }

    /// Re-establish a device session without re-scanning the QR. Used after the
    /// device server restarts (which drops its in-memory session and our TCP
    /// socket): tear down the stale socket/session, rediscover the device by
    /// mDNS, reuse the Keychain pairing secret, and run a fresh handshake.
    /// Returns true once a new session is established.
    @discardableResult
    func reconnect() async -> Bool {
        // Drop the stale socket + session so connect() runs a fresh handshake
        // (it skips the handshake while User.UUID is non-nil).
        self.connection?.cancel()
        self.connection = nil
        self.connected = false
        await MainActor.run { LoginManager.shared.clearDeviceSession() }

        let discovery = ServiceDiscoveryManager()
        discovery.discoverService()
        defer { discovery.stop() }

        guard let (netService, serial) = await discovery.awaitPairedService(timeout: 5) else {
            print("reconnect: no known Audio Share device found on the network")
            return false
        }
        guard let (ip_address, port) = discovery.getHostData(netService: netService) else {
            print("reconnect: could not resolve device address")
            return false
        }

        await self.connect(ip_address: ip_address, port: port, serialNumber: serial)
        return LoginManager.shared.isConnectedToDevice
    }

    func start(ip_address: String, port: Int) {
        self.connection = NWConnection(host: NWEndpoint.Host(ip_address), port: NWEndpoint.Port(rawValue: UInt16(port))!, using: .tcp)
        self.connection!.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Connected to \(ip_address) on port \(port)")
                self.receiveData();
            case .cancelled:
                print("Connection Cancelled.");
            case .preparing:
                print("Preparing connection.");
            case .failed(let error):
                print("Failed to connect: \(error)")
            default:
                break
            }
        }
    
        self.connected = true;
        self.connection!.start(queue: .main);
    }

    func requestDeviceSessionID(ip_address: String, port: Int, User: User) async -> User? {
        //self.connection = NWConnection(host: NWEndpoint.Host(ip_address), port: NWEndpoint.Port(rawValue: UInt16(port))!, using: .tcp)
        //self.connection!.start(queue: .main);
        if (self.connection == nil) {
            self.start(ip_address: ip_address, port: port);
        }
        guard let connection = self.connection else {
            // Handle the case where connection is nil
            print("Connection is nil")
            return nil;
        }
        
        guard let publicKey = keychainManager.loadPublicKey(tag: "\(User.username ?? "default")_audioshare_pubkey") else {
            print("Failed to load public key")
            return nil;
        }
        
        let data: UserSessionRequest = UserSessionRequest(publicKey.rawRepresentation.base64EncodedString());
        
        do {
            //self.sendData(data: connectionData!);
            guard let serverResponse = await self.sendAndReceive(data) else {
                print("Error getting response from server");
                return nil;
            }
            guard let sessionKey = try serverResponse.getSessionKey() else {
                print("Error getting session key");
                return nil;
            }
            
            let SEC = Sec.shared;

            guard let pairingSecret = keychainManager.loadPairingSecret(for: self.currentSerialNumber) else {
                print("No pairing secret found for device \(self.currentSerialNumber)")
                return nil
            }

            guard let (session_uuid, symmetricKey) = SEC.getSessionData(json: sessionKey, pairingSecret: pairingSecret) else {
                print("Could not derive session data from json.")
                return nil;
            }
            // Set the session synchronously (not fire-and-forget) so callers see
            // isConnectedToDevice/session_key set the moment this returns — the
            // reconnect() flow checks that flag right after the handshake.
            await MainActor.run {
                LoginManager.shared.setSessionKey(uuid: session_uuid, session_key: symmetricKey)
            }

            let User = LoginManager.shared.getUser();
            return User;
        }
        catch{
            print("Error getting session ID.");
        }
        
        return nil;
    }
    
    private init(){}
    
    func sendAndReceive(_ request: any Request) async -> ServerResponse? {
        let json_encoder = JSONEncoder();
        
        do {
            guard let data = request.getRequestData() else {
                print("Error getting request data");
                return nil;
            }
            
            self.sendData(data: data);
            let (response_data, _, _, _) = try await self.connection!.asyncReceive();
            
            guard let data = response_data else {
                print("Error with response data");
                return nil;
            }
            
            let jsonDecoder = JSONDecoder();
            let serverResponse = try jsonDecoder.decode(ServerResponse.self, from: data);
            return serverResponse;
        }
        catch{
            print("\(error.localizedDescription)");
            return nil;
        }
    }
    
    func sendData(_ data: Codable, task: String) async {
        print("Sending Data");
        let json_encoder = JSONEncoder();
        guard let User = LoginManager.shared.getUser() else {
            return;
        }
        
        guard let session_key = User.session_key else {
            return;
        }
        guard let uuid = User.UUID else {
            return;
        }
        
        let codableObject = AnyCodable(data);
        let userRequest = UserRequest(task: task, data: codableObject, session_token: uuid);
        
        do {
            let data = try json_encoder.encode(userRequest)
            guard let encryptedData = Sec.shared.encryptWithSessionKey(data) else {
                print("Error: failed to encrypt outgoing data")
                return
            }
            // base64-encode so the server's decrypt_data can decode it with STANDARD.decode()
            self.sendData(data: encryptedData.base64EncodedData())
        }
        catch {
            return;
        }

    }

    /// Encrypted control message with a plain JSON-object payload, e.g.
    /// `{"task":"play","data":{"url":...,"zone":"default"},"session_token":...}`.
    /// The server (`commands::dispatch`) reads `data.url` / `data.zone`, so `data`
    /// must serialize as a nested object — unlike `sendData(_:task:)`/UserRequest,
    /// which encodes `data` as base64 and can't carry a `[String:String]` payload.
    private struct TaskMessage: Encodable {
        let task: String
        let data: [String: String]
        let session_token: String
    }

    /// Send a playback task (`play`/`stop`/…) with a string payload to the device.
    func sendTask(_ task: String, data: [String: String]) {
        guard let user = LoginManager.shared.getUser(),
              user.session_key != nil,
              let uuid = user.UUID else {
            print("sendTask(\(task)): no active device session")
            return
        }

        let message = TaskMessage(task: task, data: data, session_token: uuid.uuidString)
        do {
            let json = try JSONEncoder().encode(message)
            guard let encrypted = Sec.shared.encryptWithSessionKey(json) else {
                print("sendTask(\(task)): encryption failed")
                return
            }
            // base64 so the server's decrypt_data can STANDARD.decode() it.
            self.sendData(data: encrypted.base64EncodedData())
        } catch {
            print("sendTask(\(task)): encode failed: \(error)")
        }
    }

    func sendData(data: Data){
        if (!self.connected){
            self.start(ip_address: self.ip_address, port: self.port);
        }
        
        connection!.send(content: data, completion: .contentProcessed { sendError in
               if let error = sendError {
                   print("Failed to send data: \(error)")
               } else {
                   print("Data sent successfully")
               }
           })

    }
    
    private func receiveData(_ continue_receive: Bool = true) {
        self.connection!.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, context, isComplete, error in
               if let data = data, !data.isEmpty {
                   let receivedString = String(data: data, encoding: .utf8) ?? ""
                   print("Received: \(receivedString)")
               }

               if isComplete {
                   print("Connection closed by server.")
                   self.connected = false;
                   self.connection!.cancel()
                   return
               }
            else{
                print("CONNECTION STILL OPEN");
            }

               if let error = error {
                   print("Error receiving data: \(error)")
                   return
               }

               // Continue to receive data
            self.receiveData();
        }
       }
}
