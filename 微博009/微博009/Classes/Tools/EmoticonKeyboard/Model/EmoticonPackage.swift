//
//  EmoticonPackage.swift
//  01-表情键盘
//
//  Created by Romeo on 15/9/11.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 表情包模型
class EmoticonPackage: NSObject {
    /// 目录名
    var id: String?
    /// 分组名
    var group_name_cn: String?
    /// 表情符号数组
    lazy var emoticons = [Emoticon]()
    
    init(dict: [String: AnyObject]) {
        super.init()
        
        // setValuesForKeysWithDictionary 会循环调用 setValueForKey 函数
        // 但是，调用的顺序程序员无法决定
        // 如果先调用 emoticons 数组，再调用 id 就无法正确拼接路径
        id = dict["id"] as? String
        group_name_cn = dict["group_name_cn"] as? String
        
        // 每隔`20`个按钮添加一个删除按钮
        var index = 0
        if let array = dict["emoticons"] as? [[String: String]] {
            // 循环创建 emoticon 数组
            for var d in array {
                // 拼接 png 的路径，将 id + "/" + png，后续再读取图片的时候，直接使用包路径就可以
                // 判断字典中是否包含 png 的 key，排除 emoji 没有图片的情况
                if let imagePath = d["png"] {
                    // 修改字典中的路径
                    d["png"] = id! + "/" + imagePath
                }
                
                emoticons.append(Emoticon(dict: d))
                
                index++
                // 判断是否已经20个
                if index == 20 {
                    // 插入一个删除按钮
                    emoticons.append(Emoticon(isRemove: true))
                    // 让计数复位
                    index = 0
                }
            }
        }
        
        appendBlankEmoticon()
    }
    
    /// 追加空白表情
    func appendBlankEmoticon() {
        let count = emoticons.count % 21
        
        print("\(group_name_cn)分组 剩余 \(count) 个 按钮")
        // 如果刚好被 21 整除直接返回
        if count == 0 && emoticons.count > 0  {
            return
        }
        
        // 如果有需要补足的情况，表情数组完全为空
        // 追加到20个空白按钮
        for _ in count..<20 {
            emoticons.append(Emoticon(isEmpty: true))
        }
        
        // 末尾追加一个删除按钮
        emoticons.append(Emoticon(isRemove: true))
    }
    
    override var description: String {
        let keys = ["id", "group_name_cn", "emoticons"]
        
        return dictionaryWithValuesForKeys(keys).description
    }
}
