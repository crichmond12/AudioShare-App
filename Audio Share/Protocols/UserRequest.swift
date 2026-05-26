//
//  UserRequest.swift
//  Audio Share
//
//  Created by Christian Richmond on 6/13/24.
//

import Foundation

protocol Request: Codable {
    func encode(to encoder: Encoder);
    func getRequestData() -> Data?;
    init(from decoder: Decoder) throws;
    var task: String {get set};
}

extension Request {
    public func getRequestData() -> Data? {
        let mirror = Mirror(reflecting: self);
        var data: [String: String] = [:];
        
        for child in mirror.children {
            if let label = child.label {
                if let value = child.value as? String {
                    data[label] = value;
                }
            }
        }
        
        do {
            let json_data = try JSONEncoder().encode(data);
            guard let User = LoginManager.shared.getUser() else {
                return json_data;
            }
            guard let session_token = User.UUID else {
                return json_data;
            }
            
            guard let encrypted_data = Sec.shared.encryptWithSessionKey(json_data) else {
                print("Error encrypting data.")
                return json_data;
            }
            
            return encrypted_data.base64EncodedData();
        }
        catch {
            print("Error converting to json.");
            return nil;
        }
    }
    
    public func encode(to encoder: Encoder) {
        var container = encoder.singleValueContainer();
        
        do {
            try container.encode(self);
        }
        catch {
            
        }
    }
}
