//
//  SettingsViewController.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-05-29.
//

import UIKit

class SettingsViewController: UIViewController {
    var userSessionManager = UserSessionManager.shared

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setGradientBackground()
    }
    
    @IBAction func doLogout(_ sender: Any) {
        userSessionManager.doLogout()
    }

    func setGradientBackground() {
        let colorTop =  UIColor(red: 193.0/255.0, green: 101.0/255.0, blue: 221.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 92.0/255.0, green: 39.0/255.0, blue: 254.0/255.0, alpha: 1.0).cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds

        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
}
