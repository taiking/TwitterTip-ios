//
//  SendTipViewController.swift
//  TwitterTip
//
//  Created by 辻林 大揮 on 2018/05/10.
//  Copyright © 2018年 chocovayashi. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class SendTipViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    var toAddress: EthereumAddress!
    
    @IBAction func sendBuyEth(_ sender: UIButton) {
        let coldWalletABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
        var options = Web3Options.defaultOptions()
        let value = textField.text!
        Config.network.addKeystoreManager(Config.keystoreManager)
        
        guard let doubleValue = Double(value) else { return }
        options.value = BigUInt(doubleValue * Double(pow(10, Config.decimal).description)!)
        options.from = Config.myAddress
        let intermediate = Config.network.contract(coldWalletABI, at: toAddress, abiVersion: 2)!.method(options: options)!
        guard let password = Config.password else {
            fatalError("環境変数をセットしてください")
        }
        let sendResult = intermediate.send(password: password)
        switch sendResult {
        case .success(let r):
            print(r)
        case .failure(let err):
            print(err)
        }
    }
    
    @IBAction func sendBuyTwtp(_ sender: UIButton) {
        var options = Web3Options.defaultOptions()
        options.from = Config.myAddress
        let value = textField.text!
        guard let doubleValue = Double(value) else { return }
        let bigValue = BigUInt(doubleValue * Double(pow(10, Config.decimal).description)!) as AnyObject
        Config.network.addKeystoreManager(Config.keystoreManager)
        let contract = Config.network.contract(Config.contractAbi, at: Config.contractAddress, abiVersion: 2)!
        let parameters: [AnyObject] = [toAddress.address as AnyObject, bigValue]
        let intermediate = contract.method("transfer", parameters: parameters, options: options)
        guard let password = Config.password else {
            fatalError("環境変数をセットしてください")
        }
        guard let sendTokenResult = intermediate?.send(password: password) else { return }
        switch sendTokenResult {
        case .success(let r):
            print(r)
        case .failure(let err):
            print(err)
        }
    }
}
