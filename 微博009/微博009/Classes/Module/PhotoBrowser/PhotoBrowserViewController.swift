//
//  PhotoBrowserViewController.swift
//  Weibo09
//
//  Created by Romeo on 15/9/14.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import SVProgressHUD

/// 可重用标示符号
private let HMPhotoBrowserCellID = "HMPhotoBrowserCellID"

class PhotoBrowserViewController: UIViewController {

    // MARK: - 控制器属性
    /// 照片 URL 数组
    var urls: [NSURL]
    /// 用户选中照片索引
    var selectedIndexPath: NSIndexPath
    
    /// 当前选中的图像索引
    var currentImageIndex: NSIndexPath {
        return collectionView.indexPathsForVisibleItems().last!
    }
    
    /// 当前选中的图像视图
    var currentImageView: UIImageView {
        let cell = collectionView.cellForItemAtIndexPath(currentImageIndex) as! PhotoBrowserCell
        
        return cell.imageView
    }
    
    // MARK: - 保存图像
    /// 保存当前图像
    @objc private func saveImage() {
        // 1. 获取图像
        // 提示：sdwebimage不一定能够下载到图像
        guard let image = currentImageView.image else {
            SVProgressHUD.showInfoWithStatus("没有图像")
            return
        }
        
        // 2. 保存图像
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    // 判断图像是否保存成功的完成回调方法
    //  - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
    @objc private func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        let message = (error == nil) ? "保存成功" : "保存失败"

        SVProgressHUD.showInfoWithStatus(message)
    }
    
    // MARK: - 构造函数
    /// 构造函数的好处
    /// 1. 简化外部的调用
    /// 2. 可以不使用可选项属性，避免后续的解包问题
    init(urls: [NSURL], indexPath: NSIndexPath) {
        self.urls = urls
        selectedIndexPath = indexPath
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        printLog("浏览器 88")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(urls)
        print(selectedIndexPath)
    }
    
    // 视图完成布局，准备开始显示
    // 开发提示：具体选择哪一个视图生命周期函数，一定要打断点，调试，不要死记硬背！
    // 不同的控制器，viewVC, tableVC, collectionVC 生命周期函数执行的频率不一样，会根据子控件的类型以及个数会受到影响
    // collectionVC 的 viewDidLayoutSubviews 之前的版本调用频率很高！
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // collectionView 滚动到用户选择的图片
        collectionView.scrollToItemAtIndexPath(selectedIndexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
        
        // 分页控件
        pageControl.currentPage = selectedIndexPath.item
    }
    
    // 视图出现 － 会出现图片的跳跃，会先显示第一张，然后再滚动
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        // collectionView 滚动到用户选择的图片
//        collectionView.scrollToItemAtIndexPath(selectedIndexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
//    }
    
    // MARK: - 设置界面
    override func loadView() {
        // 1. 创建全屏的视图（结构体修改属性需要用 var，对象不需要）
        var rect = UIScreen.mainScreen().bounds
        rect.size.width += 20
        
        view = UIView(frame: rect)
        view.backgroundColor = UIColor.blackColor()
        
        // 2. 设置界面
        setupUI()
    }
    
    /// 设置界面细节
    private func setupUI() {
        // 1. 添加控件
        view.addSubview(collectionView)
        view.addSubview(saveButton)
        view.addSubview(closeButton)
        view.addSubview(pageControl)
        
        // 2. 设置布局
        collectionView.frame = view.bounds
        
        // 自动布局
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDict = ["saveButton": saveButton, "closeButton": closeButton]
        // 水平方向
        /**
            自动布局的约束逻辑关系
        
            == 可以省略
            >=
            <=
        */
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[saveButton(==80)]-(>=8)-[closeButton(==80)]-28-|", options: [], metrics: nil, views: viewDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[closeButton(35)]-8-|", options: [], metrics: nil, views: viewDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[saveButton(35)]-8-|", options: [], metrics: nil, views: viewDict))
        
        // 分页控件
        view.addConstraint(NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: -10))
        view.addConstraint(NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -8))
        
        // 3. 准备控件
        prepareCollectionView()
        preparePageControl()
    
        // 4. 监听方法 - RAC 一旦使用 self 同时没有取消信号，一定注意循环引用
        closeButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self] (btn) in
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        saveButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self] (btn) in
            self?.saveImage()
        }
        pageControl.rac_signalForControlEvents(.ValueChanged).subscribeNext { [weak self] (pageControl) in
            let indexPath = NSIndexPath(forItem: pageControl.currentPage, inSection: 0)

            // 滚动到指定索引
            self?.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: true)
        }
    }
    
    // MARK: 准备控件的方法 - swift 的智能提示在闭包中太痛苦
    // 提示：工作中，有很多老代码，会在 viewDidLoad 中加载所有控件，通常都好几百行
    /// 准备分页视图
    private func preparePageControl() {
        // 总页数
        pageControl.numberOfPages = urls.count
        
        // 单页隐藏
        pageControl.hidesForSinglePage = true
        // 颜色
        pageControl.pageIndicatorTintColor = UIColor.whiteColor()
        pageControl.currentPageIndicatorTintColor = UIColor.redColor()
    }
    
    /// 准备 collectionView
    private func prepareCollectionView() {
        // 1. 注册可重用Cell
        collectionView.registerClass(PhotoBrowserCell.self, forCellWithReuseIdentifier: HMPhotoBrowserCellID)
        
        // 2. 数据源
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 3. 设置布局属性
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = view.bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView.pagingEnabled = true
    }
    
    // MARK: - 懒加载控件
    /// 集合视图
    private lazy var collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    /// 保存按钮
    private lazy var saveButton: UIButton = UIButton(title: "保存", fontSize: 14)
    /// 关闭按钮
    private lazy var closeButton: UIButton = UIButton(title: "关闭", fontSize: 14)
    /// 分页控件 － 绝大多数只是用来显示
    /// 交互提示：点左侧，向前，点右侧，向后，不会精准到具体点！
    private lazy var pageControl: UIPageControl = UIPageControl()
    
    /// 照片缩放比例 - Swift 的 extension 中不能包含存储型属性
    private var photoScale: CGFloat = 1
}

// MARK: - UICollectionViewDataSource
extension PhotoBrowserViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // 提示: indexPath 是之前一个 cell 的索引
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        pageControl.currentPage = collectionView.indexPathsForVisibleItems().last?.item ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HMPhotoBrowserCellID, forIndexPath: indexPath) as! PhotoBrowserCell
        
        cell.url = urls[indexPath.item]
        // 指定 cell 的缩放代理
        cell.photoDelegate = self
        
        return cell
    }
}

// MARK: - PhotoBrowserCellDelegate － 照片 Cell 缩放协议
extension PhotoBrowserViewController: PhotoBrowserCellDelegate {
    
    /// 缩放完成
    func photoBrowserCellEndZoom() {
        
        // 如果缩放比例 < 0.8 dismiss
        if photoScale < 0.8 {
            // 一旦调用了 dismiss 会触发 animator 中的 接触转场动画方法
            // 从当前的动画状态继续完成后续的转场动画
            // 交互式转场动画结束，交给系统的转场
            completeTransition(true)
        } else { // 恢复位置
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.view.transform = CGAffineTransformIdentity
                self.view.alpha = 1.0
                }) { _ in
                    // 动画完成后，显示控件
                    self.hideControllers(false)
            }
        }
    }
    
    /// 缩放中
    ///
    /// - parameter scale: 当前的缩放比例
    func photoBrowserCellDidZooming(scale: CGFloat) {
        print(scale)
        
        // 1. 记录缩放比例
        photoScale = scale
        
        // 2. 显示或者隐藏控件
        hideControllers(scale < 1.0)

        // 3. 开始交互转场
        if scale < 1.0 {
            startInteractiveTransition(self)
        } else {
            // 恢复视图的形变参数
            view.transform = CGAffineTransformIdentity
            view.alpha = 1.0
        }
    }
    
    /// 隐藏/显示控件
    private func hideControllers(isHidden: Bool) {
        closeButton.hidden = isHidden
        saveButton.hidden = isHidden
        // 分页控件一旦设置了 hidden，单页隐藏无效
        //pageControl.hidden = isHidden
        pageControl.hidden = (urls.count == 1) ? true : isHidden
        
        view.backgroundColor = isHidden ? UIColor.clearColor() : UIColor.blackColor()
        collectionView.backgroundColor = isHidden ? UIColor.clearColor() : UIColor.blackColor()
    }
}

// MARK: - UIViewControllerInteractiveTransitioning - 交互式转场协议
extension PhotoBrowserViewController: UIViewControllerInteractiveTransitioning {
    
    /// 开始交互式转场
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.view.transform = CGAffineTransformMakeScale(photoScale, photoScale)
        self.view.alpha = photoScale
    }
}

// MARK: - UIViewControllerContextTransitioning - 转场动画上下文协议 - 提供转场动画细节
extension PhotoBrowserViewController: UIViewControllerContextTransitioning {
    
    /// 完成转场动画
    func completeTransition(didComplete: Bool) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func containerView() -> UIView? { return view.superview }

    func isAnimated() -> Bool { return true }
    func isInteractive() -> Bool { return true }
    func transitionWasCancelled() -> Bool { return false }
    func presentationStyle() -> UIModalPresentationStyle { return UIModalPresentationStyle.Custom }

    func updateInteractiveTransition(percentComplete: CGFloat) {}
    func finishInteractiveTransition() {}
    func cancelInteractiveTransition() {}
    
    func viewControllerForKey(key: String) -> UIViewController? { return self }
    func viewForKey(key: String) -> UIView? { return view }
    
    func targetTransform() -> CGAffineTransform { return CGAffineTransformIdentity }

    func initialFrameForViewController(vc: UIViewController) -> CGRect { return CGRectZero }
    func finalFrameForViewController(vc: UIViewController) -> CGRect { return CGRectZero }
}
