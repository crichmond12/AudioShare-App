//
//  Server Response.swift
//  Audio Share
//
//  Created by Christian Richmond on 6/9/24.
//

import Foundation
protocol ServerResponseData: Codable {
    func getData() -> String?;
}

