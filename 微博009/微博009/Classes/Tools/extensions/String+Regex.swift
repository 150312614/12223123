//
//  String+Regex.swift
//  02-正则表达式
//
//  Created by Romeo on 15/9/15.
//  Copyright © 2015年 itheima. All rights reserved.
//

import Foundation

extension String {
    
    /// 从当前字符串中，提取超文本链接的 URL & 地址
    /// swift 中提供了元组，可以允许返回多个数值
    func href() -> (link: String, text: String)? {
        let pattern = "<a href=\"(.*?)\".*?>(.*?)</a>"
        
        // 定义正则表达式
        // DotMatchesLineSeparators 能否让 `.` 匹配换行符 － 通常用在抓取网页数据
        let regex = try! NSRegularExpression(pattern: pattern, options: [NSRegularExpressionOptions.DotMatchesLineSeparators])
        
        guard let result = regex.firstMatchInString(self, options: [], range: NSRange(location: 0, length: self.characters.count)) else {
            
            return nil
        }
        
        let link = (self as NSString).substringWithRange(result.rangeAtIndex(1))
        let text = (self as NSString).substringWithRange(result.rangeAtIndex(2))

        return (link, text)
    }
}