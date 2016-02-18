//
//  StatusViewModel.swift
//  微博009
//
//  Created by Romeo on 15/9/5.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 原创微博的可重用标识符
let HMStatusNormalCellID = "HMStatusNormalCellID"
/// 转发微博的可重用标识符
let HMStatusForwardCellID = "HMStatusForwardCellID"

/// 微博的视图模型，供界面显示使用
class StatusViewModel: NSObject {

    /// 微博对象
    var status: Status
    
    /// 当前模型对应的行高
    var rowHeight: CGFloat = 0
    
    /// 返回当前视图模型对应的可重用标识符
    var cellID: String {
        return status.retweeted_status != nil ? HMStatusForwardCellID : HMStatusNormalCellID
    }
    
    /// 被转发的原创微博文字，格式: @作者:原文
    var forwardText: String? {
        let username = status.retweeted_status?.user?.name ?? ""
        let text = status.retweeted_status?.text ?? ""
        
        return "@\(username):\(text)"
    }
    
    /// 用户头像 URL
    var userIconUrl: NSURL? {
        return NSURL(string: status.user?.profile_image_url ?? "")
    }
    /// 认证类型 -1：没有认证，0，认证用户，2,3,5: 企业认证，220: 达人
    /// imageWithNamed 方法能够缓存图像，所以两个计算型属性的效率不会受到影响
    /// 设置计算型属性的时候，需要考虑到性能
    /// imageWithNamed 方法千万不要加载太大的图片，程序员无法释放内存！
    var userVipImage: UIImage? {
        switch (status.user?.verified ?? -1) {
        case 0: return UIImage(named: "avatar_vip")
        case 2, 3, 5: return UIImage(named: "avatar_enterprise_vip")
        case 220: return UIImage(named: "avatar_grassroot")
        default: return nil
        }
    }
    /// 会员等级 1-6
    var userMemberImage: UIImage? {
        if status.user?.mbrank > 0 && status.user?.mbrank < 7 {
            return UIImage(named: "common_icon_membership_level\(status.user!.mbrank)")
        }
        return nil
    }

    /// 如果是原创微博有图，在 pic_urls 数组中记录
    /// 如果是`转发微博`有图，在 retweeted_status.pic_urls 数组中记录
    /// 如果`转发微博`有图，pic_urls 数组中没有图
    /// 配图缩略图 URL 数组
    var thumbnailURLs: [NSURL]?
    /// 计算型属性：只有在用户点击一张图像的时候，根据 缩略图地址临时生成中等尺寸的图像数组
    /// 计算方法：将 thumbnail 替换成 bmiddle
    /// 中等尺寸的图像 URL 数组 - 用户不一定会点击所有的图像去查看
    var bmiddleURLs: [NSURL]? {
        // 1. 判断 thumbnailURLs 是否为 nil
        guard let urls = thumbnailURLs else {
            return nil
        }
        
        // 2. 顺序替换每一个 url 字符串中的单词
        var array = [NSURL]()
        
        for url in urls {
            let urlString = url.absoluteString.stringByReplacingOccurrencesOfString("/thumbnail/", withString: "/bmiddle/")
            
            array.append(NSURL(string: urlString)!)
        }
        return array
    }
    
    // MARK: - 构造函数
    init(status: Status) {
        self.status = status
        
        // 如果是转发微博，取 retweeted_status 的 pic_urls 否则直接取 pic_urls
        if let urls = status.retweeted_status?.pic_urls ?? status.pic_urls {
            
            thumbnailURLs = [NSURL]()
            
            for dict in urls {
                thumbnailURLs?.append(NSURL(string: dict["thumbnail_pic"]!)!)
            }
        }
        
        super.init()
    }
    
    override var description: String {
        return status.description + " 缩略图 URL 数组 \(thumbnailURLs)"
    }
}
