//
//  TweetsViewController.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-05-24.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var viewModel = MainViewModel()
    var userSessionManager = UserSessionManager.shared

    var tweets: [Tweet] = []
    var profileImages: [Int: UIImage] = [:]
    let dispatchGroup = DispatchGroup()
    @IBOutlet weak var tweetsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tweetsTableView.delegate = self
        self.tweetsTableView.dataSource = self
        setupBindings()
        viewModel.getTimeline()
    }

    func setupBindings() {
        viewModel.errorText.bind { errorText in
            if !errorText.isEmpty {
                self.displayAlert(errorText)
            }
        }
        
        viewModel.tweets.bind { tweets in
            print("TWEETS TWEETS TWEETS")
            if !tweets.isEmpty {
                self.tweets = tweets
            }
        }

        viewModel.profileImages.bind { profileImages in
            if !profileImages.isEmpty {
                DispatchQueue.main.async {
                    self.profileImages = profileImages
                    print("Profile images downloaded")
                    self.tweetsTableView.reloadData()
                }
            }
        }
    }

    @IBAction func doRefreshTweets(_ sender: Any) {
        viewModel.getTimeline()
    }
    
    @IBAction func doLogout(_ sender: UIBarButtonItem) {
        userSessionManager.doLogout()
    }


    func displayAlert(_ errorText: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: errorText, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200
//    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCell

        let tweet = tweets[indexPath.row]
        cell.userNameLabel.text = tweet.user.name

        if let retweetedStatus = tweet.retweetedStatus {
            let attributionString = "Retweeted from \(retweetedStatus.user.name) \n"
            cell.tweetTextView.text = attributionString + retweetedStatus.fullText
        } else {
            cell.tweetTextView.text = tweet.fullText
        }

        if let profileImage = self.profileImages[indexPath.row] {
            cell.profileImageView.image = profileImage
        }

        return cell
    }
}
