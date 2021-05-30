//
//  MainViewModel.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-04-08.
//

import Foundation
import AuthenticationServices

class MainViewModel {
    var apiRequestFactory = APIRequestFactory()
    var userSessionManager = UserSessionManager.shared

    var requestTokenReceived = BindableVar<Bool>(false)
    var tweets = BindableVar<[Tweet]>([])
    var profileImages = BindableVar<[Int: UIImage]>([:])
    var errorText = BindableVar<String>("")
    
    func createApiClient() -> APIRequestToResponseConverting {
        let apiClient: APIRequestToResponseConverting = APIClient(adapters: [SanitizeJSON(),
                                                                             AddDefaultHeaders()])
        return apiClient
    }

    func getRequestToken() {
        let apiRequest = apiRequestFactory.createGetRequestTokenRequest()
        let apiClient = createApiClient()

        apiClient.execute(apiRequest: apiRequest, dataModel: PlainString.self) { (result) in
            switch result {
                case .success(let response):
                    let requestTokenDict = response.decodedDataModel.responseString.urlQueryStringParameters
                    print(response.decodedDataModel.responseString)
                    print(requestTokenDict)
                    UserDefaults.standard.setValue(requestTokenDict["oauth_token"], forKey: "requestToken")
                    UserDefaults.standard.setValue(requestTokenDict["oauth_token_secret"], forKey: "requestTokenSecret")
                    self.requestTokenReceived.value = true
                case .failure(let apiError):
                    print(apiError.localizedDescription)
                    print(apiError.originalError.debugDescription)
                    self.errorText.value = apiError.localizedDescription
            }
        }
    }

    func createWebAuthSessionForUserAuthorization() -> ASWebAuthenticationSession {
        let apiRequest = apiRequestFactory.createUserAuthorizationRequest()
        let url = apiRequest.targetUrlComponents.url!

        let webAuthSession = ASWebAuthenticationSession.init(url: url, callbackURLScheme: TWITTER_URL_SCHEME, completionHandler: { (callbackUrl: URL?, error: Error?) in
            guard error == nil, let successUrl = callbackUrl else {
                self.errorText.value = "User authorization failed"
                return
            }

            let queryParameters = successUrl.query!.urlQueryStringParameters
            print(queryParameters)
            if queryParameters.keys.contains("denied") {
                print("User did not authorize request to access their account")
                self.errorText.value = "User did not authorize request to access their account"
                return
            }

            UserDefaults.standard.setValue(queryParameters["oauth_verifier"], forKey: "oauthVerifier")
            self.getAccessToken()
        })

        return webAuthSession
    }

    func getAccessToken() {
        let apiRequest = apiRequestFactory.createGetAccessTokenRequest()
        let apiClient = createApiClient()

        apiClient.execute(apiRequest: apiRequest, dataModel: PlainString.self) { (result) in
            switch result {
                case .success(let response):
                    let requestTokenDict = response.decodedDataModel.responseString.urlQueryStringParameters
                    print(response.decodedDataModel.responseString)
                    print(requestTokenDict)
                    UserDefaults.standard.setValue(requestTokenDict["oauth_token"], forKey: "accessToken")
                    UserDefaults.standard.setValue(requestTokenDict["oauth_token_secret"], forKey: "accessTokenSecret")
                    UserDefaults.standard.setValue(requestTokenDict["screen_name"], forKey: "screenName")
                    UserDefaults.standard.setValue(requestTokenDict["user_id"], forKey: "userId")
                    self.userSessionManager.didLogin.value = true
                case .failure(let apiError):
                    print(apiError.localizedDescription)
                    print(apiError.originalError.debugDescription)
                    self.errorText.value = apiError.localizedDescription
            }
        }
    }

    func getTimeline() {
        let apiRequest = apiRequestFactory.createGetTimelineRequest()
        let apiClient = createApiClient()

        apiClient.execute(apiRequest: apiRequest, dataModel: [Tweet].self) { (result) in
            switch result {
                case .success(let response):
                    self.tweets.value = response.decodedDataModel
                    self.fetchProfileImages()
                case .failure(let apiError):
                    if let originalError = apiError.originalError {
                        self.errorText.value = originalError.localizedDescription
                    }
            }
        }
    }

    func fetchProfileImages() {
        let dispatchGroup = DispatchGroup()
        var tempProfileImages: [Int: UIImage] = [:]

        for (i, tweet) in self.tweets.value.enumerated() {
            dispatchGroup.enter()

            if let profileImageUrlHttps = URL(string: tweet.user.profileImageUrlHttps) {
                let imageTask = URLSession.shared.dataTask(with: profileImageUrlHttps) { data, response, error in
                    if let data = data {
                        tempProfileImages[i] = UIImage(data: data)!
                    } else {
                        tempProfileImages[i] = UIImage(systemName: "cloud")
                    }

                    dispatchGroup.leave()
                }

                imageTask.resume()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.profileImages.value = tempProfileImages
        }
    }
}
