//
//  TweetCell.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-05-29.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Remove all default padding from the textview so that its contents
        // can line up with the name label.
        let padding = tweetTextView.textContainer.lineFragmentPadding
        tweetTextView.textContainerInset =  UIEdgeInsets(top: 0,
                                                         left: -padding,
                                                         bottom: 0,
                                                         right: -padding)
    }
}
