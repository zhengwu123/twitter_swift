//
//  TweetViewController.swift
//  Tweeter
//
//  Created by zheng wu on 2/11/16.
//  Copyright © 2016 zheng wu. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController {
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    var retweetCount: Int! {
        didSet {
            retweetCountLabel.text = "\(retweetCount!)"
        }
    }
    var favoriteCount: Int! {
        didSet {
            favoriteCountLabel.text = "\(favoriteCount!)"
        }
    }
    
    var favorited: Bool! {
        didSet {
            var imageName = "novel-1"
            if favorited == true {
                imageName = "novel_filled"
                favoriteCount = favoriteCount + 1
            } else {
                favoriteCount = favoriteCount - 1
            }
            self.favoriteButton.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        }
    }
    var retweeted: Bool! {
        didSet {
            var imageName = "recurring_appointment"
            if retweeted == true {
                imageName = "recurring_appointment_filled"
                retweetCount = retweetCount + 1
            } else {
                retweetCount = retweetCount - 1
            }
            self.retweetButton.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        }
    }
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    var tweet: Tweet!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        nameLabel.text = tweet.user?.name
        if tweet.user?.screenname != nil {
            usernameLabel.text = "@" + (tweet.user?.screenname)!
        }

        
        retweetCount = tweet.retweet_count
        favoriteCount = tweet.favorite_count
        timestampLabel.text = tweet.sinceCreatedString
        tweetTextLabel.text = tweet.text
        profileImageView.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
//
        if tweet.retweetedBy != nil {
            retweetLabel.text = "@" + tweet.retweetedBy!.screenname! + " retweeted"
            retweetLabel.hidden = false
        } else if tweet.in_reply_to_screen_name != nil {
            print(tweet.in_reply_to_screen_name)
            retweetLabel.text = "In reply to @" + (tweet.in_reply_to_screen_name)!
            retweetLabel.hidden = false
        } else {
            retweetLabel.hidden = true
            retweetLabel.text = ""
        }

        // Set state variables.
        favorited = tweet.favorited
        retweeted = tweet.retweeted
        
        // Set up "hover" images for buttons.
        favoriteButton.setImage(UIImage(named: "novel_filled"), forState: UIControlState.Highlighted)
        retweetButton.setImage(UIImage(named: "recurring_appointment_filled"), forState: UIControlState.Highlighted)
    
    }

    @IBAction func onRetweet(sender: AnyObject) {
        if self.retweeted == false {
            tweet.retweet() {
                (tweet:Tweet?, error:NSError?) in
                if error == nil {
                    self.retweeted = true
                } else {
                    print(error)
                }
                
            }
        } else {
            tweet.unretweet() {
                (tweet:Tweet?, error:NSError?) in
                if error == nil {
                    self.retweeted = false
                } else {
                    print(error)
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
                } else {
                    print(error)
                }
            }
        } else {
            tweet.unfavorite() {
                (tweet:Tweet?, error:NSError?) in
                if error == nil {
                    self.favorited = false
                } else {
                    print(error)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destViewController = segue.destinationViewController
        
        if segue.identifier == "replyDetailTweetSegue" || segue.identifier == "replyDetailBarTweetSegue" {
            let navigationController = destViewController as? UINavigationController
            let composerViewController = navigationController?.topViewController as? ComposeViewController
            composerViewController?.inReplyToTweet = self.tweet
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
