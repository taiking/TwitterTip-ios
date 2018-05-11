//
//  TabViewController.swift
//  TwitterTip
//
//  Created by 辻林 大揮 on 2018/05/10.
//  Copyright © 2018年 chocovayashi. All rights reserved.
//

import UIKit
import web3swift

class TabViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 秘密鍵とかのセット
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        var bip32keystoreManager = KeystoreManager.managerForPath(userDir + "/bip32_keystore", scanForHDwallets: true)
        var bip32ks: BIP32Keystore
        if bip32keystoreManager?.addresses?.count == 0 {
            guard let password = Config.password else {
                fatalError("環境変数をセットしてください")
            }
            bip32ks = try! BIP32Keystore(mnemonics: "bamboo smart forest finish virtual cannon carry subway swim drink shove heart spike away swarm", password: password, mnemonicsPassword: "", language: .english)!
            let keydata = try! JSONEncoder().encode(bip32ks.keystoreParams)
            FileManager.default.createFile(atPath: userDir + "/bip32_keystore"+"/key.json", contents: keydata, attributes: nil)
            bip32keystoreManager = KeystoreManager.managerForPath(userDir + "/bip32_keystore", scanForHDwallets: true)
        } else {
            bip32ks = bip32keystoreManager?.walletForAddress((bip32keystoreManager?.addresses![0])!) as! BIP32Keystore
        }
        guard let bip32sender = bip32ks.addresses?.first else { return }
        Config.myAddress = bip32sender
        Config.keystoreManager = bip32keystoreManager
        Config.network.addKeystoreManager(Config.keystoreManager)
        
        /// コントラクトへアドレスのセット
        let contract = Config.network.contract(Config.contractAbi, at: Config.contractAddress, abiVersion: 2)!
        var options = Web3Options.defaultOptions()
        options.from = Config.myAddress
        let userName = UserDefaults.standard.string(forKey: "userName")!
        Config.network.addKeystoreManager(Config.keystoreManager)
        guard let result = contract.method("addressOf", parameters: [userName] as [AnyObject], options: options)?.call(options: nil) else { return }
        guard case .success(let address) = result, let addr = address["0"] as? EthereumAddress else { return }
        if addr.address == Config.noAddress {
            let parameters: [AnyObject] = [userName as AnyObject]
            let intermediate = contract.method("setAddress", parameters: parameters, options: options)
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
}
