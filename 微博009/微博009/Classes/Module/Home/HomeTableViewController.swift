//
//  HomeTableViewController.swift
//  微博009
//
//  Created by Romeo on 15/8/31.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import SVProgressHUD

/// MVVM 中控制器/视图不能直接引用模型
class HomeTableViewController: BaseTableViewController {

    /// 微博列表数据模型
    private lazy var statusListViewModel = StatusListViewModel()
    /// Modal动画提供者
    private lazy var photoBrowserAnimator = PhotoBrowserAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !UserAccountViewModel.sharedUserAccount.userLogon {
            visitorView?.setupInfo(nil, message: "关注一些人，回这里看看有什么惊喜")
            
            return
        }
        
        // 注册通知
        /**
            1. 通知`名`
            2. 对象，监听`发送通知`的对象，如果是 nil，监听所有发送该通知的对象
            3. 队列，调度 block 的队列，如果是 nil，在主线程调度 block 执行
            4. block：接收到通知执行的方法
        
            * 目前 iOS 开发中，更多的人喜欢用 block，所有的代码写在一起！
        
            使用 通知的 block 有陷阱，只要使用 self. 一定会循环引用！
        */
        NSNotificationCenter.defaultCenter().addObserverForName(HMStatusPictureViewSelectedPhotoNotification, object: nil, queue: nil) { [weak self] (notification) -> Void in
            
            /// 检查通知中的 userInfo
            guard let urls = notification.userInfo![HMStatusPictureViewSelectedPhotoURLsKey] as? [NSURL] else {
                return
            }
            guard let indexPath = notification.userInfo![HMStatusPictureViewSelectedPhotoIndexPathKey] as? NSIndexPath else {
                return
            }
            // 获取图片视图的对象
            guard let picView = notification.object as? StatusPictureView else {
                return
            }
            
            // Modal 展现，默认会将上级视图移除
            let vc = PhotoBrowserViewController(urls: urls, indexPath: indexPath)
            
            // 以下两句代码能够保证 Modal 之后，源视图控制器不会从屏幕上移除
            // 1. 指定动画的提供者 transitioning - 转场，从一个界面跳转到另外一个界面的动画效果
            vc.transitioningDelegate = self?.photoBrowserAnimator
            // 2. 指定 modal 展现样式是自定义的
            vc.modalPresentationStyle = UIModalPresentationStyle.Custom
            // 3. 计算位置
            let fromRect = picView.screenRect(indexPath)
            let toRect = picView.fullScreenRect(indexPath)
            
            self?.photoBrowserAnimator.prepareAnimator(picView, fromRect: fromRect, toRect: toRect, url: urls[indexPath.item])
            
            self?.presentViewController(vc, animated: true, completion: nil)
        }
        
        prepareTableView()
        
        loadData()
    }
    
    deinit {
        printLog("88")
        // 销毁通知
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func prepareTableView() {
        // 注册可重用 cell
        tableView.registerClass(StatusForwardCell.self, forCellReuseIdentifier: HMStatusForwardCellID)
        tableView.registerClass(StatusNormalCell.self, forCellReuseIdentifier: HMStatusNormalCellID)
        // 提示：如果不使用自动计算行高，UITableViewAutomaticDimension，一定不要设置底部约束
        tableView.estimatedRowHeight = 300
        // 取消分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // 准备下拉刷新控件 － 刷新控件的高度是 60 点
        refreshControl = HMRefreshControl()
        refreshControl?.addTarget(self, action: "loadData", forControlEvents: UIControlEvents.ValueChanged)
        
        // 上拉提示控件
        tableView.tableFooterView = pullupView
    }
    
    /// 加载数据
    func loadData() {
        // beginRefreshing只会播放刷新动画，不会加载数据
        refreshControl?.beginRefreshing()
        
        statusListViewModel.loadStatuses(isPullupRefresh: pullupView.isAnimating()).subscribeNext({ (result) -> Void in
            // 使用 RAC 传递的数值，是一 NSNumber 形式传递的
            let count = (result as! NSNumber).integerValue
            
            self.showPulldownTips(count)
            
            }, error: { (error) -> Void in
                self.endLoadData()
                
                printLog(error)
                SVProgressHUD.showInfoWithStatus("您的网络不给力")
            }) {
                self.endLoadData()
                
                // 刷新表格
                self.tableView.reloadData()
        }
    }
    
    /// 显示下拉条数提示
    ///
    /// - parameter count: 下拉的条数
    /// 提示：NavBar, TabBar, ToolBar 不能使用自动布局
    /// 不要疯狂下拉刷新！一旦 403 可以更换 App ID
    private func showPulldownTips(count: Int) {

        let title = count == 0 ? "没有新微博" : "刷新到 \(count) 条微博"
        let height: CGFloat = 44
        let rect = CGRect(x: 0, y: -2 * height, width: UIScreen.mainScreen().bounds.width, height: height)
        
        pulldownTipLabel.text = title
        pulldownTipLabel.frame = rect
        
        UIView.animateWithDuration(1.2, animations: {
            
            self.pulldownTipLabel.frame = CGRectOffset(rect, 0, 3 * height)
            
            }) { (_) -> Void in
                UIView.animateWithDuration(1.2) { self.pulldownTipLabel.frame = rect }
        }
    }
    
    /// 结束刷新数据
    private func endLoadData() {
        // 关闭刷新控件
        self.refreshControl?.endRefreshing()
        // 关闭上拉刷新动画
        self.pullupView.stopAnimating()
    }
    
    // MARK: - 懒加载控件
    /// 下拉提示标签
    private lazy var pulldownTipLabel: UILabel = {

        let label = UILabel(title: nil, color: UIColor.whiteColor(), fontSize: 18)
        label.backgroundColor = UIColor.orangeColor()
        label.textAlignment = NSTextAlignment.Center
        
        self.navigationController?.navigationBar.insertSubview(label, atIndex: 0)
        
        return label
    }()
    /// 上拉刷新视图
    private lazy var pullupView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        indicator.color = UIColor.darkGrayColor()

        return indicator
    }()
}

// 类似于 OC 的分类，同时可以将遵守的协议方法，分离出来
extension HomeTableViewController {
    
    // 1. 数据行数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusListViewModel.statuses.count
    }
    
    // 2. 表格 cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 1. 获取微博数据
        let viewModel = statusListViewModel.statuses[indexPath.row]
        
        // 2. 取可重用 cell
        let cell = tableView.dequeueReusableCellWithIdentifier(viewModel.cellID, forIndexPath: indexPath) as! StatusCell
        
        // 3. 设置数据
        cell.statusViewModel = viewModel
        
        // 4. 判断当前的 indexPath 是否是数组的最后一项，如果是，开始上拉动画
        if (indexPath.row == statusListViewModel.statuses.count - 1) && !pullupView.isAnimating() {
            printLog("显示上拉视图...")
            pullupView.startAnimating()
            // 开始刷新数据
            loadData()
        }
        
        // 5. 设置 cell 的代理
        cell.cellDelegate = self
        
        // 6. 返回 cell
        return cell
    }
    
    /**
        默认情况下，会计算所有行的行高，原因：UITableView继承自 UIScrollView
        UIScrollView 的滚动依赖于 contentSize -> 把所有行高都计算出来，才能准确的知道 contentSize
        
        如果设置了预估行高，会根据预估行高，来计算需要显示行的尺寸！
    
        提示：如果行高是固定的，千万不要实现此代理方法！行高的代理方法，在每个版本的 Xcode 和 iOS 模拟器上执行的频率都不一样
    
        苹果在底层一直在做优化！
    
        需要行高的缓存！`只计算一次！有一个地方能够记录当前的行高！`
    */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // 0. 获得模型
        let viewModel = statusListViewModel.statuses[indexPath.row]
        
        // 1. 判断视图模型的行高是否为0，如果不为0，表示行高已经缓存
        if viewModel.rowHeight > 0 {
            return viewModel.rowHeight
        }
        
        // 2. 获得 cell，不能使用 indexPath 的方法，否则会出现死循环
        let cell = tableView.dequeueReusableCellWithIdentifier(viewModel.cellID) as! StatusCell
        
        // 3. 记录行高
        viewModel.rowHeight = cell.rowHeight(viewModel)
        
        return viewModel.rowHeight
    }
}

extension HomeTableViewController: StatusCellDelegate {
    func statusCellDidClickURL(url: NSURL) {
        let vc = HomeWebViewController()
        
        vc.url = url
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
}