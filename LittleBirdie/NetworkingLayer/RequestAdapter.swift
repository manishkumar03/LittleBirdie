//
//  RequestAdapter.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-04-09.
//

import Foundation

/// Used to modify the requests before execution or to modify the response after execution.
///
/// It can be helpful in the following cases:
/// * Need to add default headers to the request
/// * Need to add query parameters for certain requests
/// * Need to sanitize the received JSON
public protocol RequestAdapter {
    func adapt(_ request: inout APIRequest)
    func beforeSend(_ request: inout APIRequest)
    func onResponse(receivedData: inout Data)
}

/// Since all these functions are optional, create default empty implementations for them
public extension RequestAdapter {
    func adapt(_ request: inout APIRequest) {}
    func beforeSend(_ request: inout APIRequest) {}
    func onResponse(receivedData: inout Data) {}
}

/// Twitter does not return a JSON object on successful OAuth calls. Instead, it returns a plain string in the following format:
/// "oauth_token=ODxj...&oauth_token_secret=ShVss...&oauth_callback_confirmed=true"
/// This plain string has to be converted to a JSON object so that the it can follow the regular program flow
struct SanitizeJSON: RequestAdapter {
    func onResponse(receivedData: inout Data) {
        var isJsonValid = false

        if let jsonObject = try? JSONSerialization.jsonObject(with: receivedData, options: .allowFragments) {
            isJsonValid = JSONSerialization.isValidJSONObject(jsonObject)
        }

        if isJsonValid {
            // Nothing to do. `receivedData` is already good.
        } else {
            if let responseString = String(data: receivedData, encoding: .utf8), responseString.hasPrefix("oauth_token") {
                let json = """
                    {
                        "responseString": "\(responseString)"
                    }
                    """
                receivedData = json.data(using: String.Encoding.utf8)!
            }
        }
    }
}

struct AddDefaultHeaders: RequestAdapter {
    func beforeSend(_ request: inout APIRequest) {
        let defaultHeaders : [String: String] = [
            "User-Agent": "My Macbook Pro"
        ]

        request.queryHeaders.merge(defaultHeaders) { (old, new) in new }
    }
}
