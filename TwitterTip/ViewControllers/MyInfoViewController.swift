//
//  MyInfoViewController.swift
//  TwitterTip
//
//  Created by 辻林 大揮 on 2018/05/10.
//  Copyright © 2018年 chocovayashi. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class MyInfoViewController: UIViewController {
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var balanceEther: UILabel!
    
    @IBOutlet weak var balanceToken: UILabel!
    
    @IBOutlet weak var loginName: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loginName.text = UserDefaults.standard.string(forKey: "userName")
        
        addressLabel.text = Config.myAddress.address
        
        // Ethの残高取得
        guard case .success(var balance) = Config.network.eth.getBalance(address: Config.myAddress) else { return }
        balance = balance / BigUInt(pow(10, Config.decimal).description)!
        balanceEther.text = "\(balance)"
        
        // トークンの残高取得
        let contract = Config.network.contract(Config.contractAbi, at: Config.contractAddress, abiVersion: 2)!
        var options = Web3Options.defaultOptions()
        options.from = Config.myAddress
        guard let bkxBalanceResult = contract.method("balanceOf", parameters: [Config.myAddress] as [AnyObject], options: options)?.call(options: nil) else { return }
        guard case .success(let bkxBalance) = bkxBalanceResult, var bal = bkxBalance["0"] as? BigUInt else { return }
        bal = bal / BigUInt(pow(10, Config.decimal).description)!
        balanceToken.text = "\(bal) CCVX"
    }
}

