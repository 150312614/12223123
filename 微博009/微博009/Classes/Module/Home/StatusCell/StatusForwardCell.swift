//
//  StatusForwardCell.swift
//  微博009
//
//  Created by Romeo on 15/9/7.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 转发微博的 Cell
class StatusForwardCell: StatusCell {

    /// 重写父类的 － 微博数据视图模型
    /// 不需要 super，父类的 didSet 仍然能够正常执行 -> 只需要设置子类的控件内容
    override var statusViewModel: StatusViewModel? {
        didSet {
            let forwardText = statusViewModel?.forwardText ?? ""
            forwardLabel.attributedText = EmoticonViewModel.sharedViewModel.emoticonText(forwardText, font: forwardLabel.font)
        }
    }
    
    // 设置 UI
    override func setupUI() {
        // 执行父类的方法
        super.setupUI()
        
        // 添加控件
        contentView.insertSubview(backButton, belowSubview: pictureView)
        contentView.insertSubview(forwardLabel, aboveSubview: backButton)
        
        // 设置布局
        // 1> 背景按钮
        backButton.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: contentLabel, size: nil, offset: CGPoint(x: -HMStatusCellMargin, y: HMStatusCellMargin))
        backButton.ff_AlignVertical(type: ff_AlignType.TopRight, referView: bottomView, size: nil)
        
        // 2> 转发文字
        forwardLabel.ff_AlignInner(type: ff_AlignType.TopLeft, referView: backButton, size: nil, offset: CGPoint(x: HMStatusCellMargin, y: HMStatusCellMargin))
        
        // 3> 配图视图
        let cons = pictureView.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: forwardLabel, size: CGSize(width: HMStatusPictureMaxWidth, height: HMStatusPictureMaxWidth), offset: CGPoint(x: 0, y: HMStatusCellMargin))
        // 记录配图视图约束
        pictureViewWidthCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Width)
        pictureViewHeightCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Height)
        pictureViewTopCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Top)

        // 4> 设置转发微博的文本代理 - 一旦触发，会调用父类协议方法
        forwardLabel.labelDelegate = self
    }
    
    // MARK: - 懒加载控件
    /// 背景按钮
    private lazy var backButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        return button
    }()
    /// 转发的文字
    private lazy var forwardLabel: FFLabel = FFLabel(title: "", color: UIColor.darkGrayColor(), fontSize: 14, layoutWidth: UIScreen.mainScreen().bounds.width - 2 * HMStatusCellMargin)
}
