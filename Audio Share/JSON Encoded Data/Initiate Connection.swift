//
//  Initiate Connection.swift
//  Audio Share
//
//  Created by Christian Richmond on 6/14/24.
//

import Foundation

struct InitiateConnection: Request {
    private let session_token: String;
    internal var task: String = "InitiateConnection";
    
    public init() {
        guard let User = LoginManager.shared.getUser() else {
            self.session_token = "";
            return;
        }
        
        guard let uuid = User.UUID?.uuidString else {
            self.session_token = "";
            return;
        }
        
        self.session_token = uuid;
    }
}
