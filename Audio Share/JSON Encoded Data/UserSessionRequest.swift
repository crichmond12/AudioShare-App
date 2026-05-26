//
//  UserSessionRequest.swift
//  Audio Share
//
//  Created by Christian Richmond on 6/13/24.
//

import Foundation

struct UserSessionRequest:Request {
    
    private var public_key: String;
    internal var task: String = "getSessionID";
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            self.public_key = stringValue;
            return
        }
        
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode UserSessionRequest")
    }
    
    public init (_ public_key_str: String) {
        self.public_key = public_key_str;
    }    
}
