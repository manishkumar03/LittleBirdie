//
//  Tweet.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-03-29.
//

import UIKit

struct Tweet: Codable {
    let fullText: String
    let user: User
    let retweetedStatus: RetweetedStatus?
}

struct User: Codable {
    let name: String
    let profileImageUrlHttps: String
}

struct RetweetedStatus: Codable {
    let fullText: String
    let user: User
}

struct TweetExpanded {
    let fullText: String
    let name: String
    let avatar: UIImage
}
