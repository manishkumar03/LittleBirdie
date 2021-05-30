//
//  UserSessionManager.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-05-25.
//

import Foundation

class UserSessionManager {
    static let shared = UserSessionManager()

    var didLogin = BindableVar<Bool>(false)

    func doLogout() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "accessTokenSecret")
        self.didLogin.value = false
    }

    func isUserLoggedIn() -> Bool {
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            return accessToken.count > 0
        }

        return false
    }
}
