//
//  ServiceDiscovery.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/21/24.
//

import Foundation;
import Network;
//import Combine;

class ServiceDiscoveryManager: NSObject, NetServiceBrowserDelegate, NetServiceDelegate, ObservableObject {
    
    @Published var services: [NWEndpoint:NetService] = [:];
    private var browser: NWBrowser?;
    //var serviePublisher = PassthroughSubject<[NWEndpoint:NetService], Never>()

    
    func discoverService() {
        let networkAuth = LocalNetworkAuthorization()
        networkAuth.requestAuthorization(completion: { auth in
            if auth {
                let params = NWParameters()
                params.includePeerToPeer = true
                
                self.browser = NWBrowser(for: .bonjour(type: "_audioshare._tcp", domain: ""), using: params)
                
                self.browser!.stateUpdateHandler = { newState in
                    switch newState {
                    case .ready:
                        print("Browser ready")
                    case .failed(let error):
                        print("Browser failed with error: \(error)")
                    default:
                        break
                    }
                }
                
                self.browser!.browseResultsChangedHandler = { results, changes in
                    var newServices: [NWEndpoint: NetService] = [:];
                    for result in results {
                        if case let NWEndpoint.service(name, type, domain, _) = result.endpoint {
                            print("SERVICE: \(name)");
                            let netService = NetService(domain: domain, type: type, name: name)
                            netService.delegate = self;
                            netService.resolve(withTimeout: 1);
                            newServices[result.endpoint] = netService;

                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.services = newServices
                    }
                }
                

                self.browser!.start(queue: .main)
                
            }
        })
    }
    
    func cancel(){
        self.browser!.cancel();
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("Failed to resolve service: \(errorDict)")
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
            if let txtRecordData = sender.txtRecordData() {
                let txtRecordDictionary = NetService.toDictionary(fromTXTRecord: txtRecordData)
                print("TXT Record Dictionary: \(txtRecordDictionary)")
            } else {
                print("No TXT record data found.")
            }
        }
    
    func matchSerialNumber(serial_code: String) -> NetService? {
        for (endpoint, netService) in self.services {
            
            if let txtRecordData = netService.txtRecordData() {
                let txtRecordDictionary = NetService.toDictionary(fromTXTRecord: txtRecordData)
                
                if txtRecordDictionary.contains(where: { $0.key == "serial_number" }){
                    if (txtRecordDictionary["serial_number"] == serial_code){
                        return netService;
                    }
                }
            }
        }
    
        return nil;
    }
    func connectToService(service: NetService) {
    }

    /// Stop browsing. Safe to call even if discovery never started.
    func stop() {
        self.browser?.cancel()
    }

    /// Wait up to `timeout` seconds for an mDNS-discovered Audio Share device
    /// that we already hold a Keychain pairing secret for, and return it with
    /// its serial number. This is what makes QR-free reconnect possible: the
    /// serial comes from the live TXT record and the secret from the Keychain,
    /// so no scan is needed. Polls because resolution (addresses + TXT) lands
    /// asynchronously after each service is found.
    func awaitPairedService(timeout: TimeInterval) async -> (NetService, String)? {
        let keychain = KeychainManager()
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            let snapshot = self.services
            for (_, netService) in snapshot {
                guard let txtData = netService.txtRecordData() else { continue }
                let txt = NetService.toDictionary(fromTXTRecord: txtData)
                guard let serial = txt["serial_number"],
                      keychain.loadPairingSecret(for: serial) != nil,
                      let addresses = netService.addresses, !addresses.isEmpty else {
                    continue
                }
                return (netService, serial)
            }
            try? await Task.sleep(nanoseconds: 250_000_000) // 0.25s
        }
        return nil
    }

    private func getIPAddress(from data: Data) -> String? {
            var storage = sockaddr_storage()
            (data as NSData).getBytes(&storage, length: data.count)
            
            switch Int32(storage.ss_family) {
            case AF_INET:
                var addr = sockaddr_in()
                memcpy(&addr, &storage, MemoryLayout<sockaddr_in>.size)
                var buffer = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
                let addressCString = inet_ntop(AF_INET, &addr.sin_addr, &buffer, socklen_t(INET_ADDRSTRLEN))
                return addressCString.map { String(cString: $0) }
                
            case AF_INET6:
                var addr = sockaddr_in6()
                memcpy(&addr, &storage, MemoryLayout<sockaddr_in6>.size)
                var buffer = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
                let addressCString = inet_ntop(AF_INET6, &addr.sin6_addr, &buffer, socklen_t(INET6_ADDRSTRLEN))
                return addressCString.map { String(cString: $0) }
                
            default:
                return nil
            }
        }
    
    public func getHostData(netService: NetService) -> (String, Int)? {
        if let addresses = netService.addresses {
                    for address in addresses {
                        if let ip_address = getIPAddress(from: address) {
                            let port = 50505;//service.port
                            print("Resolved IP: \(ip_address), port: \(port)")
                            return (ip_address, port);
                            // Establish connection using NWConnection
                            //self.connection = NWConnection(host: NWEndpoint.Host(ip), port: NWEndpoint.Port(rawValue: UInt16(port))!, using: .tcp)
                        }
                    }
                }
        return nil;
    }
    // MARK: - NetServiceBrowserDelegate

    /*func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        services.append(service)
        if !moreComing {
            // All services have been discovered
            resolveServices()
        }
    }

    func resolveServices() {
        for service in services {
            service.delegate = self
            service.resolve(withTimeout: 10)
        }
    }

    // MARK: - NetServiceDelegate

    func netServiceDidResolveAddress(_ sender: NetService) {
        // Access and parse TXT record using sender.txtRecordData
        // Compare values against expected values
        // Open connection if values match
    }*/
}

extension NetService {
    func getTxtRecord() {
        self.resolve(withTimeout: 1)
    }
    /// Convert TXT record data to a dictionary.
    static func toDictionary(fromTXTRecord txtData: Data) -> [String: String] {
        var result = [String: String]()

        let txtRecordDictionary = NetService.dictionary(fromTXTRecord: txtData)
        for (key, value) in txtRecordDictionary {
            if let valueData = value as Data?, let valueString = String(data: valueData, encoding: .utf8) {
                result[key] = valueString
            }
        }

        return result
    }
}
