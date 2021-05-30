//
//  APIRequestFactory.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-05-24.
//

import Foundation

/// Vend `APIRequest` for various functions.
class APIRequestFactory {
    var oauthHelpers = OauthHelpers()
    /// Get OAuth Request token which will be used later to construct the URL to seek user consent
    func createGetRequestTokenRequest() -> APIRequest {
        let callback = TWITTER_URL_SCHEME + "://success"

        var params: [String: String] = [
            "oauth_callback" : callback,
            "oauth_consumer_key" : TWITTER_CONSUMER_KEY,
            "oauth_nonce" : UUID().uuidString, // nonce can be any 32-bit string made up of random ASCII values
            "oauth_signature_method" : "HMAC-SHA1",
            "oauth_timestamp" : String(Int(NSDate().timeIntervalSince1970)),
            "oauth_version" : "1.0"
        ]

        let twitterAction: TwitterAction = .getRequestToken

        params["oauth_signature"] = oauthHelpers.oauthSignature(httpMethod: HTTPMethod.post.rawValue,
                                                                url: twitterAction.fullUrlString,
                                                                params: params,
                                                                consumerSecret: TWITTER_CONSUMER_SECRET,
                                                                oauthTokenSecret: nil)
        let authHeader = oauthHelpers.authorizationHeader(params: params)

        let apiRequest = APIRequest(twitterAction: twitterAction,
                                    queryParameters: [:],
                                    queryHeaders: ["Authorization": authHeader],
                                    body: nil)

        return apiRequest
    }

    /// Request to ask user to provide their consent so that the app can access their account. This particular `APIRequest` will not be executed
    /// directly. It's only being constructed so that we can get the final URL from it instead of constructing the URL manually.
    func createUserAuthorizationRequest() -> APIRequest {
        let requestToken = UserDefaults.standard.string(forKey: "requestToken")!
        let params: [String: String] = ["oauth_token" : requestToken]

        let apiRequest = APIRequest(twitterAction: .getUserApproval,
                                    queryParameters: params,
                                    queryHeaders: [:],
                                    body: nil)

        return apiRequest
    }

    /// Exchange `requestToken` for an `accessToken`.  The `accessToken` is what we wanted all-along and this is what will be used
    /// in every subsequent call to the Twitter API.
    func createGetAccessTokenRequest() -> APIRequest {
        let requestToken = UserDefaults.standard.string(forKey: "requestToken")!
        let requestTokenSecret = UserDefaults.standard.string(forKey: "requestTokenSecret")!
        let oauthVerifier = UserDefaults.standard.string(forKey: "oauthVerifier")!

        var params: [String: String] = [
            "oauth_token" : requestToken,
            "oauth_verifier" : oauthVerifier,
            "oauth_consumer_key" : TWITTER_CONSUMER_KEY,
            "oauth_nonce" : UUID().uuidString, // nonce can be any 32-bit string made up of random ASCII values
            "oauth_signature_method" : "HMAC-SHA1",
            "oauth_timestamp" : String(Int(NSDate().timeIntervalSince1970)),
            "oauth_version" : "1.0"
        ]

        let twitterAction: TwitterAction = .getAccessToken

        params["oauth_signature"] = oauthHelpers.oauthSignature(httpMethod: HTTPMethod.post.rawValue,
                                                                url: twitterAction.fullUrlString,
                                                                params: params,
                                                                consumerSecret: TWITTER_CONSUMER_SECRET,
                                                                oauthTokenSecret: requestTokenSecret)
        let authHeader = oauthHelpers.authorizationHeader(params: params)

        let apiRequest = APIRequest(twitterAction: twitterAction,
                                    queryParameters: [:],
                                    queryHeaders: ["Authorization": authHeader],
                                    body: nil)

        return apiRequest
    }

    /// Use `accessToken` to fetch user's home timeline.
    func createGetTimelineRequest() -> APIRequest {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        let accessTokenSecret = UserDefaults.standard.string(forKey: "accessTokenSecret")!


        var params: [String: String] = [
            "oauth_token" : accessToken,
            "oauth_consumer_key" : TWITTER_CONSUMER_KEY,
            "oauth_nonce" : UUID().uuidString, // nonce can be any 32-bit string made up of random ASCII values
            "oauth_signature_method" : "HMAC-SHA1",
            "oauth_timestamp" : String(Int(NSDate().timeIntervalSince1970)),
            "oauth_version" : "1.0"
        ]

        let queryParameters = ["tweet_mode": "extended",
                               "count": "50"]

        /// Note that the query parameters are being added to the list of params which are used to generate the signature.
        for (key, value) in queryParameters {
            params[key] = value
        }

        let twitterAction: TwitterAction = .getTimeline

        params["oauth_signature"] = oauthHelpers.oauthSignature(httpMethod: HTTPMethod.get.rawValue,
                                                                url: twitterAction.fullUrlString,
                                                                params: params,
                                                                consumerSecret: TWITTER_CONSUMER_SECRET,
                                                                oauthTokenSecret: accessTokenSecret)
        let authHeader = oauthHelpers.authorizationHeader(params: params)

        let apiRequest = APIRequest(twitterAction: twitterAction,
                                    queryParameters: queryParameters,
                                    queryHeaders: ["Authorization": authHeader],
                                    body: nil)

        return apiRequest
    }
    
}
