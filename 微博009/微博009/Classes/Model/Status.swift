//
//  Status.swift
//  微博009
//
//  Created by Romeo on 15/9/5.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 微博模型
class Status: NSObject {
    /// 创建时间
    var created_at: String?
    /// 微博ID
    var id: Int = 0
    /// 微博信息内容
    var text: String?
    /// 微博来源
    var source: String? {
        didSet {
            // 一旦给 source 设置数值之后，立即提取 文本链接并且保存
            // 在 didSet 中，给本属性设置数值，不会再次调用 didSet
            source = source?.href()?.text
        }
    }
    /// 配图URL字符串的数组
    var pic_urls: [[String: String]]?
    
    /// 用户模型 － 如果直接使用 KVC，会变成字典
    var user: User?
    
    /// 如果是原创微博有图，在 pic_urls 数组中记录
    /// 如果是`转发微博`有图，在 retweeted_status.pic_urls 数组中记录
    /// 如果`转发微博`有图，pic_urls 数组中没有图
    /// 被转发的原创微博对象
    var retweeted_status: Status?
    
    // MARK: - 构造函数
    // NSArray & NSDictionary 在 swift 中极少用，contentOfFile 加载 plist 才会使用
    init(dict: [String: AnyObject]) {
        super.init()
        
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forKey key: String) {
        // 1. 判断 key 是否是 "User"
        if key == "user" {
            // 如果 key 是 user, value 是字典
            // 调用 User 的构造函数创建 user 对象属性
            user = User(dict: value as! [String: AnyObject])
            
            // 如果不return，user 属性又会被默认的 KVC 方法，设置成字典
            return
        }
        
        // 2. 判断 key 是否是 retweeted_status
        if key == "retweeted_status" {
            retweeted_status = Status(dict: value as! [String: AnyObject])
            
            return
        }
        
        super.setValue(value, forKey: key)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    override var description: String {
        let keys = ["created_at", "id", "text", "source", "user", "pic_urls", "retweeted_status"]
        
        return dictionaryWithValuesForKeys(keys).description
    }
}
