//
//  TimelineViewController.swift
//  Twitter-App
//
//  Created by Rachel Thomas on 2/20/15.
//  Copyright (c) 2015 Rachel Thomas. All rights reserved.
//

import UIKit

class TimelineViewController: CenterViewController, UITableViewDataSource, TweetCellReplyDelegate, TweetCellRetweetDelegate, TweetCellFavoriteDelegate, TweetCellProfileDelegate {
    

    @IBOutlet weak var navItem: UINavigationItem!
    
    var tweets: [Tweet]?
    var pullRefreshControl: UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func signOut(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    @IBAction func composeTweet(sender: AnyObject) {
       segueToComposer(nil)
    }
    
    func segueToComposer(replyTo: String!){
        let storyboard = UIStoryboard(name: "Compose", bundle: nil)
        let navController = storyboard.instantiateInitialViewController() as UINavigationController
        let composeController = navController.topViewController as ComposerViewController
        composeController.replyTo = replyTo
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    func goToProfile(tweetCell: TweetCell) {
        println("go to profile called: \(tweetCell.name.text!)")
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let navController = storyboard.instantiateInitialViewController() as UINavigationController
        let profileController = navController.topViewController as ProfileViewController
        profileController.user = tweetCell.tweet.user
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    func favorite(tweetCell: TweetCell) {
        TwitterClient.sharedInstance.favoriteTweet(tweetCell.tweet!.id!, params: nil, completion: {(error) -> () in
            tweetCell.favoriteButton.imageView?.image = UIImage(named: "favorite_on.png")
            let thisTweet = tweetCell.tweet! as Tweet
            if thisTweet.favorite_count! > 0 {
                tweetCell.favoriteCount.text = "\(thisTweet.favorite_count! + 1)"
            } else {
                tweetCell.favoriteCount.text = "1"
            }
        })
    }
    
    func retweet(tweetCell: TweetCell) {
        TwitterClient.sharedInstance.retweetTweet(tweetCell.tweet!.id!, params: nil, completion: {(error) -> () in
            tweetCell.retweetButton.imageView?.image = UIImage(named: "retweet_on.png")
            let thisTweet = tweetCell.tweet! as Tweet
            if thisTweet.retweet_count! > 0 {
                tweetCell.retweetCount.text = "\(thisTweet.retweet_count! + 1)"
            } else {
                tweetCell.retweetCount.text = "1"
            }
        })
    }
    
    func reply(tweetCell: TweetCell) {
        let replyTo = tweetCell.handle!.text as String?
        segueToComposer(replyTo)
    }
    
    func loadTweets(){
        println("\(navItem.title!)")
        if navItem.title == "Mentions" {
            TwitterClient.sharedInstance.mentionsWithCompletion(nil, completion: {(tweets, error) -> () in
                self.tweets = tweets
                self.tableView.reloadData()
            })
        } else {
            navItem.title = "Timeline"
            TwitterClient.sharedInstance.timelineWithCompletion(nil, completion: {(tweets, error) -> () in
                self.tweets = tweets
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        loadTweets()
        pullRefreshControl = UIRefreshControl()
        pullRefreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(pullRefreshControl, atIndex: 0)
    }
    
    
    func onRefresh() {
        loadTweets()
        self.pullRefreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        if let array = tweets {
            return array.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tweetcell") as TweetCell
        cell.replyDelegate = self
        cell.retweetDelegate = self
        cell.favoriteDelegate = self
        cell.profileDelegate = self
        let thisTweet = tweets![indexPath.row] as Tweet
        let thisUser = thisTweet.user! as User
        cell.tweet = thisTweet
        cell.tweetText.text = thisTweet.text! as NSString
        cell.name.text = thisUser.name! as NSString
        cell.handle.text = "@" + thisUser.screenname! as NSString
        cell.imageButton.setImageForState(.Normal, withURL: NSURL(string: thisUser.profileImageURL!))
        cell.imageButton.contentHorizontalAlignment = .Fill
        cell.imageButton.contentVerticalAlignment = .Fill
        if thisTweet.favorited! {
            cell.favoriteButton.imageView?.image = UIImage(named: "favorite_on.png")
        } else {
            cell.favoriteButton.imageView?.image = UIImage(named: "favorite.png")
        }
        if thisTweet.favorite_count! > 0 {
            cell.favoriteCount.text = "\(thisTweet.favorite_count!)"
        } else {
            cell.favoriteCount.text = ""
        }
        if thisTweet.retweeted! {
            cell.retweetButton.imageView?.image = UIImage(named: "retweet_on.png")
        } else {
            cell.retweetButton.imageView?.image = UIImage(named: "retweet.png")
        }
        if thisTweet.retweet_count! > 0 {
            cell.retweetCount.text = "\(thisTweet.retweet_count!)"
        } else {
            cell.retweetCount.text = ""
        }
        return cell
    }

}
