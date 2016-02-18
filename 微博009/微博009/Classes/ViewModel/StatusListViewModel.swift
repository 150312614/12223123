//
//  StatusListViewModel.swift
//  微博009
//
//  Created by Romeo on 15/9/5.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SDWebImage

/// 微博列表的视图模型 - 分离网络方法
class StatusListViewModel: NSObject {

    /// 微博数据数组 - 项目名称不能由`中文+数字`组成
    /// since_id 第一项
    /// max_id 最后一项
    lazy var statuses = [StatusViewModel]()
    
    /// 加载微博数据
    ///
    /// - parameter isPullupRefresh: 是否上拉刷新标记
    ///
    /// - returns: RAC Signal
    func loadStatuses(isPullupRefresh isPullupRefresh: Bool) -> RACSignal {
        
        // 初始刷新: statuses 数组没有内容
        // 下拉刷新: 取 statuses 的第一项的 id 作为 since_id
        var since_id = statuses.first?.status.id ?? 0
        var max_id = 0
        // 上拉刷新: 取 statuses 的最后一项的 id 作为 max_id
        if isPullupRefresh {
            since_id = 0
            max_id = statuses.last?.status.id ?? 0
        }
        
        // RACSignal 在订阅的时候，会对 self 进行强引用，sendCompleted 说明信号完成，会释放对 self 的强引用
        // 以下代码不存在循环引用，但是为了保险，可以使用 [weak self] 防范！
        return RACSignal.createSignal({ [weak self] (subscriber) -> RACDisposable! in
            
            // 网络工具，执行的时候，会对 self 进行强引用，网络访问结束后，后对 self 的引用释放！
            NetworkTools.sharedTools.loadStatus(since_id: since_id, max_id: max_id).subscribeNext({ (result) -> Void in
                
                // 1. 获取 result 中的 statuses 字典数组
                guard let array = result["statuses"] as? [[String: AnyObject]] else {
                    printLog("没有正确的数据")
                    subscriber.sendError(NSError(domain: "com.itheima.error", code: -1002, userInfo: ["error message": "没有正确数据"]))
                    return
                }
                
                // 2. 字典转模型
                // 定义并且创建一个临时数组，记录当前网络请求返回的结果
                var arrayM = [StatusViewModel]()
                
                // 遍历数组，字典转模型
                for dict in array {
                    arrayM.append(StatusViewModel(status: Status(dict: dict)))
                }
                
                printLog("刷新到 \(arrayM.count) 条微博")

                // 添加尾随闭包
                self?.cacheWebImage(arrayM) {
                    
                    if max_id > 0 {     // 将新数据拼接在现有数组的末尾
                        self?.statuses += arrayM
                    } else {            // 初始刷新&下拉刷新
                        self?.statuses = arrayM + self!.statuses
                    }
                    
                    // 如果是下拉刷新，提示用户
                    if since_id > 0 {
                        // RAC 是 OC 的，通知订阅者，下拉刷新的数据
                        subscriber.sendNext(arrayM.count)
                    }
                    
                    // 3. 通知调用方数据加载完成
                    subscriber.sendCompleted()
                }
                                
                }, error: { (error) -> Void in
                    
                    subscriber.sendError(error)
                }) {}
            
            return nil
        })
    }
    
    /// 缓存网络图片
    ///
    /// - parameter array:    视图模型数组
    /// - parameter finished: 完成回调
    private func cacheWebImage(array: [StatusViewModel], finished: () -> ()) {
        
        // 1. 定义调度组
        let group = dispatch_group_create()
        // 记录图像大小
        var dataLength = 0
        
        // 遍历视图模型数组
        for viewModel in array {
            
            // 目标：只需要缓存单张图片
            let count = viewModel.thumbnailURLs?.count ?? 0
            
            if count != 1 {
                continue
            }
            
            printLog(viewModel.thumbnailURLs)
            
            // 2. 入组 - 紧贴着 block/闭包，enter & leave 要配对出现
            dispatch_group_enter(group)
            
            // 使用 SDWebImage 的核心函数下载图片
            SDWebImageManager.sharedManager().downloadImageWithURL(viewModel.thumbnailURLs![0], options: [], progress: nil, completed: { (image, _, _, _, _) in
                
                // 代码执行到此，图片已经缓存完成，不一定有 image
                if image != nil {
                    // 将 image 转换成二进制数据
                    let data = UIImagePNGRepresentation(image)
                    
                    dataLength += data?.length ?? 0
                }
                
                // 3. 出组 - block 的最后一句
                dispatch_group_leave(group)
            })
        }
        
        // 4. 调度组监听
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            printLog("缓存图像完成 \(dataLength / 1024) K")
            
            // 执行闭包
            finished()
        }
    }
}
