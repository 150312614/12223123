//
//  StatusCellBottomView.swift
//  微博009
//
//  Created by Romeo on 15/9/5.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

class StatusCellBottomView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 设置背景颜色
        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        addSubview(forwardButton)
        addSubview(commonButton)
        addSubview(likeButton)
        
        ff_HorizontalTile([forwardButton, commonButton, likeButton], insets: UIEdgeInsetsZero)
    }

    // MARK: 懒加载控件
    private lazy var forwardButton: UIButton = UIButton(title: " 转发", imageName: "timeline_icon_retweet", color: UIColor.darkGrayColor(), fontSize: 12)
    private lazy var commonButton: UIButton = UIButton(title: " 评论", imageName: "timeline_icon_comment", color: UIColor.darkGrayColor(), fontSize: 12)
    private lazy var likeButton: UIButton = UIButton(title: " 赞", imageName: "timeline_icon_unlike", color: UIColor.darkGrayColor(), fontSize: 12)
    
}
