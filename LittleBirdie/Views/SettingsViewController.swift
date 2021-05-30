//
//  SettingsViewController.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-05-29.
//

import UIKit

class SettingsViewController: UIViewController {
    var userSessionManager = UserSessionManager.shared

    @IBAction func doLogout(_ sender: Any) {
        userSessionManager.doLogout()
    }
}
