//
//  NWConnection Extension.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/28/24.
//

import Foundation
import Network

extension NWConnection {
    func asyncReceive(minimumIncompleteLength: Int = 1, maximumLength: Int = 65536) async throws -> (Data?, NWConnection.ContentContext?, Bool, NWError?) {
        return try await withCheckedThrowingContinuation { continuation in
            self.receive(minimumIncompleteLength: minimumIncompleteLength, maximumLength: maximumLength) { data, context, isComplete, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (data, context, isComplete, nil))
                }
            }
        }
    }
}
