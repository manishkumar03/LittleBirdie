//
//  APIResponse.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-03-29.
//

import Foundation

/** The `APIResponse` struct carries all the information received as the result of executing an `APIRequest`

 The response to a network call returns the following parameters
 1. URLResponse
    * Independent of protocol and URL scheme. For HTTP requests, it's cast to `HTTPURLResponse` to obtain response headers etc. Also contains the HTTP status codes.
 2. Data
    * Optional, raw binary data. It can be a JSON, or a jpeg image, or an XML etc. A `non-nil` value does _not_ indicate a successful call.
 3. Error
    * Additional details in case the request fails. A `nil` value does _not_ indicate a successful call. Stored in `APIError` struct.

 In additon to the required details above, this struct also contains
 1. Original `APIRequest` which can be helpful in case we have to perform debugging.
 2. Binary JSON converted to `DataModel` struct
 */
public struct APIResponse<DataModel> {
    public let originalData: Data?
    public let originalResponse: URLResponse?
    public let decodedDataModel: DataModel
    public let apiRequest: APIRequest
}
