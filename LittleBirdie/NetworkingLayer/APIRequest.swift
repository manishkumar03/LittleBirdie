//
//  APIRequest.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-03-25.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

/** The `APIRequest` struct carries all the information required to create a well-formed HTTP request

 An HTTP request needs the following parameters
 1. Base URL
 2. Path
 3. HTTP method (Optional, defaults to `GET`)
 4. Query parameters
 5. Request headers
 6. Body (raw binary data)
*/
public struct APIRequest {
    public var twitterAction: TwitterAction = .getTimeline
    public var queryParameters: [String: String] = [:]
    public var queryHeaders: [String: String] = [:]
    public var body: Data?

    /// Using `queryItems` on `URLComponents` is the cleanest way to specify query parameters in a URL.
    /// This avoids the usual methods of handling query parameters like adding `&` and `=` manually.
    public var targetUrlComponents: URLComponents {
        let url = twitterAction.fullUrl
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        urlComponents.queryItems = queryParameters.map({ (key, value) in
            URLQueryItem(name: key, value: value)
        })
        return urlComponents
    }

    /// A `URLRequest` is independent of the protocol or the URL scheme. It contains two essential properties
    /// of a network request: The URL to load and the policies used to load it. For HTTP(S) requests, it also
    /// contains the HTTP method (GET, POST etc) and also the HTTP headers.
    public var targetUrlRequest: URLRequest? {
        guard let targetUrl = targetUrlComponents.url else {
            return nil
        }

        var urlRequest = URLRequest(url: targetUrl)
        urlRequest.httpMethod = twitterAction.method.rawValue

        for (headerKey, headerValue) in queryHeaders {
            urlRequest.addValue(headerValue, forHTTPHeaderField: headerKey)
        }

        urlRequest.httpBody = body

        return urlRequest
    }

}
