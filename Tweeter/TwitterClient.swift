//
//  TwitterClient.swift
//  Tweeter
//
//  Created by zheng wu on 2/11/16.
//  Copyright © 2016 zheng wu. All rights reserved.
//

//import Cocoa
import BDBOAuth1Manager

let twitterConsumerKey = "dXpqJM7saUm835S4jYMK282b4"
let twitterConsumerSecret = "eArJFNK4VVnVylAT2DS78mETEXU0AcclbAGcZiutly02Jnav6K"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
   
    
    enum NetworkRequest {
        case GET, POST
    }
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(
                baseURL: twitterBaseURL,
                consumerKey: twitterConsumerKey,
                consumerSecret: twitterConsumerSecret)
        }
        return Static.instance
    }
    
    func retweet(id: String, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        let url = "1.1/statuses/retweet/\(id).json"
        requestTwitterWithTweetResponse(NetworkRequest.POST, url: url, queryParams: nil, parameters: nil, completion: completion)
    }
    
    func unretweet(id: String, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        let url = "1.1/statuses/unretweet/\(id).json"
        requestTwitterWithTweetResponse(NetworkRequest.POST, url: url, queryParams: nil, parameters: nil, completion: completion)
    }
    
    func favorite(id_str: String, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        let url = "1.1/favorites/create.json"
        requestTwitterWithTweetResponse(NetworkRequest.POST, url: url, queryParams: ["id" : id_str], parameters: nil, completion: completion)
    }
    
    func unfavorite(id_str: String, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        let url = "1.1/favorites/destroy.json"
        requestTwitterWithTweetResponse(NetworkRequest.POST, url: url, queryParams: ["id" : id_str], parameters: nil, completion: completion)
    }
    
    func buildURLWithQueryParams(url: String, queryParams: [String:String]?) -> String {
        var urlWithQueryParams = url
        if queryParams != nil {
            urlWithQueryParams.appendContentsOf("?")
            for qp in queryParams! {
                let qp1: String = qp.1.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
                urlWithQueryParams.appendContentsOf(qp.0 + "=" + qp1 + "&")
            }
        }
        if urlWithQueryParams[urlWithQueryParams.endIndex.predecessor()] == "&" {
            urlWithQueryParams = String(urlWithQueryParams.characters.dropLast())
        }

        return urlWithQueryParams
    }
    
    func requestTwitter(mode: NetworkRequest, url: String, queryParams: [String:String]?, parameters: NSDictionary?, completion: (response: AnyObject?, error: NSError?) -> ()) {
        
        let urlWithQueryParams = buildURLWithQueryParams(url , queryParams: queryParams)
        if mode == NetworkRequest.GET {
            GET(urlWithQueryParams, parameters: parameters, success:  { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                completion(response: response, error: nil)
                }, failure: { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                    completion(response: nil, error: error)
            })
        } else if mode == NetworkRequest.POST {
            
            POST(urlWithQueryParams, parameters: parameters, success:  { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                    completion(response: response, error: nil)
                }, failure: { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                    completion(response: nil, error: error)
            })
        } else {
            print("requestTwitter with unknown mode: \(mode)")
        }
    }
    
    func requestTwitterWithTweetResponse(mode: NetworkRequest, url: String, queryParams: [String:String]?, parameters: NSDictionary?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        requestTwitter(NetworkRequest.POST, url: url, queryParams: queryParams, parameters: parameters) {
            (response: AnyObject?, error: NSError?) in
            var tweet: Tweet? = nil
            if response != nil {
                tweet = Tweet(dictionary: response as! NSDictionary)
            }
            completion(tweet:tweet, error: error)
        }
    }
    
    func homeTimelineWithParams(parameters: NSDictionary?, completion: (tweets: [Tweet]?, error:NSError?) -> ()) {
        
        GET("1.1/statuses/home_timeline.json", parameters: ["include_entities": true], success:  { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                completion(tweets: tweets, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                completion(tweets: nil, error: error)
        })
    }
    
    func publishTweet(text: String, in_reply_tweet_id: Int?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        let url = "1.1/statuses/update.json"
        var queryParams = ["status": text]
        if in_reply_tweet_id != nil {
            queryParams["in_reply_to_status_id"] =  "\(in_reply_tweet_id!)"
        }
        
        requestTwitterWithTweetResponse(NetworkRequest.POST, url: url, queryParams: queryParams, parameters: nil, completion: completion)
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        self.loginCompletion = completion
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string:"tweetiepy://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
            }, failure: { (error: NSError! ) -> Void in
                print("Failed to get token")
        })
    }
    
    func openURL(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print("Got access token")
            
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success:  { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                    let user = User(dictionary: response as! NSDictionary)
                    User.currentUser = user
                    self.loginCompletion?(user:user, error:nil)
                }, failure: { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                    self.loginCompletion?(user:nil, error:error)
                    
            })

            }, failure: {
                (error: NSError!) -> Void in
                print("Failed to get access token")
                self.loginCompletion?(user:nil, error:error)
        })
    }
}