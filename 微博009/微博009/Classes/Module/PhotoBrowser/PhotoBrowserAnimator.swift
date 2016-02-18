//
//  PhotoBrowserAnimator.swift
//  Weibo09
//
//  Created by Romeo on 15/9/14.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import SDWebImage

/// 专门提供从控制器向照片浏览器的 Modal `转场`动画的对象
class PhotoBrowserAnimator: NSObject, UIViewControllerTransitioningDelegate {
    
    /// 是否展现的标记
    var isPresented = false
    /// 起始位置
    var fromRect = CGRectZero
    /// 目标位置
    var toRect = CGRectZero
    /// 图像视图的 URL
    var url: NSURL?
    /// 动画播放的图像视图
    lazy var imageView: HMProgressImageView = {
        let iv = HMProgressImageView()
        
        iv.contentMode = UIViewContentMode.ScaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    /// 首页视图控制器中的配图视图 - 本质上 HomeVC 的 Cell 对其进行强引用
    weak var picView: StatusPictureView?
    
    /// 准备动画参数
    ///
    /// - parameter picView:  Cell中的配图视图
    /// - parameter fromRect: fromRect
    /// - parameter toRect:   toRect
    /// - parameter url:      url
    func prepareAnimator(picView: StatusPictureView, fromRect: CGRect, toRect: CGRect, url: NSURL) {
        self.picView = picView
        self.fromRect = fromRect
        self.toRect = toRect
        self.url = url
    }
    
    /// 返回提供展现 present 转场动画的对象
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresented = true
        
        return self
    }

    /// 返回提供解除 dismiss 转场动画的对象
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresented = false
        
        return self
    }
}

// MARK: - UIViewControllerAnimatedTransitioning - 转场动画协议 - 专门提供专场动画的实现细节
extension PhotoBrowserAnimator: UIViewControllerAnimatedTransitioning {
    
    /// 返回专场动画时长
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 2
    }
    
    /// 专门实现转场动画效果 - 一旦实现了此方法，程序员必须完成动画效果
    ///
    /// - parameter transitionContext: transition[转场]Context[上下文] 提供了转场动画所需的一切细节
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        printLog(fromVC)
        printLog(toVC)
        
        isPresented ? presentAnim(transitionContext) : dismissAnim(transitionContext)
    }
    
    /// 实现解除专场动画
    ///
    /// - parameter transitionContext: 上下文
    private func dismissAnim(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! PhotoBrowserViewController
        // 通过控制器获得内部的 imageView
        let imageView = fromVC.currentImageView
        let indexPath = fromVC.currentImageIndex
        
        // 拿到被展现的视图 - fromView
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        // 直接将 fromView 从容器视图中移除
        fromView.removeFromSuperview()
        
        // 将图像视图添加到容器视图中
        transitionContext.containerView()?.addSubview(imageView)
        // 设置 imageView 的位置
        imageView.center = fromView.center
        // 叠加 imageView 的形变参数 － 将 fromVC 的 view 的缩放形变叠加到 imageView 上
        let scale = fromVC.view.transform.a
        imageView.transform = CGAffineTransformScale(imageView.transform, scale, scale)
        imageView.alpha = scale
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
            
            // 单纯修改最外侧的 view 的 frame 无法达到预期的效果
            imageView.frame = self.picView!.screenRect(indexPath)
            imageView.alpha = 1.0
            
            }, completion: { (_) -> Void in
                
                // 将视图从容器视图中删除
                imageView.removeFromSuperview()
                
                // 动画完成
                transitionContext.completeTransition(true)
        })
    }
    
    /// 实现 Modal 展现动画
    ///
    /// - parameter transitionContext: 上下文
    private func presentAnim(transitionContext: UIViewControllerContextTransitioning) {
        
        // 1. 将 imageView 添加的 容器视图
        transitionContext.containerView()?.addSubview(imageView)
        imageView.frame = fromRect
        
        // 2. 用 sdwebImage 异步下载图像
        /**
            sd_setImageWithURL
            1> 如果图片已经被缓存，不会再次下载
            2> 如果要跟进进度，都是`异步`回调
                原因：
                a) 一般程序不会跟踪进度
                b) 进度回调的频率相对较高
                异步回调，能够降低对主线程的压力
        */
        imageView.sd_setImageWithURL(url, placeholderImage: nil, options: [SDWebImageOptions.RetryFailed], progress: { (current, total) -> Void in
            
            // 设置进度 - 计算下载进度
            dispatch_async(dispatch_get_main_queue()) {
                self.imageView.progress = CGFloat(current) / CGFloat(total)
            }
            
            }) { (_, error, _, _) in
                
                // 判断是否有错误
                if error != nil {
                    printLog(error, logError: true)
                    
                    // 声明动画结束 － 参数为 false 容器视图不会添加，转场失败
                    transitionContext.completeTransition(false)
                    
                    return
                }
                
                // 3. 图像下载完成之后，再显示动画
                UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
                    
                    self.imageView.frame = self.toRect
                    
                    }, completion: { (_) -> Void in
                        // 将目标视图添加到容器视图
                        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
                        transitionContext.containerView()?.addSubview(toView)
                        
                        // 将 imageView 从界面上删除
                        self.imageView.removeFromSuperview()
                        
                        // 声明动画完成
                        transitionContext.completeTransition(true)
                })
        }
    }
}
