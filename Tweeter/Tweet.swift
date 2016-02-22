//
//  Tweet.swift
//  Tweeter
//
//  Created by zheng wu on 2/11/16.
//  Copyright © 2016 zheng wu. All rights reserved.
//

//import Cocoa
import UIKit


class Tweet: NSObject {
    var user: User?
    var text: String?
    var createdAtString: String?
    var sinceCreatedString: String?
    var createAt: NSDate?
    var retweetedBy: User?
    var tweetID: Int?
    var retweeted: Bool?
    var favorited: Bool?
    var in_reply_to_screen_name: String?
    var dictionary: NSDictionary?
    var retweet_count: Int?
    var favorite_count: Int?
    
    var media_url: String?
    var media_height: Int?
    
    init(dictionary: NSDictionary) {
        var tweet_dictionary: NSDictionary = dictionary
        
        if tweet_dictionary["retweeted_status"] != nil {
            retweetedBy = User(dictionary: tweet_dictionary["user"] as! NSDictionary)
            tweet_dictionary = tweet_dictionary["retweeted_status"] as! NSDictionary
            
        }
        self.dictionary = tweet_dictionary
        if tweet_dictionary["entities"] != nil {
            
            let entities_dict = tweet_dictionary["entities"] as! NSDictionary
            if entities_dict["media"] != nil {
                let medias = entities_dict["media"] as! NSArray
                let media = medias[0] as! NSDictionary
                let media_url = media["media_url"] as! String
                self.media_url = media_url

//                let sizes_dict = media["sizes"] as! NSDictionary
//                let small_dict = sizes_dict["small"] as! NSDictionary
//                let height = small_dict["h"]
//                let width = small_dict["w"]
//                print("h:\(height)w:\(width)")
//                self.media_height = height as? Int
            }
            
        }
        user = User(dictionary: tweet_dictionary["user"] as! NSDictionary)
        text = tweet_dictionary["text"] as? String
        createdAtString = tweet_dictionary["created_at"] as? String
        createAt = DateFormatter.dateFromString(createdAtString)
        sinceCreatedString = DateFormatter.sinceNowFormat(createAt)
        retweeted = tweet_dictionary["retweeted"] as? Bool
        favorited = tweet_dictionary["favorited"] as? Bool
        let id_str = tweet_dictionary["id_str"] as? String
        if id_str != nil {
            tweetID = Int(id_str!)
        }
        
        self.in_reply_to_screen_name = tweet_dictionary["in_reply_to_screen_name"] as? String
        self.retweet_count = tweet_dictionary["retweet_count"] as? Int
        self.favorite_count = tweet_dictionary["favorite_count"] as? Int

    }
    
    func favorite(completion: (tweet: Tweet?, error:NSError?) -> ()) {
        TwitterClient.sharedInstance.favorite("\(tweetID!)", completion: completion)
    }
    
    func unfavorite(completion: (tweet: Tweet?, error:NSError?) -> ()) {
        TwitterClient.sharedInstance.unfavorite("\(tweetID!)", completion: completion)
    }
    
    func unretweet(completion: (tweet: Tweet?, error:NSError?) -> ()) {
        TwitterClient.sharedInstance.unretweet("\(tweetID!)", completion: completion)
    }
    
    func retweet(completion: (tweet: Tweet?, error:NSError?) -> ()) {
        TwitterClient.sharedInstance.retweet("\(tweetID!)", completion: completion)
    }
    
    class func homeTimelineWithParams(parameters: NSDictionary?, completion: (tweets: [Tweet]?, error:NSError?) -> ()) {
        TwitterClient.sharedInstance.homeTimelineWithParams(nil , completion:  completion)
    }
    
    class func loadMoreHomeTimelineWithLastTweet(lastTweet: Tweet, completion: (tweets: [Tweet]?, error:NSError?) -> ()) {

        let params: NSDictionary = ["since_id": (lastTweet.tweetID)!]
        TwitterClient.sharedInstance.homeTimelineWithParams(params , completion:  completion)
    }
    
    class func publishTweet(text: String, in_reply_tweet_id: Int?, completion: (tweets: Tweet?, error:NSError?) -> ()) {
        if text.characters.count > 0 {
            TwitterClient.sharedInstance.publishTweet(text,in_reply_tweet_id:in_reply_tweet_id, completion: completion)
        }
    }
    
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}
