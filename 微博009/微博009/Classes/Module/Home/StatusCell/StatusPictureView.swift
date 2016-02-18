//
//  StatusPictureView.swift
//  微博009
//
//  Created by Romeo on 15/9/7.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import SDWebImage

// MARK: - 通知常量，常量是保存在常量区，所有的常量共享，一定要足够长，可以避免重复
/// 选中照片通知
let HMStatusPictureViewSelectedPhotoNotification = "HMStatusPictureViewSelectedPhotoNotification"
/// 选中索引 Key
let HMStatusPictureViewSelectedPhotoIndexPathKey = "HMStatusPictureViewSelectedPhotoIndexPathKey"
/// 选中的图片 URL Key
let HMStatusPictureViewSelectedPhotoURLsKey = "HMStatusPictureViewSelectedPhotoURLsKey"

/// 可重用标识符
private let HMStatusPictureViewCellID = "HMStatusPictureViewCellID"

class StatusPictureView: UICollectionView {

    /// 微博数据视图模型 － 如果是新的 cell 才会设置模型
    var statusViewModel: StatusViewModel? {
        didSet {
            sizeToFit()
            
            // 刷新数据
            reloadData()
        }
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return calcViewSize()
    }
    
    /// 根据模型中的图片数量来计算视图大小
    private func calcViewSize() -> CGSize {
        // 1. 准备工作
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        // 设置默认大小
        layout.itemSize = CGSize(width: HMStatusPictureItemWidth, height: HMStatusPictureItemWidth)
        
        // 2. 根据图片数量来计算大小
        let count = statusViewModel?.thumbnailURLs?.count ?? 0
        
        // 1> 没有图
        if count == 0 {
            return CGSizeZero
        }
        
        // 2> 1张图
        if count == 1 {
            var size = CGSize(width: 150, height: 150)
            
            // 判断图片是否已经被正确的缓存 Key 是 URL 的完整字符串
            let key = statusViewModel!.thumbnailURLs![0].absoluteString
            
            // 如果有缓存图片，记录当前图片的大小
            if let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(key) {
                size = image.size
            }
            
            // 单独处理过宽或者过窄的图片
            size.width = size.width < 40 ? 40 : size.width
            size.width = size.width > 300 ? 300 : size.width
            
            layout.itemSize = size
            return size
        }
        
        // 3> 4张图 2 * 2 
        if count == 4 {
            let w = 2 * HMStatusPictureItemWidth + HMStatusPictureItemMargin
            
            return CGSize(width: w, height: w)
        }
        
        // 4> 其他
        /**
            2, 3,
            5, 6,
            7, 8, 9
        */
        // 计算显示图片的行数
        let row = CGFloat((count - 1) / Int(HMStatusPictureMaxCount) + 1)
        let h = row * HMStatusPictureItemWidth + (row - 1) * HMStatusCellMargin
        let w = HMStatusPictureMaxWidth
        
        return CGSize(width: w, height: h)
    }
    
    // 构造函数的调用是底层自动转发的 init() -> initWithFrame -> initWithFrame:layout:
    // 默认的 layout 没有被初始化
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        
        backgroundColor = UIColor.lightGrayColor()
        
        // 设置布局的间距
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = HMStatusPictureItemMargin
        layout.minimumLineSpacing = HMStatusPictureItemMargin
        
        // 指定数据源 & 代理
        // 1. 在自定义 view 中，代码逻辑相对简单，可以考虑自己充当自己的数据源
        // 2. dataSource & delegate 本身都是弱引用，自己充当自己的代理不会产生循环引用
        // 3. 除了配图视图，自定义 pickerView(省市联动的)
        dataSource = self
        delegate = self
        
        // 注册可重用 cell
        registerClass(StatusPictureViewCell.self, forCellWithReuseIdentifier: HMStatusPictureViewCellID)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDataSource
extension StatusPictureView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        // 测试起始位置&目标位置的代码
//        let v = UIView(frame: fullScreenRect(indexPath))
//        
//        v.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
//        UIApplication.sharedApplication().keyWindow?.addSubview(v)
        
        // 发送通知
        /**
            object: 发送的对象，可以传递一个数值，也可以是`自己`，通过 obj.属性
            userInfo: 可选字典，可以传递多个数值，object 必须有值
        */
        NSNotificationCenter.defaultCenter().postNotificationName(HMStatusPictureViewSelectedPhotoNotification,
            object: self,
            userInfo: [HMStatusPictureViewSelectedPhotoIndexPathKey: indexPath,
                HMStatusPictureViewSelectedPhotoURLsKey: statusViewModel!.bmiddleURLs!])
    }
    
    /// 返回指定 indexPath 对应 cell 在屏幕上的坐标位置
    func screenRect(indexPath: NSIndexPath) -> CGRect {
        let cell = cellForItemAtIndexPath(indexPath)
        
        // 转换坐标 convert，每一个视图的 frame 都是相对父视图来定义的
        // 有的时候，同一个位置，需要知道在其他视图中的对应位置，这个时候，就可以使用 conver 函数
        // UIView 本身就遵守了 UICoordinateSpace 协议，该协议提供了坐标转换的方法
        return convertRect(cell!.frame, toCoordinateSpace: UIApplication.sharedApplication().keyWindow!)
    }
    
    /// 返回指定 indexPath 对应 图像完全放大后，在屏幕上的坐标
    func fullScreenRect(indexPath: NSIndexPath) -> CGRect {
        // 根据［缩略图］`图片`来计算目标尺寸
        // 1. 拿到缩略图
        let key = statusViewModel!.thumbnailURLs![indexPath.item].absoluteString
        let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(key)
        
        // 2. 根据图像计算宽高比
        let scale = image.size.height / image.size.width
        let w = UIScreen.mainScreen().bounds.width
        let h = w * scale
        
        // 3. 判断高度
        var y = (UIScreen.mainScreen().bounds.height - h) * 0.5
        if y < 0 {  // 如果图片的高度大于屏幕高度，让图片置顶
            y = 0
        }
        
        return CGRect(x: 0, y: y, width: w, height: h)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statusViewModel?.thumbnailURLs?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HMStatusPictureViewCellID, forIndexPath: indexPath) as! StatusPictureViewCell
        
        cell.imageURL = statusViewModel!.thumbnailURLs![indexPath.item]

        return cell
    }
}

/// 配图视图的 Cell
private class StatusPictureViewCell: UICollectionViewCell {
    
    /// 配图视图的 URL
    var imageURL: NSURL? {
        didSet {
            iconView.sd_setImageWithURL(imageURL)
            
            // 在设置图像 URL 的同时，根据图片的扩展名来判断是否是GIF
            gifIconView.hidden = (imageURL!.absoluteString as NSString).pathExtension.lowercaseString != "gif"
        }
    }
    
    // MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iconView)
        iconView.addSubview(gifIconView)
        
        iconView.ff_Fill(self)
        gifIconView.ff_AlignInner(type: ff_AlignType.BottomRight, referView: iconView, size: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载
    private lazy var iconView: UIImageView = {
       
        let iv = UIImageView()
        
        // 设置填充模式
        iv.contentMode = UIViewContentMode.ScaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    /// GIF 指示图片
    private lazy var gifIconView: UIImageView = UIImageView(image: UIImage(named: "timeline_image_gif"))
}
