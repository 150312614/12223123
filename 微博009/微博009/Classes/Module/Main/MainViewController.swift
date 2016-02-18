//
//  MainViewController.swift
//  微博009
//
//  Created by Romeo on 15/8/31.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    /// 是苹果专为`代码创建视图`层次结构设计的函数，可以和 XIB / Storyboard 等价
    override func loadView() {
        super.loadView()
    }
    
    /// 视图加载完成会调用
    /// 通常在视图控制器加载完成后，做准备工作，例如：加载数据，或者`一次性`的初始化/准备工作
    /// 如果视图没有被销毁，只会被调用一次
    /// 目前有些团队的开发中，会把创建视图控件的代码放在 viewDidLoad 中
    override func viewDidLoad() {
        super.viewDidLoad()

        // 添加所有的子控制器，注意：不会添加 tabBar 中的按钮
        // 在 iOS 开发中，懒加载是无处不在的，视图资源只有在需要显示的时候，才会被创建
        addChildViewControllers()
    }
    
    /// 视图将要出现，可能会被调用多次，例如：push 一个 vc，再 pop 回来，此方法会被再次调用
    /// 不适合做多次执行的代码
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 不能重复添加按钮，因此 addSubview 方法放在了懒加载内部
        setupComposedButton()
    }
    
    /**
    按钮监听方法，由`运行循环`来调用的，因此不能直接使用 private
    
    swift 中，所有的函数如果不使用 private 修饰，是全局共享的
    
    @objc 关键字能够保证运行循环能够调用，走的 oc 的消息机制，调用之前不再判断方法是否存在
    和 private 联用，就能够做到对方法的保护
    */
    @objc private func clickComposedButton() {
        // 常量有一次设置数值的机会
        let vc: UIViewController
        
        if UserAccountViewModel.sharedUserAccount.userLogon {
            vc = ComposeViewController()
        } else {
            vc = OAuthViewController()
        }
        
        let nav = UINavigationController(rootViewController: vc)
        
        presentViewController(nav, animated: true, completion: nil)
    }
    
    /// 添加撰写按钮，并且设置撰写按钮位置
    private func setupComposedButton() {
        // 拿到控制器的总数
        let count = childViewControllers.count
        
        // 计算每个按钮的宽度
        let w = tabBar.bounds.width / CGFloat(count)
        let rect = CGRect(x: 0, y: 0, width: w, height: tabBar.bounds.height)
        
        // 设置按钮的位置
        composedButton.frame = CGRectOffset(rect, 2 * w, 0)
    }
    
    /// 添加所有子控制器
    private func addChildViewControllers() {
        // 设置 tabBar 的渲染颜色
        // tabBar.tintColor = UIColor.orangeColor()
        
        addChildViewController(HomeTableViewController(), title: "首页", imageName: "tabbar_home")
        addChildViewController(MessageTableViewController(), title: "消息", imageName: "tabbar_message_center")
        
        // 添加了一个空白的控制器
        addChildViewController(UIViewController())
        
        addChildViewController(DiscoverTableViewController(), title: "发现", imageName: "tabbar_discover")
        addChildViewController(ProfileTableViewController(), title: "我", imageName: "tabbar_profile")
    }

    /// 添加独立的子控制器
    ///
    /// - parameter vc:        视图控制器
    /// - parameter title:     title
    /// - parameter imageName: 图像名称
    private func addChildViewController(vc: UIViewController, title: String, imageName: String) {
        
        // 设置标题 navigationItem + tabBarItem
        vc.title = title
        vc.tabBarItem.image = UIImage(named: imageName)
        
        let nav = UINavigationController(rootViewController: vc)
        
        // 添加控制器
        addChildViewController(nav)
    }
    
    // MARK: - 懒加载控件
    private lazy var composedButton: UIButton = {
       
        // 创建一个自定义的 button
        let btn = UIButton()
        
        // 设置图像
        btn.setImage(UIImage(named: "tabbar_compose_icon_add"), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: "tabbar_compose_icon_add_highlighted"), forState: UIControlState.Highlighted)
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_button"), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_button_highlighted"), forState: UIControlState.Highlighted)
        
        self.tabBar.addSubview(btn)
        // 添加监听方法
        btn.addTarget(self, action: "clickComposedButton", forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
}
