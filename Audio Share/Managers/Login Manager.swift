//
//  Login Manager.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/26/24.
//

import Foundation
import SwiftUI;
import CryptoKit;

struct User {
    var username: String?
    var login_ts: TimeInterval?
    let human: Bool
    var UUID: UUID?
    var session_key: SymmetricKey?
}

class LoginManager : ObservableObject {
    public static let shared = LoginManager();
    @Published var isLoggedIn = false
    @Published var user: User = User(human: false)
    @Published var isConnectedToDevice = false;
    
    //private var user
    
    private init(){
        
    }

    
    func login(username: String, password: String) async -> Bool {
        let formData: [String: String] = [
           "email": username,
           "password": password,
        ];
        
        let data = await ConnectionManager.post(method: "authenticateUser", formData: formData);
        guard let success = data?["success"] else {
            return false;
        }
        if (success) as! Bool {
            await MainActor.run {
                withAnimation {
                    let currentDate = Date()
                    let usersID = data?["users_id"];
                    self.user = User(username: username, login_ts: currentDate.timeIntervalSince1970, human: true, UUID: usersID as? UUID)
                    self.isLoggedIn = true
                }
            }
            
            /*if (await self.login(username: username, password: password)){
                return true;
            }*/
            return true;
        }
        
        return false;
    }
    func createUser(username: String, password: String) async -> Bool {
        do {
            let formData: [String: String] = [
               "email": username,
               "password": password,
            ];
            
            let data = await ConnectionManager.post(method: "createUser", formData: formData);
            guard let success = data?["success"] else {
                return false;
            }
            if (success) as! Bool {
                if (await self.login(username: username, password: password)){
                    return true;
                }
            }
            
            return false;
        }
    }
    func getUser() -> User? {
        return self.user
    }
    
    func userLoggedIn() -> Bool{
        return self.isLoggedIn
    }
    
    func setSessionKey(uuid: UUID, session_key: SymmetricKey){
        self.user.UUID = uuid;
        self.user.session_key = session_key;
        self.isConnectedToDevice = true;
    }
    
}
