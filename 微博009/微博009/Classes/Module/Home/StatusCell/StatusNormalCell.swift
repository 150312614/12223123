//
//  StatusNormalCell.swift
//  微博009
//
//  Created by Romeo on 15/9/7.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 原创微博 Cell
class StatusNormalCell: StatusCell {

    override func setupUI() {
        super.setupUI()
        
        // 4> 配图视图
        let cons = pictureView.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: contentLabel, size: CGSize(width: HMStatusPictureMaxWidth, height: HMStatusPictureMaxWidth), offset: CGPoint(x: 0, y: HMStatusCellMargin))
        // 记录配图视图约束
        pictureViewWidthCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Width)
        pictureViewHeightCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Height)
        pictureViewTopCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Top)
    }
}
