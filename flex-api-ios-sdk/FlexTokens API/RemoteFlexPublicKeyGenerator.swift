//
//  RemoteFlexPublicKeyGenerator.swift
//  flex-api-ios-sdk
//
//  Created by Joshua Russell on 2023-04-14.
//

import Foundation

final class RemoteFlexPublicKeyGenerator: FlexPublicKeyGenerator {
    
    struct JWK: Codable {
        var kty: String                // key type
        var use: String?                // key usage
        var kid: String?                // id
        // RSA keys
        // Represented as the base64url encoding of the value’s unsigned big endian representation as an octet sequence.
        var n: String?                    // modulus
        var e: String?                  // exponent
    }
    
    private let client: HTTPClient
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func getPublicKey(url: URL, completion: @escaping (FlexPublicKeyGenerator.Result) -> Void) {
        
        client.get(from: url) { result in
            
            switch result {
            case let .success((data, _)):
                
                if let jwkJson = try? JSONDecoder().decode(JWK.self, from: data) {
                    
                    guard let modulus = jwkJson.n,
                          let modulusData = JWTDecoder.data(base64urlEncoded: modulus),
                          let exponent = jwkJson.e,
                          let exponentData = JWTDecoder.data(base64urlEncoded: exponent) else {
                        
                        completion(.failure(Error.invalidData))
                        return
                    }
                    
                    guard let publicKey = try? CryptoUtils.publicKey(components: (modulusData, exponentData)) else {
                        
                        completion(.failure(Error.invalidData))
                        return
                    }
                    
                    completion(.success(publicKey))
                    
                } else {
                    completion(.failure(Error.invalidData))
                }
                break
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    
}
