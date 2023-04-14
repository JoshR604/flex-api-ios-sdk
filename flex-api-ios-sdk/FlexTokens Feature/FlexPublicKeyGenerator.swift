//
//  FlexPublicKeyGenerator.swift
//  flex-api-ios-sdk
//
//  Created by Joshua Russell on 2023-04-14.
//

import Foundation

protocol FlexPublicKeyGenerator {
    typealias Result = Swift.Result<SecKey, Error>
    
    func getPublicKey(url: URL, completion: @escaping (Result) -> Void)
}
