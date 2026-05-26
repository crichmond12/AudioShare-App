//
//  User Request.swift
//  Audio Share
//
//  Created by Christian Richmond on 6/1/24.
//

import Foundation
import SwiftUI

struct UserRequest: Codable {
    var session_token: UUID?;
    let task: String;
    let data: Data;
    
    init(task: String, data: AnyCodable, session_token: UUID?){
        
        do {
            let data_str = try JSONEncoder().encode(data.value);
            self.task = task;
            self.data = data_str;
            self.session_token = session_token;
        }
        catch {
            self.data  = Data();
            self.task = "Error";
        }
    }
    
}

struct UserResponse: Codable {
    var response: AnyCodable
}

struct AnyCodable: Codable {
    var value: Encodable;

    init<T: Codable>(_ value: T) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            self.value = intValue
            return
        }
        
        if let doubleValue = try? container.decode(Double.self) {
            self.value = doubleValue
            return
        }
        
        if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
            return
        }
        
        if let boolValue = try? container.decode(Bool.self) {
            self.value = boolValue
            return
        }
        
        if let dataValue = try? container.decode(Data.self) {
            self.value = dataValue;
            return;
        }
        
        if let arrayValue = try? container.decode([AnyCodable].self) {
            self.value = arrayValue.map { $0.value } as! any Encodable
            return
        }
        
        if let dictionaryValue = try? container.decode([String: AnyCodable?].self) {
            var dict = [String: Any?]()
            for (key, anyCodable) in dictionaryValue {
                dict[key] = anyCodable?.value
            }
            self.value = dict as! any Encodable
            return
        }
        
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode AnyCodable")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let intValue = value as? Int {
            try container.encode(intValue)
            return
        }
        
        if let doubleValue = value as? Double {
            try container.encode(doubleValue)
            return
        }
        
        if let stringValue = value as? String {
            try container.encode(stringValue)
            return
        }
        
        if let boolValue = value as? Bool {
            try container.encode(boolValue)
            return
        }
        
        if let dataValue = value as? Data {
            try container.encode(dataValue);
            return;
        }
        
        if let arrayValue = value as? [Any] {
            try container.encode(arrayValue.map { AnyCodable(any: $0) })
            return
        }
        
        if let dictionaryValue = value as? [String: Any?] {
            try container.encode(dictionaryValue.mapValues { $0 != nil ? AnyCodable(any: $0!) : nil })
            return
        }
        
        throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Unable to encode AnyCodable"))
    }
}

extension AnyCodable {
    init(any value: Any) {
        if let value = value as? Int {
            self.value = value
        } else if let value = value as? Double {
            self.value = value
        } else if let value = value as? String {
            self.value = value
        } else if let value = value as? Bool {
            self.value = value
        } else if let value = value as? [Any] {
            self.value = value.map { AnyCodable(any: $0) }
        } else if let value = value as? [String: Any] {
            self.value = value.mapValues { AnyCodable(any: $0) }
        } else {
            self.value = value as! any Encodable
        }
    }
}
