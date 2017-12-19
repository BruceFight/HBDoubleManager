//
//  HBTopicButton.swift
//  doubleManager
//
//  Created by jianghongbao on 2017/11/2.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

/** 按钮类型
 * 根据按钮中图片的位置来定义了 左,上,右,下 四种样式
 */
enum HBImagePositionType {
    case left
    case top
    case right
    case bottom
}
class HBTopicButton: UIButton {//HBTopicButton
    
    //MARK: - Parameters
    public var imageV = UIImageView()
    public var titleL = UILabel()
    public var redView = UIView()
    fileprivate var imageWH : CGFloat = 0
    fileprivate let labelH : CGFloat = 0
    fileprivate let redViewWH : CGFloat = 8
    fileprivate var innerMargin : CGFloat = 10
    fileprivate var imageToEdge : CGFloat = 10
    fileprivate var contentMargin : CGFloat = 5
    fileprivate var position = HBImagePositionType.left
    
    fileprivate var normalImage : UIImage?
    fileprivate var highImage : UIImage?
    fileprivate var normalTextColor : UIColor = HBRGB(0x000000)
    fileprivate var highTextColor : UIColor = HBRGB(0x000000)
    
    //MARK: - Interface
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubs()
    }
    
    /** 设置 topic 参数
     */
    func setParams(imageWH:CGFloat,
                   innerMargin:CGFloat,
                   imageToEdge:CGFloat,
                   contentMargin:CGFloat,
                   topicFont:UIFont,
                   position:HBImagePositionType) -> () {
        self.imageWH = imageWH
        self.position = position
        self.imageToEdge = imageToEdge
        self.innerMargin = innerMargin
        self.contentMargin = contentMargin
        self.titleL.font = topicFont
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubs() -> () {
        self.backgroundColor = UIColor.white
        titleL.textColor = normalTextColor
        titleL.textAlignment = .center
        titleL.sizeToFit()
        redView = UIView.init()
        redView.backgroundColor = UIColor.red
        redView.layer.cornerRadius = redViewWH / 2
        redView.layer.shadowColor = HBRGB(0xFD6363).cgColor
        redView.layer.shadowOffset = CGSize.init(width: 0, height: 3)
        redView.isHidden = true
        self.addSubview(imageV)
        self.addSubview(titleL)
        self.addSubview(redView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setSubsLayout()
    }
    
    func setSubsLayout() -> () {
        var imageFrame = CGRect.zero
        var titleFrame = CGRect.zero
        let imageRealWH = (((imageV.image) != nil) ? imageWH : 0)
        let innerRealMargin = (((imageV.image) != nil) ? innerMargin : 0)
        let realMargin = (((imageV.image) != nil) ? contentMargin : 0)
        
        switch position {
        case .left:
            imageFrame = CGRect.init(x: innerRealMargin, y: (frame.size.height - imageRealWH) / 2, width:imageRealWH, height: imageRealWH)
            titleFrame = CGRect.init(x: imageFrame.maxX + realMargin, y: 0, width: (frame.size.width - 2 * innerRealMargin - realMargin - imageRealWH), height: frame.size.height)
            break
        case .top:
            imageFrame = CGRect.init(x: (frame.size.width - imageRealWH) / 2, y: self.imageToEdge, width:imageRealWH, height: imageRealWH)
            titleFrame = CGRect.init(x: 0, y: imageFrame.maxY + realMargin, width: frame.size.width, height: frame.size.height - imageFrame.maxY - realMargin)
            break
        case .right:
            imageFrame = CGRect.init(x: frame.size.width - innerRealMargin - imageRealWH, y: (frame.size.height - imageRealWH) / 2, width:imageRealWH, height: imageRealWH)
            titleFrame = CGRect.init(x: innerRealMargin, y: 0, width: (frame.size.width - 2 * innerRealMargin - realMargin - imageRealWH), height: frame.size.height)
            break
        case .bottom:
            imageFrame = CGRect.init(x: (frame.size.width - imageRealWH) / 2, y: frame.size.height - imageRealWH - self.imageToEdge, width:imageRealWH, height: imageRealWH)
            titleFrame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: imageFrame.minY - realMargin)
            break
        }
        imageV.frame = imageFrame
        titleL.frame = titleFrame
        redView.frame = CGRect.init(x: titleL.frame.maxX - innerMargin, y: titleL.center.y-(6 + redViewWH), width: redViewWH, height: redViewWH)
    }
    
    func setTitleWith(title:String) -> () {
        self.titleL.text = title
    }
    
    func setNormalImageWith(normalImage:UIImage) -> () {
        self.normalImage = normalImage
        self.imageV.image = normalImage
    }
    
    func setHighImageWith(highImage:UIImage) -> () {
        self.highImage = highImage
    }
    
    func setNormalTextColorWith(normalTextColor:UIColor) -> () {
        self.normalTextColor = normalTextColor
        self.titleL.textColor = normalTextColor
    }
    
    func setHighTextColorWith(highTextColor:UIColor) -> () {
        self.highTextColor = highTextColor
    }

    func setNormal() -> () {
        self.imageV.image = normalImage
        self.titleL.textColor = normalTextColor
    }
    
    func setSelected() -> () {
        self.imageV.image = highImage
        self.titleL.textColor = highTextColor
    }
}


