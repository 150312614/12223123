//
//  EmoticonViewModel.swift
//  01-表情键盘
//
//  Created by Romeo on 15/9/11.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 表情的视图模型 -> 加载表情数据
/**
    从 Emoticons.bundle 中读取 emoticons.plist
    遍历 packages 数组，创建 EmoticonPackage 的数组

    EmoticonPackage 的明细内容从 id 对应的目录加载 info.plist 完成字典转模型

    - 在 Swift 中，一个对象可以不继承自 NSObject
    - 继承自 NSObject 可以使用 KVC 方法给属性设置数值 => 如果是模型对象，最好还是使用 NSObject
    - 如果过对象，没有属性，或者不依赖 KVC，可以建立一个没有父类的对象！对象的量级比较轻，内存消耗小！
*/
class EmoticonViewModel {

    /// 单例
    static let sharedViewModel = EmoticonViewModel()
    
    // 构造函数 - private 修饰符号能保证外界只能通过单例属性访问对象，不能直接实例化
    private init() {
        // 加载表情包
        loadPackages()
    }
    
    /// 表情包的数组
    lazy var packages = [EmoticonPackage]()
    
    /// 根据给定的字符串，生成带表情符号的属性字符串
    func emoticonText(str: String, font: UIFont) -> NSAttributedString {
        let pattern = "\\[.*?\\]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        // matchesInString 查找 pattern 所有的匹配项
        let results = regex.matchesInString(str, options: [], range: NSRange(location: 0, length: str.characters.count))
        
        // 获得数组数量
        var count = results.count
        
        // 准备属性字符串
        let strM = NSMutableAttributedString(string: str)
        
        // 根据数量`倒序`遍历数组内容
        while count > 0 {
            let range = results[--count].rangeAtIndex(0)
            
            // 根据 range 获取到对应的 chs 字符串
            let chs = (str as NSString).substringWithRange(range)
            
            // 根据 chs 获得对应的 emoticon 对象
            if let emoticon = emoticon(chs) {
                
                let imageText = EmoticonAttachment.emoticonAttributeText(emoticon, font: font)
                
                // 替换 strM 中对应的属性文本
                strM.replaceCharactersInRange(range, withAttributedString: imageText)
            }
        }
        
        return strM
    }
    
    /// 根据字符串查找对应的表情符号
    private func emoticon(str: String) -> Emoticon? {
        
        var emoticon: Emoticon?
        
        for p in packages {
            
// 从 p.emoticons 数组中`过滤`出指定字符串的表情
//            emoticon = p.emoticons.filter({ (em) -> Bool in
//                return em.chs == str
//            }).last
            
            emoticon = p.emoticons.filter() { $0.chs == str }.last
            
            // 如果找到 emoticon 直接退出
            if emoticon != nil {
                break
            }
        }
        
        return emoticon
    }
    
    /// 添加最近的表情
    ///
    /// - parameter indexPath: indexPath
    func favorite(indexPath: NSIndexPath) {
        // 0. 如果是第0个分组，不参与排序
        if indexPath.section == 0 {
            return
        }
        
        // 1. 获取表情符号
        let em = emoticon(indexPath)
        em.times++
        
        // 2. 将表情符号添加到第0组的首位
        // 判断是否已经存在表情
        if !packages[0].emoticons.contains(em) {
            packages[0].emoticons.insert(em, atIndex: 0)
        }
        
        // 3. 对数组进行排序 直接排序当前数组 sortInPlace
        // Swift中，对尾随闭包，同时有返回值的又一个简单的写法
//        packages[0].emoticons.sortInPlace { (obj1, obj2) -> Bool in
//            return obj1.times > obj2.times
//        }
        // $0 对应第一个参数，$1对应第二个参数，依次类推，return 可以省略
        packages[0].emoticons.sortInPlace { $0.times > $1.times }

        // 4. 删除多余的表情 － 倒数第二个
        if packages[0].emoticons.count > 21 {
            packages[0].emoticons.removeAtIndex(19)
        }
    }
    
    /// 根据 indexPath 返回对应的表情模型
    ///
    /// - parameter indexPath: indexPath
    ///
    /// - returns: 表情模型
    func emoticon(indexPath: NSIndexPath) -> Emoticon {
        return packages[indexPath.section].emoticons[indexPath.item]
    }

    // MARK: - 私有函数
    /// 加载表情包
    private func loadPackages() {
        
        // 0. 增加最近分组
        packages.append(EmoticonPackage(dict: ["group_name_cn": "最近AA"]))
        
        // 1. 读取 emoticons.plist
        let path = NSBundle.mainBundle().pathForResource("emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")
        
        // 2. 读取字典
        let dict = NSDictionary(contentsOfFile: path!)
        
        // 3. 获取 packages 数组
        let array = dict!["packages"] as! [[String: AnyObject]]

        // 4. 遍历数组，创建模型
        for infoDict in array {
            // 1> 获取 id，目录中对应的 info.plist 才是表情包的数据
            let id = infoDict["id"] as! String
            
            // 2> 拼接表情包路径
            let emPath = NSBundle.mainBundle().pathForResource("info.plist", ofType: nil, inDirectory: "Emoticons.bundle/" + id)
            
            // 3> 加载 info.plist 字典
            let packageDict = NSDictionary(contentsOfFile: emPath!) as! [String: AnyObject]
            
            // 4> 字典转模型
            packages.append(EmoticonPackage(dict: packageDict))
        }
        
        print(packages)
    }
}
