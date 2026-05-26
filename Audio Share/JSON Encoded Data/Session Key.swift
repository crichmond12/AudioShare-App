//
//  Session Key.swift
//  Audio Share
//
//  Created by Christian Richmond on 6/1/24.
//

import Foundation
struct SessionKey: Codable, ServerResponseData {
    let uuid: String;
    let session: String;
    
    public func getData() -> String? {
        do {
            let json_str = try String(data: JSONEncoder().encode(self), encoding: .utf8);
            return json_str;
        }
        catch {
            print("Issue getting json string");
            return nil;
        }
        
    }
    
}


