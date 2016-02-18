//
//  AppDelegate.swift
//  微博009
//
//  Created by Romeo on 15/8/29.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // 打印用户账户信息
        printLog(UserAccountViewModel.sharedUserAccount.userAccount)
        
        // 注册通知 object - 监听由哪一个对象发出的通知，如果设置成 nil，监听所有对象发出的 `name` 通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchRootViewController:", name: HMSwitchRootViewControllerNotification, object: nil)
        
        // 设置网络
        setupNetwork()
        // 设置外观
        setupAppearance()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()

        // 测试加载制定 id 的 控制器
//        let sb = UIStoryboard(name: "Demo", bundle: nil)
//        let vc = sb.instantiateViewControllerWithIdentifier("demoVC")

        window?.rootViewController = defaultRootViewController()
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    deinit {
        // 注销指定名称的通知，在程序被销毁的时候，才会被调用，可以省略！
        NSNotificationCenter.defaultCenter().removeObserver(self, name: HMSwitchRootViewControllerNotification, object: nil)
    }
    
    /// 切换控制器的通知监听方法
    func switchRootViewController(notification: NSNotification) {
        // 提示：在发布通知的时候
        // 如果只是传递消息，post name
        // 如果传递消息的同时，希望传递一个数值，可以通过 `object` 来传递值
        // 如果传递消息的同时，希望传递更多的内容，可以通过 userInfo 字典来传递
        printLog(notification)
        
        window?.rootViewController = (notification.object == nil) ? MainViewController() : WelcomeViewController()
    }
    
    /// 启动的默认根控制器
    private func defaultRootViewController() -> UIViewController {
        
        // 1. 判断用户是否登录
        if UserAccountViewModel.sharedUserAccount.userLogon {
            // 2. 如果登录，判断是否有新版本
            return isNewVersion() ? NewFeatureViewController() : WelcomeViewController()
        }
    
        // 3. 如果没有登录，返回 Main
        return MainViewController()
    }
    
    /// 检查是否是新版本
    private func isNewVersion() -> Bool {
        
        // 1. 当前应用程序的版本号
        let bundleVersion = Double(NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String)!
        printLog("当前版本 \(bundleVersion)")
        
        // 2. 之前保存的程序版本号
        let versionKey = "com.itheima.weibo.version"
        // 如果没有，返回0
        let saxboxVersion = NSUserDefaults.standardUserDefaults().doubleForKey(versionKey)
        printLog("之前保存的版本 \(saxboxVersion)")
        
        // 3. 保存当前版本
        NSUserDefaults.standardUserDefaults().setDouble(bundleVersion, forKey: versionKey)
        
        // 4. 比较两个版本，返回结果
        return bundleVersion > saxboxVersion
    }
    
    /// 设置网络指示器
    private func setupNetwork() {
        // 设置网络指示器，一旦设置，发起网络请求，会在状态栏显示菊花，指示器只负责 AFN 的网络请求，其他网络框架不负责
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        
        // 设置缓存大小 NSURLCache －> GET 请求的数据会被缓存
        // 缓存的磁盘路径: /Library/Caches/(application bundle id)
        // MATTT，内存缓存是 4M，磁盘缓存是 20M
        // 提示：URLSession 只有 dataTask 会被缓存，downloadTask / uploadTask 都不会缓存
        let cache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(cache)
    }
    
    /**
    设置全局外观
    
    修改导航栏外观 - 修改要尽量早，一经设置，全局有效
    */
    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = UIColor.orangeColor()
        UITabBar.appearance().tintColor = UIColor.orangeColor()
    }
}

