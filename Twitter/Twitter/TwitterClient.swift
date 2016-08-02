//
//  TwitterClient.swift
//  Twitter
//
//  Created by Abhinav Mathur on 8/1/16.
//  Copyright © 2016 Abhinav Mathur. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com")!, consumerKey: "6E1pF2Seg8gzbQSpldqJqTxnz", consumerSecret: "IOVz3GjV6mdYT2PJgaqHIVEDwvPYFCwmIqAQQaXs0lfOYeAi9e")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((NSError) -> ())?
    
    func homeTimeline(success: ([Tweet] -> ()), failure: (NSError) -> ()){
        
        GET("1.1/statuses/home_timeline.json", parameters: nil, success: { (task : NSURLSessionDataTask, response : AnyObject?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let tweets       = Tweet.tweetsWithArray(dictionaries)
            success(tweets)
            
            }, failure: { (task : NSURLSessionDataTask?, error : NSError) -> Void in
                failure(error)
        })
    }
    
    func currentAccount(success: (User) -> (), failure: (NSError) -> () ){
        GET("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task : NSURLSessionDataTask , response : AnyObject?) ->  Void in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            success(user)
            print("User: \(user.name)")
            print("name: \(user.screenname)")
            print("profile url: \(user.profileUrl)")
            print("Description: \(user.tagline)")
            }, failure: { (task : NSURLSessionDataTask?, error : NSError) -> Void in
                failure(error)
                
        })
    }
    
    
    func postTweet(status:String) {
        //https://api.twitter.com/1.1/statuses/update.json
        let obj = ["status":"hello world"]
        
        
      // POST("1.1/statuses/update.json", parameters: obj, success: nil, failure: nil)
        POST("1.1/statuses/update.json", parameters: obj, success: { (task:NSURLSessionTask, response:AnyObject?)-> Void in
            print("success")
            }, failure: nil)

    }
    
    func login(success : () -> (), failure :(NSError) -> ()){
        deauthorize()
        loginSuccess = success
        loginFailure = failure
        fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string:  "twitterdemo://oauth"), scope: nil, success: { (requestToken : BDBOAuth1Credential!) -> Void in
            print("I got token")
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!
            UIApplication.sharedApplication().openURL(url)
            })
        { (error : NSError!) -> Void in
            self.loginFailure?(error)
        }
    }
    
    func handleOpenUrl(url: NSURL){
        
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: requestToken, success:{ (accessToken :BDBOAuth1Credential!) -> Void in
            self.currentAccount({ (user: User) -> () in
                User.currentUser = user
                self.loginSuccess?()
                },
                failure: { (error: NSError) -> () in
                    self.loginFailure!(error)
            })
            
            })
        { (error : NSError!) in
            print("error : \(error.localizedDescription)")
            self.loginFailure!(error)
        }
    }
    
    func logout(){
        User.currentUser = nil
        deauthorize()
        NSNotificationCenter.defaultCenter().postNotificationName(User.userDidLogoutNotification, object: nil)
    }
    
    

}
