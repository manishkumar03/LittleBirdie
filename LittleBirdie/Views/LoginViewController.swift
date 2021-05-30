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
}

