//
//  TweetsViewController.swift
//  TwitterTip
//
//  Created by 辻林 大揮 on 2018/05/10.
//  Copyright © 2018年 chocovayashi. All rights reserved.
//

import UIKit
import web3swift

class TweetsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tweets: [TWTRTweet] = [] {
        didSet {
            if tweets.count != 0 { tableView.reloadData() }
        }
    }
    
    var cellHeight: [String: CGFloat] = [:]
    
    var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTweets()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSendTip" {
            guard let vc = segue.destination as? SendTipViewController,
                let address = sender as? EthereumAddress else { return }
            vc.toAddress = address
        }
    }
    
    private func getTweets(maxId: String? = nil) {
        let session = TWTRTwitter.sharedInstance().sessionStore.session()!
        let client = TWTRAPIClient(userID: session.userID)
        let userName = UserDefaults.standard.string(forKey: "userName")!
        let endpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        var params = ["name": userName]
        if let maxId = maxId, let maxIdInt = Int(maxId) {
            params["max_id"] =  "\(maxIdInt - 1)"
        }
        var clientError : NSError?

        let request = client.urlRequest(withMethod: "GET", urlString: endpoint, parameters: params, error: &clientError)

        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("Error: \(connectionError!)")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                let jsonDic = json as! [[AnyHashable: Any]]
                if maxId == nil {
                    self.tweets = TWTRTweet.tweets(withJSONArray: jsonDic) as! [TWTRTweet]
                } else {
                    self.tweets += TWTRTweet.tweets(withJSONArray: jsonDic) as! [TWTRTweet]
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.isLoading = false
                })
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
        }
    }
}

extension TweetsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as? TweetCell,
            let tweetView = cell.contentView.subviews.first as? TWTRTweetView else {
                return UITableViewCell()
        }
        tweetView.delegate = self
        tweetView.configure(with: tweets[indexPath.row])
        tweetView.sizeToFit()
        cellHeight["\(indexPath.row)"] = tweetView.frame.height
        return cell
    }
}

extension TweetsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight["\(indexPath.row)"] ?? 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.height >= scrollView.contentSize.height &&
            scrollView.contentOffset.y > 0 && !isLoading {
            isLoading = true
            let lastId = Int(tweets.last!.tweetID)!
            getTweets(maxId: "\(lastId - 1)")
        }
    }
}

extension TweetsViewController: TWTRTweetViewDelegate {
    func tweetView(_ tweetView: TWTRTweetView, didTap tweet: TWTRTweet) {
        let contract = Config.network.contract(Config.contractAbi, at: Config.contractAddress, abiVersion: 2)!
        var options = Web3Options.defaultOptions()
        options.from = Config.myAddress
        guard let result = contract.method("addressOf", parameters: [tweet.author.screenName] as [AnyObject], options: options)?.call(options: nil) else { return }
        guard case .success(let address) = result, let addr = address["0"] as? EthereumAddress else { return }
        if addr.address == Config.noAddress {
            performSegue(withIdentifier: "toNoAddress", sender: nil)
        } else {
            performSegue(withIdentifier: "toSendTip", sender: addr)
        }
    }
}

class TweetCell: UITableViewCell {
    
}
