//
//  UILabel+Extension.swift
//  微博009
//
//  Created by Romeo on 15/9/5.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

extension UILabel {
    
    /// 便利构造函数
    ///
    /// - parameter title:          title
    /// - parameter color:          color
    /// - parameter fontSize:       fontSize
    /// - parameter layoutWidth:    布局宽度，一旦大于 0，就是多行文本
    ///
    /// - returns: UILabel
    convenience init(title: String?, color: UIColor, fontSize: CGFloat, layoutWidth: CGFloat = 0) {
        // 实例化当前对象
        self.init()
        
        // 设置对象属性
        text = title
        textColor = color
        font = UIFont.systemFontOfSize(fontSize)
        
        if layoutWidth > 0 {
            preferredMaxLayoutWidth = layoutWidth
            numberOfLines = 0
        }
        
        sizeToFit()
    }
}
