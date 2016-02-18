//
//  VisitorLoginView.swift
//  微博009
//
//  Created by Romeo on 15/9/1.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 访客视图
class VisitorLoginView: UIView {
    
    /// 设置界面信息
    ///
    /// - parameter imageName: 图像名称
    /// - parameter message:   消息文字
    func setupInfo(imageName: String?, message: String) {
        
        messageLabel.text = message
        
        // 判断是否传递图片，有图片就不是首页
        if let imgName = imageName {
            iconView.image = UIImage(named: imgName)
            // 隐藏小房子图标
            homeIconView.hidden = true
            // 将遮罩视图移动到底部
            sendSubviewToBack(maskIconView)
        } else {
            startAnimation()
        }
    }
    
    /// 首页图标的动画
    private func startAnimation() {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        
        anim.toValue = 2 * M_PI
        anim.duration = 20
        anim.repeatCount = MAXFLOAT
        // 设置动画不被删除，当 iconView 被销毁的时候，动画会被自动释放
        anim.removedOnCompletion = false
        
        iconView.layer.addAnimation(anim, forKey: nil)
    }
    
    // MARK: - 界面布局
    /// 纯代码开发会被调用
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    /// SB开发会被调用
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    /// 设置界面 - 负责添加和设置界面位置
    private func setupUI() {
        // 1. 添加控件
        addSubview(iconView)
        addSubview(maskIconView)
        addSubview(homeIconView)
        addSubview(messageLabel)
        addSubview(registerButton)
        addSubview(loginButton)
        
        // 2. 设置布局，将布局要添加到视图上
        // "view1.attr1 = view2.attr2 * multiplier + constant"
        // 默认情况下，使用纯代码开发，是不支持自动布局的，如果要支持自动布局，需要将
        // 控件的 translatesAutoresizingMaskIntoConstraints 设置为 false / NO
        // 1> 图标
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: -60))
        
        // 2> 小房子 － 代码设计自动布局的时候，最好有一个固定的参照物
        homeIconView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: homeIconView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: homeIconView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        // 3> 设置文本
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 16))
        // 提示：如果要设置一个固定数值，参照的属性，需要设置为 NSLayoutAttribute.NotAnAttribute，参照对象是 nil
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 224))
        
        // 4> 注册按钮
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 16))
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100))
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        
        // 5> 登录按钮
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 16))
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100))
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        
        // 6. 遮罩视图 - VFL 可视化布局语言
        /**
            H: 水平方向
            V: 垂直方向
            | 边界
            [] 控件
        
            metrics: 极少用
            views: [key, VFL 中[] 括起的名称, value: 控件] -> 控件和 VFL 的映射
        */
        maskIconView.translatesAutoresizingMaskIntoConstraints = false
        let cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[v]-0-|", options: [], metrics: nil, views: ["v": maskIconView])
        // 调试 VFL 的技巧
        addConstraints(cons)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[v]-(-35)-[regButton]", options: [], metrics: nil, views: ["v": maskIconView, "regButton": registerButton]))
        
        // 设置背景颜色 - 灰度图 r = g = b 
        // 提高程序效率的一个细节，如果能够用颜色表示，就不要用图片
        backgroundColor = UIColor(white: 237.0 / 255.0, alpha: 1.0)
    }
    
    // MARK: - 懒加载控件 -> 负责创建控件
    // 图标
    private lazy var iconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_smallicon"))
    // 小房子
    private lazy var homeIconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
    // 遮罩视图 － 不要使用 maskView
    private lazy var maskIconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))
    // 消息文字
    private lazy var messageLabel: UILabel = {
        let label = UILabel()

        label.text = "关注一些人，回这里看看有什么惊喜关注一些人，回这里看看有什么惊喜"
        // 一般不要使用纯黑色
        label.textColor = UIColor.darkGrayColor()
        label.font = UIFont.systemFontOfSize(14)
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        
        return label
    }()
    // 注册按钮
    lazy var registerButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("注册", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        button.setBackgroundImage(UIImage(named: "common_button_white_disable"), forState: UIControlState.Normal)
        
        return button
    }()
    // 登录按钮
    lazy var loginButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("登录", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        button.setBackgroundImage(UIImage(named: "common_button_white_disable"), forState: UIControlState.Normal)
        
        return button
    }()

}
