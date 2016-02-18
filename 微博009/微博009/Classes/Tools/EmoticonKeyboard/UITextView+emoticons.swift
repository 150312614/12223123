//
//  UITextView+emoticons.swift
//  01-表情键盘
//
//  Created by Romeo on 15/9/11.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

extension UITextView {
  
    /// 计算型属性，返回完整的表情字符串
    var emoticonText: String {
        
        let attrText = attributedText
        
        // 创建一个可变字符串
        var strM = String()
        
        attrText.enumerateAttributesInRange(NSRange(location: 0, length: attrText.length), options: []) { (dict, range, _) -> Void in
            
            if let attachment = dict["NSAttachment"] as? EmoticonAttachment {
                print("表情图片 \(attachment.chs)")
                strM += attachment.chs
            } else {
                let str = (attrText.string as NSString).substringWithRange(range)
                print("文本内容：\(str)")
                strM += str
            }
        }

        return strM
    }
    
    /// 插入表情符号
    ///
    /// - parameter emoticon: 表情符号模型
    func insertEmoticon(emoticon: Emoticon) {
        
        // 0. 空表情
        if emoticon.isEmpty {
            return
        }
        
        // 1. 删除按钮
        if emoticon.isRemove {
            deleteBackward()
            return
        }
        
        // 2. emoji
        if emoticon.emoji != nil {
            replaceRange(selectedTextRange!, withText: emoticon.emoji!)
            return
        }
        
        // 3. 表情图片 一定有图片
        // 0> 谁的事情谁负责，将代码放在最合适的地方！
        let imageText = EmoticonAttachment.emoticonAttributeText(emoticon, font: font!)
        
        // 1> 从 textView 中取出属性文本
        let strM = NSMutableAttributedString(attributedString: attributedText)
        
        // 2> 插入图片文字
        strM.replaceCharactersInRange(selectedRange, withAttributedString: imageText)
        
        // 3> 重新设置 textView 的内容
        // 1) 记录当前光标位置
        let range = selectedRange
        // 2) 设置内容
        attributedText = strM
        // 3) 恢复光标位置
        selectedRange = NSRange(location: range.location + 1, length: 0)
        
        // 4> 执行代理方法 - 代理就是`在需要的时候`，通知代理执行协议方法
        // 协议方法之所以需要强行解包，是因为方法是可选的，!表示代理一定要实现协议方法
        delegate?.textViewDidChange!(self)
    }

}
