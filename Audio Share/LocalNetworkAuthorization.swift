//
//  LocalNetworkAuthorization.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/18/24.
//

import Foundation
import Network

public class LocalNetworkAuthorization: NSObject {
    private var browser: NWBrowser?
    private var netService: NetService?
    private var completion: ((Bool) -> Void)?
    private var discoveredServices: [String] = []

    public func requestAuthorization(completion: @escaping (Bool) -> Void) {
        self.completion = completion

        // Create parameters and allow browsing over peer-to-peer link.
        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        // Browse for the custom service type.
        let browser = NWBrowser(for: .bonjour(type: "_audioshare._tcp", domain: nil), using: parameters)
        self.browser = browser
        browser.stateUpdateHandler = { newState in
            switch newState {
            case .failed(let error):
                print("Browser failed with error: \(error.localizedDescription)")
                self.reset()
                self.completion?(false)
            case .ready:
                print("Browser is ready")
            case .waiting(let error):
                print("Browser is waiting with error: \(error.localizedDescription)")
            default:
                break
            }
        }

        browser.browseResultsChangedHandler = { results, changes in
            print(results)
            print(changes)
            /*for result in results {
                if case let .service(service) = result.endpoint {
                    print("Discovered service: \(service)")
                    self.discoveredServices.append(service.name)
                }
            }*/
            self.completion?(true)
        }

        self.browser?.start(queue: .main)
    }

    private func reset() {
        self.browser?.cancel()
        self.browser = nil
        self.netService?.stop()
        self.netService = nil
    }
}
