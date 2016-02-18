//
//  EmoticonAttachment.swift
//  01-表情键盘
//
//  Created by Romeo on 15/9/11.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

class EmoticonAttachment: NSTextAttachment {

    /// 表情文字
    var chs: String
    
    init(chs: String) {
        self.chs = chs
        
        super.init(data: nil, ofType: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 创建表情属性文本
    ///
    /// - returns: 属性文本
    class func emoticonAttributeText(emoticon: Emoticon, font: UIFont) -> NSAttributedString {
        let attachment = EmoticonAttachment(chs: emoticon.chs!)
        
        attachment.image = UIImage(contentsOfFile: emoticon.imagePath)
        // 图片高度
        let height = font.lineHeight
        // bounds 的 x / y 就是 scrollView 的 contentOffset，苹果利用 bounds 的 x/y 能够调整控件内部的偏移位置
        attachment.bounds = CGRect(x: 0, y: -4, width: height, height: height)
        
        // 1) 创建图片属性字符串
        let imageText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        // 2) `添加`字体
        imageText.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: 1))
        
        return imageText
    }
}
