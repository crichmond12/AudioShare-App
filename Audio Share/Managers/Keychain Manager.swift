//
//  Keychain Manager.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/25/24.
//

//
//  KeychainManager.swift
//  SchoolPathways
//
//  Created by Christian Richmond on 2/18/24.
//
import Foundation
import CryptoKit

class KeychainManager {
    private let service = "AudioShareAccountInfo"
    //private let lastUsedUsernameKey = "LastUsedUsername"
    private let username = "UserName"

    func saveDeviceSerialNumbers(serial_numbers: Array<String>) -> Bool{
        do {
            let serialNumbersData = try NSKeyedArchiver.archivedData(withRootObject: serial_numbers, requiringSecureCoding: true);
                
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: "audio_share",
                kSecValueData as String: serialNumbersData
            ]
            
            // Delete any existing item for the service
            SecItemDelete(query as CFDictionary)
            let status = SecItemAdd(query as CFDictionary, nil)
            return status == errSecSuccess
        }
        catch{
            return false;
        }
    }
    func getSerialNumbers() -> [String]? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "audio_share",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data {
            do {
                 if let serialNumbers = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSString.self], from: data) as? [String] {
                     return serialNumbers
                 }
             } catch {
                 print("Error retrieving serial numbers:", error)
             }
        }
        return nil
    }

    
    func addDeviceSerialNumber(serial_number: String) -> Bool{
        var serial_numbers = getSerialNumbers();
        serial_numbers!.append(serial_number);
        
        return saveDeviceSerialNumbers(serial_numbers: serial_numbers!)
    }
    
    func removeDeviceSerialNumber(serial_number: String) -> Bool{
        var serial_numbers = getSerialNumbers();
        let new_serial_numbers = serial_numbers!.filter{$0 != serial_number};
        return saveDeviceSerialNumbers(serial_numbers: new_serial_numbers);
    }
    
    func savePrivateKey(_ privateKey: Curve25519.KeyAgreement.PrivateKey, for tag: String) -> Bool {
        let privateKeyData = privateKey.rawRepresentation

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecValueData as String: privateKeyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        // Delete any existing key with the same tag
        SecItemDelete(query as CFDictionary)

        // Add the key to the keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func savePublicKey(_ publicKey: Curve25519.KeyAgreement.PublicKey, for tag: String) -> Bool {
        let publicKeyData = publicKey.rawRepresentation

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecValueData as String: publicKeyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
    

        // Delete any existing key with the same tag
        SecItemDelete(query as CFDictionary)

        // Add the key to the keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    

    
    func loadPrivateKey(tag: String) -> Curve25519.KeyAgreement.PrivateKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }

        guard let privateKeyData = item as? Data else { return nil }
        return try? Curve25519.KeyAgreement.PrivateKey(rawRepresentation: privateKeyData)
    }

    func loadPublicKey(tag: String) -> Curve25519.KeyAgreement.PublicKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnData as String: kCFBooleanTrue!
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status != errSecSuccess {
            print("Error retrieving key from keychain: \(status)")
            return nil
        }

        guard let publicKeyData = item as? Data else {
            print("Failed to cast retrieved item to Data")
            return nil
        }
        
        do {
            return try Curve25519.KeyAgreement.PublicKey(rawRepresentation: publicKeyData)
        } catch {
            print("Failed to create public key from raw representation: \(error)")
            return nil
        }
    }

    
    func saveCredentials(username: String, password: String) -> Bool {
        // Define the item attributes
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: username,
            kSecValueData as String: password.data(using: .utf8)!, // Convert password to Data
        ]
        

        // Add or update the item in the Keychain
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status != errSecSuccess {
            print("Keychain save error: \(status)")
            return false;
        }
        updateUsername(username)
    
        return true;

    }
    
    private func addDeviceSerialNumber(serial_number: String){
        
    }
    
    private func updateUsername(_ username: String?) {
            // Update the last used username in UserDefaults
        UserDefaults.standard.set(username, forKey: self.username)
        }
    
    func getUsername() -> String {
        let lastUsedUsername = UserDefaults.standard.string(forKey: username)
        guard let username = lastUsedUsername else {
            return ""
            }
        
        return username
        }

    func getCredentials() -> (username: String?, password: String?, pkey: Data?) {
        let username = UserDefaults.standard.string(forKey: username)

        // Define the query attributes
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: username!,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        // Try to retrieve the item from the Keychain
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        // Check if the item was found
        guard status == errSecSuccess else {
            print("Keychain query error: \(status)")
            return (nil, nil, nil)
        }

        // Extract the password and organization from the item
        guard let itemAttributes = item as? [String: Any],
              let passwordData = itemAttributes[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: .utf8),
              let pkey = itemAttributes[kSecAttrGeneric as String] as? Data else {
            print("Keychain data extraction error")
            return (nil, nil, nil)
        }

        return (username, password, pkey)
    }
    
    func areCredentialsSaved() -> Bool {
           // Define the query attributes to retrieve all items for the service
           let query: [String: Any] = [
               kSecClass as String: kSecClassGenericPassword,
               kSecAttrService as String: service,
               kSecMatchLimit as String: kSecMatchLimitAll,
               kSecReturnAttributes as String: true
           ]

           // Try to retrieve all items for the service from the Keychain
           var items: CFTypeRef?
           let status = SecItemCopyMatching(query as CFDictionary, &items)

           // Check if the items were found
           if status == errSecSuccess {
               let itemArray = items as! [NSDictionary]
               return !itemArray.isEmpty
           } else if status == errSecItemNotFound {
               return false
           } else {
               return false
           }
       }
}

