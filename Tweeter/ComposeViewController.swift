//
//  ComposeViewController.swift
//  Tweeter
//
//  Created by zheng wu on 2/11/16.
//  Copyright © 2016 zheng wu. All rights reserved.
//

import UIKit
let tweetCreatedNotification = "ntweetCreated"
let tweetCreatedKey = "ktweetCreated"

class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var composerTextView: UITextView!
    @IBOutlet weak var composerPlaceholderLabel: UILabel!
    var inReplyToTweet: Tweet?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameLabel.text = User.currentUser?.name
        self.usernameLabel.text = "@\((User.currentUser?.screenname)!)"
        self.composerTextView.delegate = self
        updateNumChars()
        self.profileImageView.setImageWithURL(NSURL(string: (User.currentUser?.profileImageUrl)!)!)
        if inReplyToTweet != nil {
            self.composerTextView.text = "@\((inReplyToTweet?.user!.screenname)!) "
            self.composerPlaceholderLabel.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTweet(sender: AnyObject) {
        var userInfo: [NSObject : AnyObject] = [:]
        Tweet.publishTweet(self.composerTextView.text!, in_reply_tweet_id: inReplyToTweet?.tweetID)  {
            (tweet: Tweet?, error:NSError?) in
            if error != nil {
                print("Failed to post tweet")
                print(error)

            } else {
                print("Posted post \(tweet)")
                userInfo[tweetCreatedKey] = tweet
                NSNotificationCenter.defaultCenter().postNotificationName(tweetCreatedNotification, object: self, userInfo: userInfo)
                
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.composerPlaceholderLabel.hidden = true
        if self.composerTextView.text!.characters.count > 139 {
            self.composerTextView.editable = false
        }
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if self.composerTextView.text!.characters.count > 0 {
            self.composerPlaceholderLabel.hidden = true
        }
        if self.composerTextView.text!.characters.count > 139 {
        self.composerTextView.editable = false
        }
        return true
    }
    
    
    func textViewDidChange(textView: UITextView) {
        updateNumChars()
    }
    
    func updateNumChars() {
        let numChars = 140 - self.composerTextView.text!.characters.count
        self.characterCountLabel.text = "\(numChars)"
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
