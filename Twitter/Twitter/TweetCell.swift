//
//  TweetCell.swift
//  Twitter
//
//  Created by Abhinav Mathur on 8/1/16.
//  Copyright © 2016 Abhinav Mathur. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    
    
    @IBOutlet weak var tweetLabel: UILabel!
    
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var usrImageView: UIImageView!
    
    var tweet : Tweet!{
        didSet{
           // reTweetLabel.text = String(tweet.retweetCount) as? String
            tweetLabel.text = tweet.text as? String
            userName.text = tweet.user?.screenname as? String
            
            var profileUrl = tweet.user!.profileUrl
            if let profileUrl = profileUrl{
                print("#"+profileUrl.absoluteString)
                usrImageView.setImageWithURL(profileUrl)
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
