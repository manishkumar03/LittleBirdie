//
//  String++.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-04-03.
//

import Foundation

extension String {
    var urlEncoded: String {
        var charset: CharacterSet = .urlQueryAllowed
        charset.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
        return self.addingPercentEncoding(withAllowedCharacters: charset)!
    }
}

/// Break apart URL Query parameters into more usable values, i.e. transforming something like:
/// “param1=value1&param2=value2”
/// into a dictionary →
///    [ “param1”: “value1”, “param2”: “value2”]
extension String {
    var urlQueryStringParameters: Dictionary<String, String> {
        // breaks apart query string into a dictionary of values
        var params = [String: String]()
        let items = self.split(separator: "&")
        for item in items {
            let combo = item.split(separator: "=")
            if combo.count == 2 {
                let key = "\(combo[0])"
                let val = "\(combo[1])"
                params[key] = val
            }
        }
        return params
    }
}
