//
//  OauthHelpers.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-04-03.
//

import Foundation
import CommonCrypto
/// OAuth 1.0a protocol does not assume the network connection to be secure; instead, it relies on a cryptographic hash function (HMAC-SHA1) to
/// verify the data integrity and authenticity of a message. Note that the data isn’t hidden from attackers; it just can’t be modified without the recipient knowing about it.
///
/// Contains all the auxiliary functions related to OAuth signatures etc.
class OauthHelpers {
    func oauthSignature(httpMethod: String = "POST",
                        url: String,
                        params: [String: Any],
                        consumerSecret: String,
                        oauthTokenSecret: String? = nil) -> String {
        let signingKey = signatureKey(consumerSecret, oauthTokenSecret)
        let signatureBase = signatureBaseString(httpMethod, url, params)
        return hmac_sha1(signingKey: signingKey, signatureBase: signatureBase)
    }

    func signatureKey(_ consumerSecret: String,_ oauthTokenSecret: String?) -> String {
        guard let oauthSecret = oauthTokenSecret?.urlEncoded else {
            return consumerSecret.urlEncoded+"&"
        }

        return consumerSecret.urlEncoded+"&"+oauthSecret
    }

    func signatureBaseString(_ httpMethod: String = "POST",_ url: String, _ params: [String:Any]) -> String {
        let parameterString = signatureParameterString(params: params)
        return httpMethod + "&" + url.urlEncoded + "&" + parameterString.urlEncoded
    }

    /// Converts a parameter dictionary to a URL-encoded string
    /// E.g. `["count": "5", "extended": "true"]` will get converted to `count=5&extended=true`
    func signatureParameterString(params: [String: Any]) -> String {
        var result: [String] = []
        for param in params {
            let key = param.key.urlEncoded
            let val = "\(param.value)".urlEncoded
            result.append("\(key)=\(val)")
        }
        return result.sorted().joined(separator: "&")
    }

    /// HMAC-SHA1 hashing algorithm returned as a base64 encoded string
    func hmac_sha1(signingKey: String, signatureBase: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1),
               signingKey,
               signingKey.count,
               signatureBase,
               signatureBase.count,
               &digest)
        let data = Data(digest)
        return data.base64EncodedString()
    }

    /// Construct OAuth header
    func authorizationHeader(params: [String: Any]) -> String {
        var parts: [String] = []
        for param in params {
            let key = param.key.urlEncoded
            let val = "\(param.value)".urlEncoded
            parts.append("\(key)=\"\(val)\"")
        }
        return "OAuth " + parts.sorted().joined(separator: ", ")
    }
}
