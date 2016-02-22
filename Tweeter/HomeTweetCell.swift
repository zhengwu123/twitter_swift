//
//  HomeTweetCell.swift
//  Tweeter
//
//  Created by zheng wu on 2/11/16.
//  Copyright © 2016 zheng wu. All rights reserved.
//

import UIKit
import AFNetworking


class HomeTweetCell: UITableViewCell {
    
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!

    @IBOutlet weak var tweetTextLabel: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var tweetMediaImageView: UIImageView!
    
    @IBOutlet weak var tweetMediaImageViewConstraint: NSLayoutConstraint!
    var favorited: Bool! {
        didSet {
            var imageName = "novel-1"
            if favorited == true {
                imageName = "novel_filled"
            }
            self.favoriteButton.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        }
    }
    var retweeted: Bool! {
        didSet {
            var imageName = "recurring_appointment"
            if retweeted == true {
                imageName = "recurring_appointment_filled"
            }
            self.retweetButton.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        }
    }
    
    var tweet: Tweet! {
        didSet {
            nameLabel.text = tweet.user?.name
            if tweet.user?.screenname != nil {
                usernameLabel.text = "@" + (tweet.user?.screenname)!
            }
            timestampLabel.text = tweet.sinceCreatedString
            tweetTextLabel.text = tweet.text
            
            // Set profile image thumbnail
            profileImageView.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
            profileImageView.layer.cornerRadius = 5
            profileImageView.clipsToBounds = true
            
            // Set media image
            if tweet.media_url != nil {
                tweetMediaImageView.setImageWithURL(NSURL(string: tweet.media_url!)!)
                tweetMediaImageView.layer.cornerRadius = 5
                tweetMediaImageView.clipsToBounds = true
                tweetMediaImageView.hidden = false
                //tweetMediaImageViewConstraint.constant = 231.0
                
            } else {
                tweetMediaImageView.hidden = true
                //tweetMediaImageViewConstraint.constant = 0.0
            }
            
            if tweet.retweetedBy != nil {
                retweetLabel.text = "@" + (tweet.retweetedBy?.screenname)! + " retweeted"
                retweetLabel.hidden = false
            } else if tweet.in_reply_to_screen_name != nil {
                retweetLabel.text = "In reply to @" + (tweet.in_reply_to_screen_name)!
                retweetLabel.hidden = false
            } else {
                retweetLabel.hidden = true
            }

            // Set state variables.
            favorited = tweet.favorited
            retweeted = tweet.retweeted
            
            // Set up "hover" images for buttons.
            favoriteButton.setImage(UIImage(named: "novel-1"), forState: UIControlState.Highlighted)
            retweetButton.setImage(UIImage(named: "novel_filled"), forState: UIControlState.Highlighted)
            
        }
    }

    @IBAction func onReply(sender: AnyObject) {
        
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        if self.retweeted == false {
            tweet.retweet() {
                (tweet:Tweet?, error:NSError?) in
                if error == nil {
                    self.retweeted = true
                }

            }
        } else {
            tweet.unretweet() {
                (tweet:Tweet?, error:NSError?) in
                if error == nil {
                    self.retweeted = false
                }
            }
        }
    }
    
    
    @IBAction func onFavorite(sender: AnyObject) {
        if self.favorited == false {
            tweet.favorite() {
                (tweet:Tweet?, error:NSError?) in
                if error == nil {
                    self.favorited = true
                }
            }
        } else {
            tweet.unfavorite() {
                (tweet:Tweet?, error:NSError?) in
                if error == nil {
                    self.favorited = false
                }
            }
        }
    }
    
}
