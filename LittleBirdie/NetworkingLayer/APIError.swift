//
//  APIError.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-03-29.
//

import Foundation

/** The `APIError` struct carries all the information in case of a network call failure

 The response to a network call returns the following parameters
 1. `DerivedError`
    * Simplification of the original error
 2. Original Error
    * The original error object as received from the upstream systems. A `non-nil` value does _not_ indicate a successful call.

 In additon to the required details above, this struct also contains
 1. Original `APIRequest` which can be helpful in case we have to perform debugging.
 2. Original `APIResponse` which can be helpful in case we have to perform debugging. Useful to access HTTP status code, data object etc.
 */
public struct APIError<DataModel>:Error {
    public enum DerivedError {
        case badUrl
        case failedToFetch
        case invalidJson
        case failedToDecode
    }

    public let derivedError: DerivedError

    public let originalError: Error?

    /// Even though `APIResponse` also contains the same `APIRequest`, it's still helpful to have it here
    /// for those cases where the `APIResponse` is nil. E.g., when the URL in the request is malformed and thus
    /// no network request is made, having the `APIRequest` in the returned `APIError` object will be a huge help for debugging.
    public let originalRequest: APIRequest

    public let originalResponse: APIResponse<DataModel.Type>?
}
