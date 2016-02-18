//
//  StatusCell.swift
//  微博009
//
//  Created by Romeo on 15/9/5.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 控件间的间距
let HMStatusCellMargin: CGFloat = 12
/// 头像大小
let HMStatusIconWidth: CGFloat = 35
/// 默认的图片大小
let HMStatusPictureItemWidth: CGFloat = 90
/// 默认的图片间距
let HMStatusPictureItemMargin: CGFloat = 10
/// 每行的最大图片数量
let HMStatusPictureMaxCount: CGFloat = 3
/// 配图视图的最大的尺寸
let HMStatusPictureMaxWidth = HMStatusPictureMaxCount * HMStatusPictureItemWidth + (HMStatusPictureMaxCount - 1) * HMStatusPictureItemMargin

protocol StatusCellDelegate: NSObjectProtocol {
    func statusCellDidClickURL(url: NSURL)
}

/// 微博 Cell
class StatusCell: UITableViewCell {

    weak var cellDelegate: StatusCellDelegate?
    
    /// 微博数据视图模型
    var statusViewModel: StatusViewModel? {
        didSet {
            // 模型数值被设置之后，马上要产生的连锁反应 - 界面UI发生变化
            topView.statusViewModel = statusViewModel
            
            // 微博正文
            let statusText = statusViewModel?.status.text ?? ""
            contentLabel.attributedText = EmoticonViewModel.sharedViewModel.emoticonText(statusText, font: contentLabel.font)
            
            // 设置配图视图 －> 内部的 sizeToFit 计算出大小
            pictureView.statusViewModel = statusViewModel

            // 设置配图视图的大小
            pictureViewWidthCons?.constant = pictureView.bounds.width
            pictureViewHeightCons?.constant = pictureView.bounds.height
            // 根据是否包含图片，决定顶部约束
            pictureViewTopCons?.constant = statusViewModel?.thumbnailURLs?.count == 0 ? 0 : HMStatusCellMargin
        }
    }
    /// 宽度约束
    var pictureViewWidthCons: NSLayoutConstraint?
    /// 高度约束
    var pictureViewHeightCons: NSLayoutConstraint?
    /// 顶部约束
    var pictureViewTopCons: NSLayoutConstraint?
    
    /// 计算指定视图模型对应的行高
    ///
    /// - parameter viewModel: viewModel
    ///
    /// - returns: 计算的行高
    func rowHeight(viewModel: StatusViewModel) -> CGFloat {
        
        // 1. 设置视图模型 － 会调用 模型的 didSet
        statusViewModel = viewModel
        
        // 2. 有了内容之后更新约束
        layoutIfNeeded()
        
        // 3. 返回底部视图的最大高度
        return CGRectGetMaxY(bottomView.frame)
    }
    
    // MARK: - 搭建界面
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        // 表格的cell一定要制定背景颜色，同时不要指定 clearColor，也不建议指定 alpha
        backgroundColor = UIColor.whiteColor()
        
        // 顶部分割视图
        let topSepView = UIView()
        topSepView.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        
        // 1. 添加控件
        contentView.addSubview(topSepView)
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(pictureView)
        contentView.addSubview(bottomView)
        
        // 2. 设置布局，cell 的默认大小是 320/44，iPhone 4时代的遗留问题，宽度不能直接使用cell的宽度
        let width = UIScreen.mainScreen().bounds.width
        // 1> 顶部分隔视图
        topSepView.ff_AlignInner(type: ff_AlignType.TopLeft, referView: contentView, size: CGSize(width: width, height: 10))
        
        // 2> 顶部视图
        topView.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: topSepView, size: CGSize(width: width, height: HMStatusIconWidth + HMStatusCellMargin))
        
        // 3> 正文标签
        contentLabel.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: topView, size: nil, offset: CGPoint(x: HMStatusCellMargin, y: HMStatusCellMargin))
        
        // 5> 底部视图
        bottomView.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: pictureView, size: CGSize(width: width, height: 44), offset: CGPoint(x: -HMStatusCellMargin, y: HMStatusCellMargin))
        
        // 指定底部视图相对底边约束
        // bottomView.ff_AlignInner(type: ff_AlignType.BottomRight, referView: contentView, size: nil)
        
        // 指定 label 的代理
        contentLabel.labelDelegate = self
    }
    
    // MARK: 懒加载控件 - 从上倒下，从左到右 的顺序来写懒加载的代码，便于后期的维护
    /// 1. 顶部视图
    private lazy var topView: StatusCellTopView = StatusCellTopView()
    /// 2. 文本标签
    lazy var contentLabel: FFLabel = FFLabel(title: nil, color: UIColor.darkGrayColor(), fontSize: 15, layoutWidth: UIScreen.mainScreen().bounds.width - 2 * HMStatusCellMargin)
    /// 3. 配图视图
    lazy var pictureView: StatusPictureView = StatusPictureView()
    /// 4. 底部视图
    lazy var bottomView: StatusCellBottomView = StatusCellBottomView()
}

// MARK: - FFLabelDelegate
extension StatusCell: FFLabelDelegate {
    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        print(text)
        
        // 1. 首先判断是否以 http 开头
        if !text.hasPrefix("http://") {
            return
        }
        
        // 2. 生成一个 url
        guard let url = NSURL(string: text) else {
            return
        }
        
        // 3. 通过代理通知控制器
        cellDelegate?.statusCellDidClickURL(url)
    }
}
