//
//  UIColor+Extension.swift
//  Weibo09
//
//  Created by Romeo on 15/9/14.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// 创建随机颜色
    class func randomColor() -> UIColor {
        let r = CGFloat(random() % 256) / 255
        let g = CGFloat(random() % 256) / 255
        let b = CGFloat(random() % 256) / 255
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
