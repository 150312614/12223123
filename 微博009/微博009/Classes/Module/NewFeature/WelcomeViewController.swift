//
//  WelcomeViewController.swift
//  微博009
//
//  Created by Romeo on 15/9/5.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import SDWebImage

class WelcomeViewController: UIViewController {

    /// 头像底部约束
    private var iconBottomCons: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // 设置用户头像
        iconView.sd_setImageWithURL(UserAccountViewModel.sharedUserAccount.avatarUrl)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // 开始动画
        // 1. 计算目标的约束数值
        let h = -(UIScreen.mainScreen().bounds.height + iconBottomCons!.constant)
        // 2. 修改约束数值
        // 使用自动布局，苹果提供了一个自动布局系统，在后台维护界面元素的位置和大小
        // 一旦使用了自动布局，就不要在直接设置 frame
        // 自动布局系统，会`收集`界面上所有需要重新调正位置/大小的控件的约束，然后一次性修改
        // 如果开发中需要强行更新约束，可以直接调用 layoutIfNeeded 方法，会将当前所有的约束变化应用到控件上
        iconBottomCons?.constant = h
        
        // 3. 开始动画
        label.alpha = 0
        // 开发中需要注意：不要让重要的控件移出屏幕外侧！
        UIView.animateWithDuration(1.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: [], animations: { () -> Void in
            
            // 如果需要更新布局
            self.view.layoutIfNeeded()
            
            }) { (_) -> Void in
                
                UIView.animateWithDuration(0.8, animations: { () -> Void in
                    self.label.alpha = 1
                    }, completion: { (_) -> Void in
                        
                        // 提示：程序中尽量不要直接在其他位置更新根控制器
                        // UIApplication.sharedApplication().keyWindow?.rootViewController = MainViewController()
                        // 利用通知，通知 AppDelegate 更改控制器
                        NSNotificationCenter.defaultCenter().postNotificationName(HMSwitchRootViewControllerNotification, object: nil)
                })
        }
    }
    
    private func setupUI() {
        // 1. 添加控件
        view.addSubview(backImageView)
        view.addSubview(iconView)
        view.addSubview(label)
        
        // 2. 自动布局
        backImageView.ff_Fill(view)
        
        let cons = iconView.ff_AlignInner(type: ff_AlignType.BottomCenter, referView: view, size: CGSize(width: 90, height: 90), offset: CGPoint(x: 0, y: -200))
        self.iconBottomCons = iconView.ff_Constraint(cons, attribute: NSLayoutAttribute.Bottom)
        
        label.ff_AlignVertical(type: ff_AlignType.BottomCenter, referView: iconView, size: nil, offset: CGPoint(x: 0, y: 16))
    }
    
    // MARK: - 懒加载控件
    private lazy var backImageView: UIImageView = UIImageView(image: UIImage(named: "ad_background"))
    private lazy var iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "avatar_default_big"))
        
        // 设置圆角
        iv.layer.cornerRadius = 45
        iv.layer.masksToBounds = true
        
        return iv
    }()
    private lazy var label: UILabel = UILabel(title: "欢迎归来", color: UIColor.darkGrayColor(), fontSize: 18)
}
