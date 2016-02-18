//
//  Emoticon.swift
//  01-表情键盘
//
//  Created by Romeo on 15/9/11.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 表情符号模型
class Emoticon: NSObject {

    /// 表情文字
    var chs: String?
    /// 表情图片
    var png: String?
    /// 图像的完整路径
    var imagePath: String {
        return (png != nil) ? NSBundle.mainBundle().bundlePath + "/Emoticons.bundle/" + png! : ""
    }
    /// emoji 编码
    var code: String? {
        didSet {
            // 读取 16 进制的数值
            let scanner = NSScanner(string: code!)
            
            var value: UInt32 = 0
            scanner.scanHexInt(&value)
            
            emoji = String(Character(UnicodeScalar(value)))
        }
    }
    
    /// emiji 字符串
    var emoji: String?
    /// 删除按钮标记
    var isRemove = false
    /// 空白按钮标记
    var isEmpty = false
    /// 表情的使用频率
    var times = 0
    
    init(isEmpty: Bool) {
        super.init()
        
        self.isEmpty = isEmpty
    }
    
    /// 构造删除按钮
    init(isRemove: Bool) {
        super.init()
        
        self.isRemove = isRemove
    }
    
    init(dict: [String: String]) {
        super.init()
        
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    override var description: String {
        let keys = ["chs", "png", "code", "isRemove", "isEmpty", "times"]
        
        return dictionaryWithValuesForKeys(keys).description
    }
}
