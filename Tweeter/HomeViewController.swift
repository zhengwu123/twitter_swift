//
//  HomeViewController.swift
//  Tweeter
//
//  Created by zheng wu on 2/11/16.
//  Copyright © 2016 zheng wu. All rights reserved.
//

import UIKit


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    var tweets: [Tweet]?
    var isMoreDataLoading = false
    @IBOutlet weak var tableView: UITableView!
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        // Network request to get initial data.
        Tweet.homeTimelineWithParams(nil) {
            (tweets: [Tweet]?, error: NSError?) in
            self.tweets = tweets
            self.tableView.reloadData()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(tweetCreatedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) -> Void in
            let createdTweet = notification.userInfo?[tweetCreatedKey] as? Tweet
            if createdTweet != nil {
                self.tweets?.insert(createdTweet!, atIndex: 0)
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destViewController = segue.destinationViewController

        if segue.identifier == "replySegue" {
            
            let button = sender as? UIButton
            let cell = button?.superview?.superview as? HomeTweetCell
            
            let navigationController = destViewController as? UINavigationController
            let composerViewController = navigationController?.topViewController as? ComposeViewController
            composerViewController?.inReplyToTweet = cell?.tweet

        } else if segue.identifier == "detailsSegue" {
            let cell = sender as? HomeTweetCell
            let detailsViewController = destViewController as? TweetViewController
            detailsViewController?.tweet = cell?.tweet
            
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        Tweet.homeTimelineWithParams(nil) {
            (refreshed_tweets: [Tweet]?, error: NSError?) in
            if refreshed_tweets != nil {
                self.tweets = refreshed_tweets
                self.tableView.reloadData()
            } else {
                print(error)
            }
            refreshControl.endRefreshing()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeTweetCell", forIndexPath: indexPath) as! HomeTweetCell
        cell.tweet = self.tweets![indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets?.count ?? 0
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true

                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                Tweet.loadMoreHomeTimelineWithLastTweet((self.tweets?.last)!) {
                    (tweets: [Tweet]?, error: NSError?) in
                    if tweets != nil {
                        self.tweets?.appendContentsOf(tweets!)
                        self.loadingMoreView!.stopAnimating()
                        self.tableView.reloadData()
                        self.isMoreDataLoading = false
                    } else {
                        print("\(error)")
                    }
                }
            }
        }
    }
}