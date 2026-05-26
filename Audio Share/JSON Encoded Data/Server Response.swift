//
//  Server Response.swift
//  Audio Share
//
//  Created by Christian Richmond on 6/9/24.
//

import Foundation

struct ServerResponse:Codable {
    let response: String;
    
    public func getSessionKey() throws -> SessionKey? {
        do{
            guard let responseData: Data = self.response.data(using: .utf8) else {
                print("Error getting response data")
                return nil;
            }
            
            let responseObj = try JSONDecoder().decode(SessionKey.self, from: responseData);
            return responseObj;
        }
        catch{
            throw ConnectionError.runtimeError("Server Response is not for a session key");
        }
    }
    
    public func getResponseObject() -> ServerResponseData? {
        let responseTypes = [
            SessionKey.self,
        ];
        
        for responseType in responseTypes {
            do{
                guard let responseData: Data = self.response.data(using: .utf8) else {
                    print("Error getting response data")
                    return nil;
                }
                
                let responseObj = try JSONDecoder().decode(responseType, from: responseData);
                return responseObj;
            }
            catch{
                continue;
            }
        }
        
        return nil;
    }
    
}
