//
//  NewFeatureViewController.swift
//  微博009
//
//  Created by Romeo on 15/9/4.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 可重用表示符号
private let HMNewFeatureCellID = "HMNewFeatureCellID"
/// 新特性图片数量
private let HMNewFeatureCount = 4

class NewFeatureViewController: UICollectionViewController {

    // 实现 init() 构造函数，方便外部的代码调用，不需要额外指定布局属性
    init() {
        // 调用父类的默认构造函数
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 注册可重用 cell
        self.collectionView!.registerClass(NewFeatureCell.self, forCellWithReuseIdentifier: HMNewFeatureCellID)
        
        prepareLayout()
    }
    
    /// 1. 准备布局
    private func prepareLayout() {
        // 获得当前的布局属性
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = view.bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView?.pagingEnabled = true
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HMNewFeatureCount
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HMNewFeatureCellID, forIndexPath: indexPath) as! NewFeatureCell
    
        // Configure the cell
        cell.imageIndex = indexPath.item
    
        return cell
    }
    
    // indexPath 参数是之前显示的 cell 的 indexPath
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        // 取当前显示 cell 的 indexPath
        let path = collectionView.indexPathsForVisibleItems().last!
        
        // 判断是否是最后一个
        if path.item == HMNewFeatureCount - 1 {
            // 获取cell
            let cell = collectionView.cellForItemAtIndexPath(path) as! NewFeatureCell
            cell.showStartButton()
        }
    }
}

/// 新特性 Cell，private保证 cell 只被当前控制器使用，在当前文件中，所有的 private 都是摆设！
private class NewFeatureCell: UICollectionViewCell {
    
    /// 图像索引属性
    private var imageIndex: Int = 0 {
        didSet {
            iconView.image = UIImage(named: "new_feature_\(imageIndex + 1)")
            startButton.hidden = true
        }
    }
    
    /// 点击开始按钮，如果类是 private 的，即使没有对方法进行修饰，运行循环同样无法调用监听方法
    @objc func clickStartButton() {
        NSNotificationCenter.defaultCenter().postNotificationName(HMSwitchRootViewControllerNotification, object: nil)
    }
    
    /// 动画显示启动按钮
    private func showStartButton() {
        startButton.hidden = false
        
        startButton.transform = CGAffineTransformMakeScale(0, 0)
        
        // Damping 弹性系数，0~1，越小越弹
        // Velocity: 初始速度
        UIView.animateWithDuration(1.2, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: [], animations: { () -> Void in
            
            self.startButton.transform = CGAffineTransformIdentity
            }) { (_) -> Void in
                
        }
    }
    
    /// frame 的大小来自于 layout 的 itemSize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    /// 设置界面元素
    private func setupUI() {
        printLog(bounds)
        
        // 1. 添加控件
        addSubview(iconView)
        addSubview(startButton)
        
        // 2. 指定布局
        iconView.frame = bounds
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 自动布局的约束是添加在父视图上的
        addConstraint(NSLayoutConstraint(item: startButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: startButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -160))
    }
    
    // MARK: - 懒加载属性
    /// 图像视图
    private lazy var iconView = UIImageView()
    /// 开始体验按钮
    private lazy var startButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("开始体验", forState: UIControlState.Normal)
        button.setBackgroundImage(UIImage(named: "new_feature_finish_button"), forState: UIControlState.Normal)
        button.setBackgroundImage(UIImage(named: "new_feature_finish_button_highlighted"), forState: UIControlState.Highlighted)
        
        button.sizeToFit()
        
        button.addTarget(self, action: "clickStartButton", forControlEvents: UIControlEvents.TouchUpInside)
        
        return button
    }()
}
