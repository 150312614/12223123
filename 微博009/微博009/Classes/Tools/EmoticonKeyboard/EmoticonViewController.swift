//
//  EmoticonViewController.swift
//  01-表情键盘
//
//  Created by Romeo on 15/9/11.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 可重用标识符
private let EmoticonCellID = "EmoticonCellID"

/// 表情键盘控制器 - 系统键盘的默认高度 216
class EmoticonViewController: UIViewController {

    /// 选中表情的闭包回调
    var selectedEmoticonCallBack: (emoticon: Emoticon)->()
    
    init(selectedEmoticon: (emoticon: Emoticon)->()) {
        selectedEmoticonCallBack = selectedEmoticon
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 监听方法
    @objc private func clickItem(item: UIBarButtonItem) {
        let indexPath = NSIndexPath(forRow: 0, inSection: item.tag)
        
        // 让 collectionView 滚动到对应位置
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.redColor()
        
        setupUI()
    }

    /// MARK: - 设置界面
    private func setupUI() {
        // 1. 添加控件
        view.addSubview(collectionView)
        view.addSubview(toolbar)
        
        // 2. 自动布局
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDict = ["tb": toolbar, "cv": collectionView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[cv]-0-|", options: [], metrics: nil, views: viewDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[tb]-0-|", options: [], metrics: nil, views: viewDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[cv]-[tb(44)]-0-|", options: [], metrics: nil, views: viewDict))
        
        // 3. 准备控件
        prepareToolbar()
        prepareCollectionView()
    }
    
    /// 准备工具栏
    private func prepareToolbar() {
        toolbar.tintColor = UIColor.darkGrayColor()
        
        var items = [UIBarButtonItem]()
        
        // 通常用 tag 来区别 toolbar 上的按钮，一组相近，而且是顺序的操作
        var index = 0
        
        for p in viewModel.packages {
            items.append(UIBarButtonItem(title: p.group_name_cn, style: UIBarButtonItemStyle.Plain, target: self, action: "clickItem:"))
            items.last?.tag = index++
            
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        
        toolbar.items = items
    }

    /// 准备 collectionView
    private func prepareCollectionView() {
        
        // 0. 背景颜色
        collectionView.backgroundColor = UIColor.whiteColor()
        
        // 1. 注册cell
        collectionView.registerClass(EmoticonCell.self, forCellWithReuseIdentifier: EmoticonCellID)
        
        // 2. 指定数据源 & 代理
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - 懒加载控件
    /// 工具栏
    private lazy var toolbar = UIToolbar()
    /// collectionView
    private lazy var collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: EmoticonLayout())
    /// 表情包的视图模型 - 可以对代码做最小的修改
    private lazy var viewModel = EmoticonViewModel.sharedViewModel
}

/// 表情键盘的布局
private class EmoticonLayout: UICollectionViewFlowLayout {
    
    /// 准备布局，第一次使用的时候会被调用 － collectionView 的大小已经确定(已经完成自动布局)
    /// 准备布局方法，会在数据源(cell 的个数)前调用，可以在此准备 layout 的属性
    private override func prepareLayout() {
        
        super.prepareLayout()

        let w = collectionView!.bounds.width / 7
        // iPhone 5 如果用 0.5 会每页显示两行，因为浮点数的原因，计算会有偏差！
        let margin = (collectionView!.bounds.height - 3 * w) * 0.499
        
        itemSize = CGSize(width: w, height: w)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        
        sectionInset = UIEdgeInsets(top: margin, left: 0, bottom: margin, right: 0)
        
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView?.pagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
    }
}

// MARK: - UICollectionViewDataSource
extension EmoticonViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    /// 分组数量
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return viewModel.packages.count
    }
    
    /// 每个 section 对应表情包中包涵的表情数量
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.packages[section].emoticons.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(EmoticonCellID, forIndexPath: indexPath) as! EmoticonCell
        
        // 设置表情索引
        cell.emoticon = viewModel.emoticon(indexPath)
        
        return cell
    }
    
    /// 选中cell的代理方法
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // 执行闭包回调
        selectedEmoticonCallBack(emoticon: viewModel.emoticon(indexPath))
        // 添加最近表情符号
        viewModel.favorite(indexPath)
        // 刷新 collectionView 第0组 
        // 用户体验不好：会闪动/表情会变化位置
        // collectionView.reloadSections(NSIndexSet(index: 0))
    }
}

/// 表情 Cell
private class EmoticonCell: UICollectionViewCell {
    
    /// 表情模型
    var emoticon: Emoticon? {
        didSet {
            // 以下两个清空的动作，能够解决重用的问题
            // 1. 图片 - 如果没有会清空图片
            emoticonButton.setImage(UIImage(contentsOfFile: emoticon!.imagePath), forState: UIControlState.Normal)
            
            // 2. emoji － 如果没有会清空文字
            emoticonButton.setTitle(emoticon!.emoji, forState: UIControlState.Normal)
            
            // 3. 删除按钮
            if emoticon!.isRemove {
                emoticonButton.setImage(UIImage(named: "compose_emotion_delete"), forState: UIControlState.Normal)
                emoticonButton.setImage(UIImage(named: "compose_emotion_delete_highlighted"), forState: UIControlState.Highlighted)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emoticonButton)
        emoticonButton.backgroundColor = UIColor.whiteColor()

        // CGRectInset 返回相同中心点的矩形
        // 一定使用 bounds
        emoticonButton.frame = CGRectInset(bounds, 4, 4)
        // 设置字体
        emoticonButton.titleLabel?.font = UIFont.systemFontOfSize(32)
        // 禁用按钮
        emoticonButton.userInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载控件
    private lazy var emoticonButton: UIButton = UIButton()
}
