//
//  NetworkTools.swift
//  微博009
//
//  Created by Romeo on 15/9/1.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import AFNetworking
import ReactiveCocoa

enum RequestMethod: String {
    case GET = "GET"
    case POST = "POST"
}

/// 网络工具类
class NetworkTools: AFHTTPSessionManager {

    // MARK: - App 信息
    private let clientId = "3763573571"
    private let appSecret = "d3e7a54be3676c0d067f252fa5d47c07"
    /// 回调地址
    let redirectUri = "http://www.baidu.com"
    
    /// 单例
    static let sharedTools: NetworkTools = {
        
        // 指定 baseURL
        var instance = NetworkTools(baseURL: nil)
        
        // 设置反序列化的支持格式
        instance.responseSerializer.acceptableContentTypes?.insert("text/plain")
        
        return instance
    }()
    
    // MARK: - 发布微博
    /// 发布微博
    ///
    /// - parameter status: 微博文本，不能超过 140 个字，需要百分号转义(AFN会做)
    /// - parameter image:  如果有，就上传图片
    ///
    /// - returns: RAC Signal
    /// - see: [http://open.weibo.com/wiki/2/statuses/update](http://open.weibo.com/wiki/2/statuses/update)
    /// - see: [http://open.weibo.com/wiki/2/statuses/upload](http://open.weibo.com/wiki/2/statuses/upload)
    func sendStatus(status: String, image: UIImage?) -> RACSignal {
        
        let params = ["status": status]
        
        // 如果没有图片，就是文本微博
        if image == nil {
            // 文本微博
            return request(.POST, URLString: "https://api.weibo.com/2/statuses/update.json", parameters: params)
        } else {
            // 图片微博
            return upload("https://upload.api.weibo.com/2/statuses/upload.json", parameters: params, image: image!)
        }
    }
    
    // MARK: - 微博数据
    /// 加载微博数据
    ///
    /// - parameter since_id:   若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0
    /// - parameter max_id:     若指定此参数，则返回ID小于或等于max_id的微博，默认为0，id越大，微博越新。
    ///
    /// - returns: RAC Signal
    /// - see: [http://open.weibo.com/wiki/2/statuses/home_timeline](http://open.weibo.com/wiki/2/statuses/home_timeline)
    func loadStatus(since_id since_id: Int, max_id: Int) -> RACSignal {
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        
        // 创建空的参数字典
        var params = [String: AnyObject]()
        if since_id > 0 {
            params["since_id"] = since_id
        } else if max_id > 0 {
            params["max_id"] = max_id - 1
        }
        
        return request(.GET, URLString: urlString, parameters: params)
    }
    
    // MARK: - OAuth
    /// OAuth 授权 URL
    /// - see: [http://open.weibo.com/wiki/Oauth2/authorize](http://open.weibo.com/wiki/Oauth2/authorize)
    var oauthUrl: NSURL {
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(clientId)&redirect_uri=\(redirectUri)"
        
        return NSURL(string: urlString)!
    }
    
    /// 获取 AccessToken
    ///
    /// - parameter code: 请求码/授权码
    /// - see: [http://open.weibo.com/wiki/OAuth2/access_token](http://open.weibo.com/wiki/OAuth2/access_token)
    func loadAccessToken(code: String) -> RACSignal {
        let urlString = "https://api.weibo.com/oauth2/access_token"
        
        let params = ["client_id": clientId,
            "client_secret": appSecret,
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectUri]
        
        return request(.POST, URLString: urlString, parameters: params, withToken: false)
    }
    
    /// 加载用户信息
    ///
    /// - parameter uid:          uid
    ///
    /// - returns: RAC Signal
    /// - see: [http://open.weibo.com/wiki/2/users/show](http://open.weibo.com/wiki/2/users/show)
    func loadUserInfo(uid: String) -> RACSignal {
        
        let urlString = "https://api.weibo.com/2/users/show.json"
        let params = ["uid": uid]
        
        return request(.GET, URLString: urlString, parameters: params)
    }
    
    // MARK: - 私有方法，封装 AFN 的网络请求方法
    /// 在指定参数字典中追加 accessToken
    ///
    /// - parameter parameters: parameters 地址
    ///
    /// - returns: 是否成功，如果token失效，返回 false
    private func appendToken(inout parameters: [String: AnyObject]?) -> Bool {

        // 判断单例中的 token 是否有效
        guard let token = UserAccountViewModel.sharedUserAccount.accessToken else {
            return false
        }
        
        // 判断是否传递了参数字典
        if parameters == nil {
            parameters = [String: AnyObject]()
        }
        
        // 后续的 token 都是有值的
        parameters!["access_token"] = token
        
        return true
    }
    
    /// 网络请求方法(对 AFN 的 GET & POST 进行了封装)
    ///
    /// - parameter method:     method
    /// - parameter URLString:  URLString
    /// - parameter parameters: 参数字典
    /// - parameter withToken:  是否包含 accessToken，默认带 token 访问
    ///
    /// - returns: RAC Signal
    private func request(method: RequestMethod, URLString: String, var parameters: [String: AnyObject]?, withToken: Bool = true) -> RACSignal {
        
        return RACSignal.createSignal({ (subscriber) -> RACDisposable! in
            
            // 0. 判断是否需要 token － 将代码放在最合适的地方
            // 如果 token 失效，直接返回错误
            if withToken && !self.appendToken(&parameters) {
                subscriber.sendError(NSError(domain: "com.itheima.error", code: -1001, userInfo: ["errorMessage": "Token 为空"]))
                return nil
            }
            
            // 1. 成功的回调闭包
            let successCallBack = { (task: NSURLSessionDataTask, result: AnyObject) -> Void in
                // 将结果发送给订阅者
                subscriber.sendNext(result)
                // 完成
                subscriber.sendCompleted()
            }
            
            // 2. 失败的回调闭包
            let failureCallBack = { (task: NSURLSessionDataTask, error: NSError) -> Void in
                // 即使应用程序已经发布，在网络访问中，如果出现错误，仍然要输出日志，属于严重级别的错误
                printLog(error, logError: true)
                
                subscriber.sendError(error)
            }
            
            // 3. 根据方法，选择调用不同的网络方法
            // if method == RequestMethod.GET {
            if method == .GET {
                self.GET(URLString, parameters: parameters, success: successCallBack, failure: failureCallBack)
            } else {
                self.POST(URLString, parameters: parameters, success: successCallBack, failure: failureCallBack)
            }
            
            return nil
        })
    }
    
    // 上传文件
    /// 上传文件
    ///
    /// - parameter URLString:  URLString
    /// - parameter parameters: parameters
    /// - parameter image:      image
    ///
    /// - returns: RAC Signal
    private func upload(URLString: String, var parameters: [String: AnyObject]?, image: UIImage) -> RACSignal {
        
        // 闭包返回值是对信号销毁时需要做的内存销毁工作，同样是一个 block，AFN 的可以直接 nil
        return RACSignal.createSignal() { (subscriber) -> RACDisposable! in
            
            // 0. 判断是否需要 token － 将代码放在最合适的地方
            if !self.appendToken(&parameters) {
                subscriber.sendError(NSError(domain: "com.itheima.error", code: -1001, userInfo: ["errorMessage": "Token 为空"]))
                return nil
            }
            
            // 1. 调用 AFN 的上传文件方法
            self.POST(URLString, parameters: parameters, constructingBodyWithBlock: { (formData) -> Void in
                
                // 将图像转换成二进制数据
                let data = UIImagePNGRepresentation(image)!
                
                // formData 是遵守协议的对象，AFN内部提供的，使用的时候，只需要按照协议方法传递参数即可！
                /**
                    1. 要上传图片的二进制数据
                    2. 服务器的字段名，开发的时候，咨询后台
                    3. 保存在服务器的文件名，很多后台允许随便写
                    4. mimeType -> 客户端告诉服务器上传文件的类型，格式
                        大类/小类
                        image/jpg
                        image/gif
                        image/png
                        如果，不想告诉服务器具体的类型，可以使用 application/octet-stream
                
                */
                formData.appendPartWithFileData(data, name: "pic", fileName: "ohoh", mimeType: "application/octet-stream")
                
                }, success: { (_, result) -> Void in
                    
                    subscriber.sendNext(result)
                    subscriber.sendCompleted()
                    
                }, failure: { (_, error) -> Void in
                    printLog(error, logError: true)
                    
                    subscriber.sendError(error)
            })
            
            return nil
        }
    }
}
