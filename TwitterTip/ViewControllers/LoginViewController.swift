//
//  LoginViewController.swift
//  TwitterTip
//
//  Created by 辻林 大揮 on 2018/05/10.
//  Copyright © 2018年 chocovayashi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.string(forKey: "userName") == nil {
            TWTRTwitter.sharedInstance().logIn(completion: { session, error in
                if let session = session {
                    self.save(name: session.userName)
                    self.toNext()
                } else {
                    print("error: \(error!.localizedDescription)")
                }
            })
        }
    }
    
    private func save(name: String) {
        UserDefaults.standard.set(name, forKey: "userName")
    }
    
    private func toNext() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateInitialViewController()!
        present(vc, animated: true, completion: nil)
    }
}
