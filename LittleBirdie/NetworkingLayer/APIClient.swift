//
//  APIClient.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-03-26.
//

import Foundation

typealias APIResult<DataModel> = Result<APIResponse<DataModel>, APIError<DataModel>>

protocol APIRequestToResponseConverting {
    func execute<DataModel: Codable>(apiRequest: APIRequest,
                                     dataModel: DataModel.Type,
                                     completion: @escaping (APIResult<DataModel>) -> Void)
}

/** The `APIClient` struct makes the actual network call and handles the response.

 It contains the following components:
 1. `APIRequest`
 * The only required input. Contains everything required to make a network call.
 2. `RequestAdapter`
 * Functions which modify the request before executing the request and modify the response after the call execution.
 3. `APIResult`
 * A `Result` enum containing either an `APIResponse` or an `APIError`.
 */
class APIClient: APIRequestToResponseConverting {
    public var urlSession = URLSession.shared
    public var adapters: [RequestAdapter]

    init(configuration: URLSessionConfiguration = .default, adapters: [RequestAdapter] = []) {
        self.urlSession = URLSession(configuration: configuration)
        self.adapters = adapters
    }

    public func execute<DataModel: Codable>(apiRequest: APIRequest,
                                            dataModel: DataModel.Type,
                                            completion: @escaping (APIResult<DataModel>) -> Void) {
        var apiRequest = apiRequest

        /// Adapters are functions which are used to modify requests before executing them.
        self.adapters.forEach { (adapter) in
            adapter.adapt(&apiRequest)
            adapter.beforeSend(&apiRequest)
        }

        /// Handle malformed URLs
        guard let targetUrlRequest = apiRequest.targetUrlRequest else {
            let apiError = APIError<DataModel>(derivedError: .badUrl,
                                               originalError: nil,
                                               originalRequest: apiRequest,
                                               originalResponse: nil)
            completion(.failure(apiError))
            return
        }

        let task = urlSession.dataTask(with: targetUrlRequest) { (data, response, error) in
            /// If error object is not `nil`, there is definitely an error. Note that a `nil` does not mean that there is no error!
            if let error = error {
                let apiResponse = APIResponse(originalData: data,
                                              originalResponse: response,
                                              decodedDataModel: DataModel.self,
                                              apiRequest: apiRequest)
                let apiError = APIError<DataModel>(derivedError: .failedToFetch,
                                                   originalError: error,
                                                   originalRequest: apiRequest,
                                                   originalResponse: apiResponse)
                completion(.failure(apiError))
                return
            }

            /// At this point, the error object in the server response is `nil` but that does not mean that there is no error!
            /// Check the HTTP status code to determine success/failure but this is also not a foolproof method. In some cases, the status code could be `200` which
            /// only means that the _call_ was successful (it made a round trip) even though it did not do what we intended it to do.
            if let response = response as? HTTPURLResponse {
                if let statusCode: HTTPStatusCode = HTTPStatusCode(rawValue: response.statusCode) {
                    if statusCode.responseType == .success {
                        // All good
                    } else {
                        let apiResponse = APIResponse(originalData: data,
                                                      originalResponse: response,
                                                      decodedDataModel: DataModel.self,
                                                      apiRequest: apiRequest)
                        let originalErrorMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode.rawValue)
                        let translatedError = NSError(domain: "",
                                                      code: statusCode.rawValue,
                                                      userInfo: [NSLocalizedDescriptionKey : originalErrorMessage])
                        let apiError = APIError<DataModel>(derivedError: .failedToFetch,
                                                           originalError: translatedError,
                                                           originalRequest: apiRequest,
                                                           originalResponse: apiResponse)
                        completion(.failure(apiError))
                        return
                    }
                }
            }

            /// At this stage, the error is nil and the HTTP status code is indicating success. That does not however mean that the data is non-`nil`.
            guard var data = data else {
                let apiResponse = APIResponse(originalData: nil,
                                              originalResponse: response,
                                              decodedDataModel: DataModel.self,
                                              apiRequest: apiRequest)
                let apiError = APIError<DataModel>(derivedError: .failedToFetch,
                                                   originalError: error,
                                                   originalRequest: apiRequest,
                                                   originalResponse: apiResponse)
                completion(.failure(apiError))
                return
            }

            self.adapters.forEach { (adapter) in
                adapter.onResponse(receivedData: &data)
            }

            /// At this stage, the error is `nil`, the HTTP status code is indicating success, and the data is non-`nil`.
            /// Need to check if the data is actually well-formed i.e. its contents are in the format specified by `DataModel`.
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedDataModel = try decoder.decode(DataModel.self, from: data)
                let apiResponse = APIResponse(originalData: data,
                                              originalResponse: response,
                                              decodedDataModel: decodedDataModel,
                                              apiRequest: apiRequest)
                completion(.success(apiResponse))
            } catch let decodingError {
                let apiResponse = APIResponse(originalData: data,
                                              originalResponse: response,
                                              decodedDataModel: DataModel.self,
                                              apiRequest: apiRequest)
                let apiError = APIError<DataModel>(derivedError: .failedToDecode,
                                                   originalError: decodingError,
                                                   originalRequest: apiRequest,
                                                   originalResponse: apiResponse)
                completion(.failure(apiError))
            }
        }

        task.resume()
    }
}
