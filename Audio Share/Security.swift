//
//  Security.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/20/24.
//

import Foundation
import CryptoKit

class Sec {
    
    public static let shared = Sec();
    private let keychainManager = KeychainManager();
    private let loginManager = LoginManager.shared;
    
    private init(){
        
    }
    
    func generateKeyPair() -> (publicKey: Curve25519.KeyAgreement.PublicKey, privateKey: Curve25519.KeyAgreement.PrivateKey)? {
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey;
        
        return (publicKey, privateKey)
    }

    /*func signMessage(message: Data, privateKey: Curve25519.KeyAgreement.PrivateKey) -> Data? {
        guard let privateKey = try? Curve25519.KeyAgreement.PrivateKey(rawRepresentation: privateKey.rawRepresentation) else {
            print("Error creating private key")
            return nil
        }
        
        //let signature = try? privateKey.signature(for: message)
        return signature
    }*/

    func savePrivateKeyToKeychain(privateKeyData: Data, identifier: String) -> Bool {
        // Create a query dictionary to specify the search criteria
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: identifier,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom, // Use the appropriate key type
            kSecValueData as String: privateKeyData,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked // Adjust accessibility as needed
        ]
        
        // Attempt to delete any existing private key with the same identifier
        SecItemDelete(query as CFDictionary)
        
        // Add the private key to the Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        // Check if the operation was successful
        return status == errSecSuccess
    }
    
    func encryptWithSessionKey(_ data: Data) -> Data? {
        do {
            guard let User = LoginManager.shared.getUser() else {
                print("No logged in user found.");
                return nil;
            }
            
            guard let session_key = User.session_key else {
                print("Session Key Not Found.");
                return nil;
            }
            // Generate a random nonce for each encryption
            let nonce = AES.GCM.Nonce()
            let sealedBox = try AES.GCM.seal(data, using: session_key, nonce: nonce)

            // Combine nonce and ciphertext
            let combined = nonce + sealedBox.ciphertext + sealedBox.tag
            return combined
            } catch {
                print("Error encrypting data: \(error)")
                return nil
            }
    }
    
    func getSessionData(json: SessionKey) -> (UUID, SymmetricKey)? {
        guard let encryptedData = Data(base64Encoded: json.session) else {
            print("Could not decode base64 session key")
            return nil;
        }
        
        guard let User = loginManager.getUser() else {
            return nil;
        }
        let username = User.username;
        
        guard let private_key = self.keychainManager.loadPrivateKey(tag: "\(username!)_audioshare_pkey") else{
            return nil;
        }
        
        guard let public_key = self.keychainManager.loadPublicKey(tag: "\(username!)_audioshare_pubkey") else {
            return nil;
        }
        
        let nonce = encryptedData.prefix(12)
        let ciphertextAndTag = encryptedData.dropFirst(12).dropLast(32)
        let serverPublicKeyData = encryptedData.suffix(32)
        
        guard let server_public_key = try? Curve25519.KeyAgreement.PublicKey(rawRepresentation: serverPublicKeyData) else {
               print("Failed to create server public key")
               return nil
           }
       
        // Combine ciphertext and tag
        //let combinedCiphertext = ciphertext + tag
        let combined = nonce + ciphertextAndTag;
        
        do {
            
            let sharedSecret = try private_key.sharedSecretFromKeyAgreement(with: server_public_key)
                   let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
                       using: SHA256.self,
                       salt: Data(),
                       sharedInfo: Data(),
                       outputByteCount: 32
                   )

                   // Initialize SealedBox with nonce, ciphertext, and tag
                  let sealedBox = try AES.GCM.SealedBox(combined: combined)

                   // Decrypt the session key using the symmetric key
                   let decryptedSessionKey = try AES.GCM.open(sealedBox, using: symmetricKey)

                   // Convert the decrypted session key to a SymmetricKey
                   let sessionSymmetricKey = SymmetricKey(data: decryptedSessionKey)

                   return (UUID(uuidString: json.uuid)!, sessionSymmetricKey)
            // Initialize SealedBox with nonce, ciphertext, and tag
            /*let sealedBox = try AES.GCM.SealedBox(combined: nonce + ciphertext);
           
            // Derive the shared secret from the private key and the corresponding public key
            let sharedSecret = try private_key.sharedSecretFromKeyAgreement(with: public_key)
           
            // Derive the symmetric key from the shared secret
            let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
                using: SHA256.self,
                salt: Data(),
                sharedInfo: Data(),
                outputByteCount: 32
            )
           
           // Decrypt the session key using the symmetric key
           let decryptedSessionKey = try AES.GCM.open(sealedBox, using: symmetricKey)
            print("HERERERE");
           
           // Convert the decrypted session key to a SymmetricKey
           let sessionSymmetricKey = SymmetricKey(data: decryptedSessionKey)
           
           return (UUID(uuidString: json.uuid)!, sessionSymmetricKey)*/
       } catch {
           print("Error decrypting session key: \(error)")
           return nil
       }
         
        // Decrypt the ciphertext using AES-GCM
    }
    public func decryptMessage(encryptedData: Data) -> UserRequest? {
        
        guard let User = LoginManager.shared.getUser() else {
            return nil;
        }
        
        guard let session_key = User.session_key else {
            return nil;
        }
        
        // Perform key agreement to derive the shared secret
        // In this simplified example, assume the server used a shared secret derived from the device's public key for encryption
        // Let's use AES-GCM for decryption as an example
        /*let nonce = session_key.prefix(12); // 12-byte nonce
        let ciphertext = session_key.dropFirst(12).dropLast(16);
        
        let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonce), ciphertext: ciphertext)
        let decryptedData = try AES.GCM.open(sealedBox, using: session_key)
         */
                 
        //return decryptedData
        return nil;

    }
}

