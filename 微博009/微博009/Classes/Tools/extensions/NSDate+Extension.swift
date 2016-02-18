//
//  NSDate+Extension.swift
//  01-日期字符串
//
//  Created by Romeo on 15/9/15.
//  Copyright © 2015年 itheima. All rights reserved.
//

import Foundation

extension NSDate {
    
    /// 将新浪的日期格式字符串生成一个 NSDate
    class func sinaDate(str: String) -> NSDate? {
        // 1. 转换日期
        let df = NSDateFormatter()
        // 提示：以前版本的模拟器不需要指定，但是真机一定要，否则会出错
        df.locale = NSLocale(localeIdentifier: "en")
        // 指定日期字符串的格式
        df.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        
        // 生成日期
        return df.dateFromString(str)
    }
    
    /// 返回日期的描述字符串
    ///
    /// 格式如下
    ///     -   刚刚(一分钟内)
    ///     -   X分钟前(一小时内)
    ///     -   X小时前(当天)
    ///     -   昨天 HH:mm(昨天)
    ///     -   MM-dd HH:mm(一年内)
    ///     -   yyyy-MM-dd HH:mm(更早期)
    var dateDescription: String {
        
        // 1. 日历类 - 提供了非常丰富的日期转换函数
        // 获取当前的日历对象
        let canlender = NSCalendar.currentCalendar()
        
        // 2. 今天
        if canlender.isDateInToday(self) {
            // 计算当前系统时间距离指定时间的秒数
            let delta = Int(NSDate().timeIntervalSinceDate(self))
            
            if delta < 60 {
                return "刚刚"
            }
            
            if delta < 3600 {
                return "\(delta / 60) 分钟前"
            }
            
            return "\(delta / 3600) 小时前"
        }
        
        // 3. 其他日期
        var fmtString = " HH:mm"
        if canlender.isDateInYesterday(self) {
            fmtString = "昨天" + fmtString
        } else {
            fmtString = "MM-dd" + fmtString
            
            // 提取日期中指定`单位 year/month/day ....`的数字
            // print(canlender.component(.Year, fromDate: self))
            
            // 计算两个日期之间的差值，如果是年度差，会计算一个完整年
            let coms = canlender.components(.Year, fromDate: self, toDate: NSDate(), options: [])

            // 一年前
            if coms.year > 0 {
                fmtString = "yyyy-" + fmtString
            }
        }
        
        // 根据格式字符串，生成对应的日期字符串
        let df = NSDateFormatter()
        df.locale = NSLocale(localeIdentifier: "en")
        df.dateFormat = fmtString
        
        return df.stringFromDate(self)
    }
}