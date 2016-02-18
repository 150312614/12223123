//
//  StatusCellTopView.swift
//  微博009
//
//  Created by Romeo on 15/9/5.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import SDWebImage

/// 顶部视图
class StatusCellTopView: UIView {

    /// 微博的视图模型
    var statusViewModel: StatusViewModel? {
        didSet {
            nameLabel.text = statusViewModel?.status.user?.name
            // sd_setImageWithURL 函数是 OC 的，参数可以传递 nil，不用解包
            iconView.sd_setImageWithURL(statusViewModel?.userIconUrl)
            // vip
            vipView.image = statusViewModel?.userVipImage
            // 会员图标
            memberView.image = statusViewModel?.userMemberImage
            
            // 时间需要不停的计算，每次 cell 显示时都需要计算
            timeLabel.text = NSDate.sinaDate(statusViewModel?.status.created_at ?? "")?.dateDescription
            // 微博的来源不需要每次都计算
            sourceLabel.text = statusViewModel?.status.source
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.whiteColor()
        
        // 1. 添加控件
        addSubview(iconView)
        addSubview(nameLabel)
        addSubview(memberView)
        addSubview(timeLabel)
        addSubview(sourceLabel)
        addSubview(vipView)
        
        // 2. 自动布局
        let offset = CGPoint(x: HMStatusCellMargin, y: 0)
        iconView.ff_AlignInner(type: ff_AlignType.TopLeft, referView: self, size: CGSize(width: HMStatusIconWidth, height: HMStatusIconWidth), offset: CGPoint(x: HMStatusCellMargin, y: HMStatusCellMargin))
        nameLabel.ff_AlignHorizontal(type: ff_AlignType.TopRight, referView: iconView, size: nil, offset: offset)
        memberView.ff_AlignHorizontal(type: ff_AlignType.TopRight, referView: nameLabel, size: nil, offset: offset)
        timeLabel.ff_AlignHorizontal(type: ff_AlignType.BottomRight, referView: iconView, size: nil, offset: offset)
        sourceLabel.ff_AlignHorizontal(type: ff_AlignType.BottomRight, referView: timeLabel, size: nil, offset: offset)
        vipView.ff_AlignInner(type: ff_AlignType.BottomRight, referView: iconView, size: nil, offset: CGPoint(x: 8, y: 8))
    }
    
    // MARK: 懒加载控件
    private lazy var iconView: UIImageView = UIImageView(image: UIImage(named: "avatar_default_big"))
    private lazy var nameLabel: UILabel = UILabel(title: "姓名", color: UIColor.darkGrayColor(), fontSize: 14)
    private lazy var memberView: UIImageView = UIImageView(image: UIImage(named: "common_icon_membership_level1"))
    private lazy var timeLabel: UILabel = UILabel(title: "刚刚", color: UIColor.orangeColor(), fontSize: 10)
    private lazy var sourceLabel: UILabel = UILabel(title: "来自 新浪微博", color: UIColor.darkGrayColor(), fontSize: 10)
    private lazy var vipView: UIImageView = UIImageView(image: UIImage(named: "avatar_grassroot"))
}
