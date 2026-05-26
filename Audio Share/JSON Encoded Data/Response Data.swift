//
//  Response Data.swift
//  Audio Share
//
//  Created by Christian Richmond on 6/9/24.
//

import Foundation
struct ResponseData: Codable {
    private let _decode: (Decoder) throws -> ServerResponseData
    
    init<T: ServerResponseData>(_ type: T.Type) {
        self._decode = { decoder in
            try T(from: decoder)
        }
    }
    
    init(from decoder: Decoder) throws {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Cannot decode AnyResponseData directly"))
    }

    func decode(from decoder: Decoder) throws -> ServerResponseData {
        try _decode(decoder)
    }
    
    func encode(to encoder: Encoder) throws {
        throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Cannot encode AnyResponseData directly"))
    }
}
