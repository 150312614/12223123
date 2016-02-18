//
//  UserAccountViewModel.swift
//  微博009
//
//  Created by Romeo on 15/9/4.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import ReactiveCocoa

/// 用户账户视图模型
class UserAccountViewModel: NSObject {

    /// 单例
    static let sharedUserAccount = UserAccountViewModel()
    
    override init() {
        userAccount = UserAccount.loadUserAccount()
    }
    
    /// 用户账户
    var userAccount: UserAccount?
    
    /// accessToken
    var accessToken: String? {
        return userAccount?.access_token
    }
    /// 用户登录标记
    var userLogon: Bool {
        return accessToken != nil
    }
    var avatarUrl: NSURL? {
        return NSURL(string: userAccount?.avatar_large ?? "")
    }
    
    // MARK: - 加载网络数据
    /// 加载用户 accessToken & 用户信息
    func loadUserAccount(code: String) -> RACSignal  {
        
        return RACSignal.createSignal({ (subscriber) -> RACDisposable! in
            
            // doNext 是可以给信号增加附加操作，第一个信号完成之后，将第一个信号的 result 直接传递给第二个信号
            // doNext 后面一定要加一个 subscriberXXX，否则 doNext 不会被执行到
            NetworkTools.sharedTools.loadAccessToken(code).doNext({ (result) -> Void in
                
                // 创建用户账户模型，as! 将一个对象视为什么类型， !/? 取决于参数的需求
                let account = UserAccount(dict: result as! [String: AnyObject])
                // 设置当前的账户属性
                self.userAccount = account
                printLog(account)
                
                NetworkTools.sharedTools.loadUserInfo(account.uid!).subscribeNext({ (result) -> Void in
                    
                    let dict = result as! [String: AnyObject]
                    // 设置帐号的属性
                    account.name = dict["name"] as? String
                    account.avatar_large = dict["avatar_large"] as? String
                    
                    printLog(account)
                    
                    // 保存账号
                    account.saveUserAccount()
                    
                    // 通知订阅者网络数据加载完成
                    subscriber.sendCompleted()
                    
                    }, error: { (error) -> Void in
                        subscriber.sendError(error)
                    })
            }).subscribeError({ (error) -> Void in
                subscriber.sendError(error)
            })
            
            return nil
        })
    }
}
