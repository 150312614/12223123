//
//  UIBarButton+Extension.swift
//  微博009
//
//  Created by Romeo on 15/9/10.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    /// 便利构造函数
    ///
    /// - parameter imageName:  imageName
    /// - parameter target:     target
    /// - parameter actionName: actionName
    ///
    /// - returns: UIBarButtonItem
    convenience init(imageName: String, target: AnyObject?, actionName: String?) {
        let button = UIButton(imageName: imageName)
        
        // 添加监听方法
        if target != nil && actionName != nil {
            button.addTarget(target, action: Selector(actionName!), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        self.init(customView: button)
    }
}
