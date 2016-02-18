//
//  HMRefreshControl.swift
//  微博009
//
//  Created by Romeo on 15/9/8.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 向下拖拽的偏移量，超过 -60 旋转箭头
private let HMRefreshControlMaxOffset: CGFloat = -60

/// 刷新控件，负责和控制器交互
class HMRefreshControl: UIRefreshControl {

    /// 停止刷新
    override func endRefreshing() {
        super.endRefreshing()
        
        // 停止动画
        refreshView.stopAnimation()
    }    
    
    // MARK: - KVO 监听方法
    // 监听对象的 key value 一旦变化，就会调用此方法
    /**
        越向下 y 越小，小到一定程度，自动进入刷新状态
        越向上推动表格，y值越大，刷新控件始终在视图上
    */
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if frame.origin.y > 0 {
            return
        }
        
        // 判断是否正在刷新
        if refreshing {
            refreshView.loadingAnimation()
            return
        }
        
        if frame.origin.y < HMRefreshControlMaxOffset && !refreshView.rotateFlag {
            print("反过来")
            refreshView.rotateFlag = true
        } else if frame.origin.y >= HMRefreshControlMaxOffset && refreshView.rotateFlag {
            print("转过去")
            refreshView.rotateFlag = false
        }
    }
    
    // MARK: - 构造函数
    override init() {
        super.init()
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        setupUI()
    }
    
    deinit {
        // 销毁监听
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    private func setupUI() {
        // KVO － self 监听 self.frame
        self.addObserver(self, forKeyPath: "frame", options: [], context: nil)
        
        // 隐藏转轮
        tintColor = UIColor.clearColor()
        
        addSubview(refreshView)
        
        // 自动布局 － 从 XIB 加载的视图会保留 XIB 中指定的大小
        refreshView.ff_AlignInner(type: ff_AlignType.CenterCenter, referView: self, size: refreshView.bounds.size)
    }
    
    // MARK: - 懒加载控件
    private lazy var refreshView = HMRefreshView.refreshView()

}

/// 刷新视图，单独负责显示内容&动画
class HMRefreshView: UIView {
    
    /// 旋转标记
    private var rotateFlag = false {
        didSet {
            rotateTipAnimation()
        }
    }
    
    /// 加载图标
    @IBOutlet weak var loadingIcon: UIImageView!
    /// 提示视图
    @IBOutlet weak var tipView: UIView!
    /// 下拉提示图标
    @IBOutlet weak var pulldownTipIcon: UIImageView!
    
    /// 负责从 XIB 加载视图
    class func refreshView() -> HMRefreshView {
        return NSBundle.mainBundle().loadNibNamed("HMRefreshView", owner: nil, options: nil).last! as! HMRefreshView
    }
    
    /// 旋转提示图标动画
    private func rotateTipAnimation() {
        
        var angle = CGFloat(M_PI)
        angle += rotateFlag ? -0.01 : 0.01
        
        // 在 iOS 的 block 动画中，旋转是默认顺时针，就近原则
        UIView.animateWithDuration(0.5) {
            self.pulldownTipIcon.transform = CGAffineTransformRotate(self.pulldownTipIcon.transform, angle)
        }
    }
    
    /// 加载动画
    private func loadingAnimation() {
        
        // 通过 key 能够拿到图层上的动画
        let loadingKey = "loadingKey"
        if loadingIcon.layer.animationForKey(loadingKey) != nil {
            return
        }
        
        tipView.hidden = true
        
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        
        anim.toValue = 2 * M_PI
        anim.repeatCount = MAXFLOAT
        anim.duration = 1
        
        loadingIcon.layer.addAnimation(anim, forKey: loadingKey)
    }
    
    /// 停止动画
    private func stopAnimation() {
        tipView.hidden = false
        
        loadingIcon.layer.removeAllAnimations()
    }
}

