//
//  ModelHelper.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-04-07.
//

import Foundation

public protocol ModelProtocol: Codable {
    static var decoder: JSONDecoder { get }
    static var encoder: JSONEncoder { get }
}

public extension ModelProtocol {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}
