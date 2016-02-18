//
//  OAuthViewController.swift
//  微博009
//
//  Created by Romeo on 15/9/1.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import SVProgressHUD

/// OAuth授权控制器
class OAuthViewController: UIViewController, UIWebViewDelegate {
    
    private lazy var webView = UIWebView()
    
    override func loadView() {
        // 根视图就是 webView
        view = webView
        webView.delegate = self
        
        title = "登录新浪微博"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: "close")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自动填充", style: UIBarButtonItemStyle.Plain, target: self, action: "autoFill")
    }
    
    @objc private func close() {
        SVProgressHUD.dismiss()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// 自动填充用户信息
    @objc private func autoFill() {
        let js = "document.getElementById('userId').value = 'daoge10000@sina.cn';" +
            "document.getElementById('passwd').value = 'qqq123';"
        
        // 执行 js 脚本
        webView.stringByEvaluatingJavaScriptFromString(js)
    }
    
    // 尽量让控制器不要管太多事情
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.loadRequest(NSURLRequest(URL: NetworkTools.sharedTools.oauthUrl))
    }
    
    // MARK: - UIWebViewDelegate
    // 通常在 iOS 开发中，如果代理方法有 Bool 类型的返回值，返回 true 通常是一切正常
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let urlString = request.URL!.absoluteString
        // 1. 判断 request.url 的前半部分是否是回调地址，如果不是回调地址，继续加载
        if !urlString.hasPrefix(NetworkTools.sharedTools.redirectUri) {
            // 继续加载
            return true
        }
        
        // 2. 如果是回调地址，检查 query，查询字符串，判断是否包含 "code='
        // query 就是 URL 中 `?` 后面的所有内容
        if let query = request.URL!.query where query.hasPrefix("code=") {
            // 3. 如果有，获取 code
            let code = query.substringFromIndex("code=".endIndex)
            printLog("请求码: + \(code)")
            
            // 4. 调用网络方法，获取 token
            UserAccountViewModel.sharedUserAccount.loadUserAccount(code).subscribeError({ (error) -> Void in
                printLog(error)
                }, completed: { () -> Void in
                    printLog("登录完成!")
                    
                    // 关闭控制器
                    SVProgressHUD.dismiss()
                    // 动画完成之后，再做切换根视图控制器的操作能够保证视图控制器被完全销毁
                    self.dismissViewControllerAnimated(false, completion: { () -> Void in
                        
                        // 通知是同步的，动画完成之后，发送通知
                        NSNotificationCenter.defaultCenter().postNotificationName(HMSwitchRootViewControllerNotification, object: "Main")
                    })
            })
            
        } else {
            print("取消")
        }
        
        return false
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
}
