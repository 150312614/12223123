//
//  ComposeViewController.swift
//  微博009
//
//  Created by Romeo on 15/9/10.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import SVProgressHUD

/// 发布微博的最大长度
private let HMStatusTextMaxLength = 10

/// 撰写微博控制器
class ComposeViewController: UIViewController, UITextViewDelegate {

    // MARK: - 表情键盘
    /// 表情键盘控制器 － 注意：如果闭包中调用 self. 函数，同样会做 copy，需要注意循环引用
    private lazy var keyboardVC: EmoticonViewController = EmoticonViewController { [weak self] (emoticon) -> () in
        print(emoticon.chs)
        self?.textView.insertEmoticon(emoticon)
    }
    
    /// 切换表情键盘
    @objc private func switchEmoticonKeyboard() {
        // inputView == nil，表示使用的系统键盘
        printLog(textView.inputView)
        
        // 注销焦点
        textView.resignFirstResponder()
        
        // 切换键盘
        textView.inputView = (textView.inputView == nil) ? keyboardVC.view : nil
        
        // 激活焦点
        textView.becomeFirstResponder()
    }
    
    // MARK: - 控件动画约束
    /// 工具栏底部约束
    private var toolbarBottomCons: NSLayoutConstraint?
    /// 文本视图底部约束
    private var textViewBottomCons: NSLayoutConstraint?
    /// 照片选择视图的高度约束
    private var pictureViewHeightCons: NSLayoutConstraint?
    
    // MARK: - 监听方法
    @objc private func close() {
        // 关闭键盘
        textView.resignFirstResponder()
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    /// 发送微博
    @objc private func sendStatus() {
        
        // 1. 获取带表情符号的文本字符串
        let text = textView.emoticonText
        
        // 2. 判断文本长度
        if text.characters.count > HMStatusTextMaxLength {
            SVProgressHUD.showInfoWithStatus("输入的内容过长", maskType: .Gradient)
            
            return
        }
        
        // 3. 发送微博
        NetworkTools.sharedTools.sendStatus(text, image: pictureSelectorVC.pictures.last).subscribeNext({ (result) -> Void in
            // 刚刚发送成功的微博数据字典
            printLog(result)
            
            }, error: { (error) -> Void in
                printLog(error)
                SVProgressHUD.showInfoWithStatus("您的网络不给力")
            }) { () -> Void in
                self.close()
        }
    }
    
    /// 选择照片
    @objc private func selectPicture() {
        printLog("选择照片")
        
        // 1. 删除文本视图和 toolbar 之间的约束
        view.removeConstraint(textViewBottomCons!)
        
        // 2. 设置文本视图和照片视图之间的约束
        textViewBottomCons = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: pictureSelectorVC.view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        view.addConstraint(textViewBottomCons!)
        
        // 3. 设置高度约束
        pictureViewHeightCons?.constant = UIScreen.mainScreen().bounds.height * 0.6
        
        // 4. 关闭键盘
        textView.resignFirstResponder()
        
        // 5. 动画更新约束
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = textView.hasText()
        navigationItem.rightBarButtonItem?.enabled = textView.hasText()
        
        // 修改文字长度提示
        let len = HMStatusTextMaxLength - textView.emoticonText.characters.count
        
        lengthTipLabel.text = String(len)
        lengthTipLabel.textColor = len >= 0 ? UIColor.lightGrayColor() : UIColor.redColor()
    }
    
    // MARK: - 视图生命周期函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 注册键盘通知 - UIWindow.h 中的倒数第二个
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChanged:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        // 注销通知
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /// 键盘变化监听方法
    @objc private func keyboardChanged(n: NSNotification) {
        printLog(n)
        
        // 获取动画曲线数值 － 7 苹果没有提供文档
        // 如果将动画曲线设置为 7，有两个特点
        // 1. 在连续的动画过程中，前一个动画如果没有执行完毕，直接过渡到最后一个动画
        // 2. 使用 7 之后，动画时长一律变成 0.5 秒
        let curve = n.userInfo![UIKeyboardAnimationCurveUserInfoKey]!.integerValue
        
        // 获取最终的frame － OC 中将结构体保存在字典中，存成 NSValue
        let rect = n.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        // 获取动画时长
        let duration = n.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        
        toolbarBottomCons?.constant = -UIScreen.mainScreen().bounds.height + rect.origin.y
        
        // UIView 的块动画，本质上是对`核心动画`的封装
        // 核心概念
        // 1. 通过 keyPath 来指定可动画属性的数值
        // 2. 将动画添加到`图层`
        UIView.animateWithDuration(duration) {
            // 设置动画曲线
             UIView.setAnimationCurve(UIViewAnimationCurve.init(rawValue: curve)!)
            
            self.view.layoutIfNeeded()
        }
        
        // 调试动画
        let anim = toolbar.layer.animationForKey("position")
        printLog("动画时长 \(anim?.duration)")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // 判断如果用户已经选择了照片，就不再激活键盘，> 0 说明已经选择了照片
        if pictureViewHeightCons?.constant == 0 {
            // 激活键盘
            textView.becomeFirstResponder()
        }
    }
    
    // MARK: - 创建界面
    /// 专门来创建界面的函数
    override func loadView() {
        
        view = UIView()

        // 将自动调整 scrollView 的缩进取消
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = UIColor.whiteColor()

        prepareNav()
        prepareToolBar()
        prepareTextView()
        preparePictureView()
    }

    /// 准备照片视图
    private func preparePictureView() {
        // 0. 添加子控制器 － 提示：实际开发中发现响应者链条无法正常传递，通常就是忘记添加子控制器
        // storyboard 中有一个 containerView，纯代码中没有这个控件
        // 本质上就是一个 UIView
        // 1> addSubView(vc.view)
        // 2> addChildViewController(vc)
        addChildViewController(pictureSelectorVC)
        
        // 1. 添加视图
        view.insertSubview(pictureSelectorVC.view, belowSubview: toolbar)
        
        // 2. 自动布局
        let size = UIScreen.mainScreen().bounds.size
        let w = size.width
        let h: CGFloat = 0 //size.height * 0.6
        let cons = pictureSelectorVC.view.ff_AlignInner(type: ff_AlignType.BottomLeft, referView: view, size: CGSize(width: w, height: h))
        // 记录照片视图的高度约束
        pictureViewHeightCons = pictureSelectorVC.view.ff_Constraint(cons, attribute: NSLayoutAttribute.Height)
    }
    
    /// 设置文本视图
    private func prepareTextView() {
        view.addSubview(textView)
        
        // 测试占位视图的位置
        // textView.text = "分享新鲜事..."
        
        // 自动布局
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        // topLayoutGuide 能够自动判断顶部的控件(状态栏/navbar)
        let viewDict: [String : AnyObject] = ["top": topLayoutGuide, "tb": toolbar, "tv": textView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[tv]-0-|", options: [], metrics: nil, views: viewDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[top]-0-[tv]", options: [], metrics: nil, views: viewDict))
        
        // 定义 textView 和 toolbar 之间的约束
        textViewBottomCons = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: toolbar, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        view.addConstraint(textViewBottomCons!)
        
        // 设置占位标签 － 添加到 textView 就是为了保证能够同时滚动
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame = CGRect(origin: CGPoint(x: 5, y: 8), size: placeholderLabel.bounds.size)
        
        // 设置长度提示标签 - textView 继承自 UIScrollView，添加自动约束相当的麻烦
        // 注意：添加到 view 上
        view.addSubview(lengthTipLabel)
        lengthTipLabel.ff_AlignInner(type: ff_AlignType.BottomRight, referView: textView, size: nil, offset: CGPoint(x: -HMStatusCellMargin, y: -HMStatusCellMargin))
    }
    
    /// 设置工具栏
    private func prepareToolBar() {
        view.addSubview(toolbar)
        
        // 设置背景颜色
        toolbar.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        
        // 设置自动布局
        let w = UIScreen.mainScreen().bounds.width
        let cons = toolbar.ff_AlignInner(type: ff_AlignType.BottomLeft, referView: view, size: CGSize(width: w, height: 44))
        // 记录底部约束
        toolbarBottomCons = toolbar.ff_Constraint(cons, attribute: NSLayoutAttribute.Bottom)
        // 确认获得约束
        printLog(toolbarBottomCons)
        
        // 定义按钮数组
        let itemSettings = [["imageName": "compose_toolbar_picture", "action": "selectPicture"],
            ["imageName": "compose_mentionbutton_background"],
            ["imageName": "compose_trendbutton_background"],
            ["imageName": "compose_emoticonbutton_background", "action": "switchEmoticonKeyboard"],
            ["imageName": "compose_addbutton_background"]]
        
        // 添加按钮
        var items = [UIBarButtonItem]()
        
        for dict in itemSettings {
            items.append(UIBarButtonItem(imageName: dict["imageName"]!, target: self, actionName: dict["action"]))
            
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        
        toolbar.items = items
    }
    
    /// 设置导航栏
    private func prepareNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "close")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发送", style: UIBarButtonItemStyle.Plain, target: self, action: "sendStatus")
        // 禁用发送按钮
        navigationItem.rightBarButtonItem?.enabled = false
        
        // 标题视图
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 32))
        
        let titleLabel = UILabel(title: "发微博", color: UIColor.darkGrayColor(), fontSize: 15)
        let nameLabel = UILabel(title: UserAccountViewModel.sharedUserAccount.userAccount?.name, color: UIColor.lightGrayColor(), fontSize: 13)
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(nameLabel)
        
        titleLabel.ff_AlignInner(type: ff_AlignType.TopCenter, referView: titleView, size: nil)
        nameLabel.ff_AlignInner(type: ff_AlignType.BottomCenter, referView: titleView, size: nil)
        
        navigationItem.titleView = titleView
    }
    
    // MARK: - 懒加载控件
    /// 文本视图
    private lazy var textView: UITextView = {
       
        let tv = UITextView()
        
        // 设置代理
        tv.delegate = self
        
        tv.font = UIFont.systemFontOfSize(18)
        tv.textColor = UIColor.darkGrayColor()
        
        // 允许垂直拖拽
        tv.alwaysBounceVertical = true
        // 拖拽关闭键盘
        tv.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag

        return tv
    }()
    /// 占位标签
    private lazy var placeholderLabel: UILabel = UILabel(title: "分享新鲜事...", color: UIColor.lightGrayColor(), fontSize: 18)
    /// 长度提示标签
    private lazy var lengthTipLabel: UILabel = UILabel(title: nil, color: UIColor.lightGrayColor(), fontSize: 12)
    
     /// 工具栏
    private lazy var toolbar = UIToolbar()
    /// 照片选择控制器
    private lazy var pictureSelectorVC = PictureSelectorViewController()
}
