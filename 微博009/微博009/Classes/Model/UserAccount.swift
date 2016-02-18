//
//  UserAccount.swift
//  微博009
//
//  Created by Romeo on 15/9/4.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 用户账户
class UserAccount: NSObject, NSCoding {

    /// 用于调用access_token，接口获取授权后的access token
    var access_token: String?
    /// access_token的生命周期，单位是秒数
    /// token是不安全的，对于第三方的接口，只能访问有限的资源
    /// 开发者的有效期是5年，一般用户是3天，在程序开发中，一定注意判断token是否过期
    /// 如果过期，需要用户重新登录
    var expires_in: NSTimeInterval = 0 {
        didSet {
            // 计算过期日期
            expiresDate = NSDate(timeIntervalSinceNow: expires_in)
        }
    }
    /// 过期日期
    var expiresDate: NSDate?
    /// 当前授权用户的UID
    var uid: String?
    
    /// 友好显示名称
    var name: String?
    /// 用户头像地址（大图），180×180像素
    var avatar_large: String?
    
    init(dict: [String: AnyObject]) {
        super.init()
        
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    // 对象的描述信息，需要生写，关于对象的描述信息，苹果变换了很多版本，目前没有智能提示
    // 在 Swift / OC 中，任何对象都有一个 description 的属性，用处就是用来打印对象信息
    // 默认 字典 / 数组 / 字符串 都有自己的格式，而自定义对象，默认的格式：<类名: 地址>，不利于调试
    // 为了便于调试，自定义对象可以重写 description
    override var description: String {
        let keys = ["access_token", "expires_in", "expiresDate", "uid", "name", "avatar_large"]
        
        // KVC 的模型转字典 "\(变量名)" 调用 description 进行转换
        return "\(dictionaryWithValuesForKeys(keys))"
    }
    
    // Xcode 7.0 beta 5之后，取消了 String 的拼接路径函数，改成 NSString 的函数
    static let accountPath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last! as NSString).stringByAppendingPathComponent("account.plist")
    
    /// 将当前对象归档保存
    func saveUserAccount() {
        // 对象函数中，调用静态属性，使用`类名.属性`
        printLog("保存路径 " + UserAccount.accountPath)
        
        // `键值`归档
        NSKeyedArchiver.archiveRootObject(self, toFile: UserAccount.accountPath)
    }
    
    /// 加载用户账户
    ///
    /// - returns: 账户信息，如果用户还没有登录，返回 nil
    class func loadUserAccount() -> UserAccount? {
        // 解档加载用户账户的时候，需要判断 token 的有效期
        let account = NSKeyedUnarchiver.unarchiveObjectWithFile(accountPath) as? UserAccount

        if let date = account?.expiresDate {
            // 比较日期 date > NSDate() 结果是降序
            if date.compare(NSDate()) == NSComparisonResult.OrderedDescending {
                return account
            }
        }
        
        return nil
    }
    
    // MARK: - NSCoding
    // 归档，将当前对象保存到磁盘之前，转换成二进制数据，跟序列化很像
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(access_token, forKey: "access_token")
        aCoder.encodeObject(expiresDate, forKey: "expiresDate")
        aCoder.encodeObject(uid, forKey: "uid")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(avatar_large, forKey: "avatar_large")
    }
    
    // 解档，将二进制数据从磁盘加载，转换成自定义对象时调用，跟反序列化很像
    required init?(coder aDecoder: NSCoder) {
        access_token = aDecoder.decodeObjectForKey("access_token") as? String
        expiresDate = aDecoder.decodeObjectForKey("expiresDate") as? NSDate
        uid = aDecoder.decodeObjectForKey("uid") as? String
        name = aDecoder.decodeObjectForKey("name") as? String
        avatar_large = aDecoder.decodeObjectForKey("avatar_large") as? String
    }
}
