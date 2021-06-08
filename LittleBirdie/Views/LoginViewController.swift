//
//  LoginViewController.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-03-24.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    var viewModel = MainViewModel()
    var webAuthSession: ASWebAuthenticationSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setGradientBackground()
    }

    func setupBindings() {
        viewModel.requestTokenReceived.bind { tokenReceived in
            if tokenReceived {
                self.obtainUserConsent()
            }
        }

        viewModel.errorText.bind { errorText in
            if !errorText.isEmpty {
                self.displayAlert(errorText)
            }
        }
    }

    @IBAction func doLogin(_ sender: Any) {
        viewModel.getRequestToken()
    }

    func obtainUserConsent() {
        DispatchQueue.main.async {
            self.webAuthSession = self.viewModel.createWebAuthSessionForUserAuthorization()
            self.webAuthSession?.presentationContextProvider = self
            self.webAuthSession?.start()
        }
    }

    func displayAlert(_ errorText: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: errorText, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
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

