//
//  BaseTableViewController.swift
//  微博009
//
//  Created by Romeo on 15/8/31.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 功能模块的基类，单独处理用户登录逻辑
/// Swift 中，遵守协议，直接 , 接着写
class BaseTableViewController: UITableViewController {
    
    /// 用户登录标记
    var userLogon = UserAccountViewModel.sharedUserAccount.userLogon
    
    /// 用户登录视图 － 每个控制器各自拥有自己的 visitorView
    /// 提示：如果使用懒加载，会在用户登录成功之后，视图仍然被创建，虽然不会影响程序执行，但是会消耗内存
    var visitorView: VisitorLoginView?
    
    /**
     如果 view 不存在，系统会再次调用 loadView
    */
    override func loadView() {
        userLogon ? super.loadView() : setupVistorView()
    }
    
    /// 设置访客视图
    private func setupVistorView() {
        visitorView = VisitorLoginView()
        // 替换根视图
        view = visitorView
        
        // 设置导航按钮
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: UIBarButtonItemStyle.Plain, target: self, action: "visitorLoginViewWillRegister")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: UIBarButtonItemStyle.Plain, target: self, action: "visitorLoginViewWillLogin")
        
        // 设置按钮监听方法
        visitorView?.registerButton.addTarget(self, action: "visitorLoginViewWillRegister", forControlEvents: UIControlEvents.TouchUpInside)
        visitorView?.loginButton.addTarget(self, action: "visitorLoginViewWillLogin", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // MARK: VisitorLoginViewDelegate
    @objc private func visitorLoginViewWillLogin() {
        let nav = UINavigationController(rootViewController: OAuthViewController())
        
        presentViewController(nav, animated: true, completion: nil)
    }
    
    @objc private func visitorLoginViewWillRegister() {
        print("注册")
    }
}
