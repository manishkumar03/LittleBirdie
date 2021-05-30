//
//  TwitterAction.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-03-26.
//

import Foundation

public enum TwitterAction {
    case getRequestToken
    case getUserApproval
    case getAccessToken
    case getTimeline

    var baseUrl: URL {
        switch self {
            case .getRequestToken:  return URL(string: "https://api.twitter.com")!
            case .getUserApproval:  return URL(string: "https://api.twitter.com")!
            case .getAccessToken:   return URL(string: "https://api.twitter.com")!
            case .getTimeline:      return URL(string: "https://api.twitter.com/1.1")!
        }
    }

    var path: String {
        switch self {
            case .getRequestToken:      return "/oauth/request_token"
            case .getUserApproval:      return "/oauth/authorize"
            case .getAccessToken:       return "/oauth/access_token"
            case .getTimeline:          return "/statuses/home_timeline.json"
        }
    }

    var method: HTTPMethod {
        switch self {
            case .getRequestToken:      return .post
            case .getUserApproval:      return .post
            case .getAccessToken:       return .post
            case .getTimeline:          return .get
        }
    }

    var fullUrl: URL {
        self.baseUrl.appendingPathComponent(self.path)
    }

    var fullUrlString: String {
        let completeUrl = self.baseUrl.appendingPathComponent(self.path)
        return completeUrl.absoluteString
    }
}
