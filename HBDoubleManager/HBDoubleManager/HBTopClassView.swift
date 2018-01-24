//
//  HBTopClassView.swift
//  doubleManager
//
//  Created by jianghongbao on 2017/11/2.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class HBTopClassView: UIScrollView {
    public var imageWH : CGFloat = 23 //<标题按钮图片宽高>
    public var imageToEdge : CGFloat = 10 //<.Top 和 .Bottom情况下设置有效>
    public var contentMargin : CGFloat = 5 //<图片与文本标签宽高>
    public var topicFont = UIFont.systemFont(ofSize: 14)//<图片与文本标签宽高>
    
    public var globalMargin : CGFloat = 0
    public var headBtnIndex : Int = 0
    public var topicOuterMargin : CGFloat = 10
    public var topicInnerMargin : CGFloat = 10
    public var position : HBImagePositionType = .left
    public var topicBtns = [HBTopicButton]()
    public var externals = [AnyObject]()
    
    public var selectedTopic = HBTopicButton()
    fileprivate var external : UIView?
    fileprivate var topTrackView  = UIView()
    
    private var titles = [String]()
    private var images : [String]?
    private var highImages : [String]?
    private var textColors : [UIColor]?
    private var highTextColors : [UIColor]?
    
    public var offsetRatioHandler : ((_ ratio : CGFloat ,_ tag : Int) -> ())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        setTrackView()
    }
    
    func setTrackView() -> () {
        topTrackView.backgroundColor = HBRGB(0x000000)
        self.addSubview(topTrackView)
    }
    
    func setTopics(titles:[String],
                   images:[String]?,
                   highImages:[String]?,
                   textColors:[UIColor]?,
                   highTextColors:[UIColor]?) -> () {
        self.titles = titles
        self.images = images
        self.highImages = highImages
        self.textColors = textColors
        self.highTextColors = highTextColors
        for sub in self.subviews {
            if sub.isKind(of: HBTopicButton.self) {
                sub.removeFromSuperview()
            }
        }
        
        var unifiedNormalColor : UIColor?
        var unifiedHighColor : UIColor?
        if textColors?.count == highTextColors?.count && textColors?.count == 1 {
            unifiedNormalColor = textColors?.first
            unifiedHighColor = highTextColors?.first
        }
        
        for index in 0 ..< titles.count {
            
            let topicBtn = HBTopicButton.init(frame: CGRect.zero)
            topicBtn.setParams(imageWH: imageWH,
                               innerMargin: topicInnerMargin,
                               imageToEdge: imageToEdge,
                               contentMargin: contentMargin,
                               topicFont:topicFont,
                               position: position)
            topicBtn.tag = index
            if let images = images {
                if let imgString = images.hb_object(for: index) {
                    if let image = UIImage.init(named: imgString) {
                        topicBtn.setNormalImageWith(normalImage: image)
                    }
                }
            }
            if let highImages = highImages {
                if let highImgString = highImages.hb_object(for: index) {
                    if let highImage = UIImage.init(named: highImgString) {
                        topicBtn.setHighImageWith(highImage: highImage)
                    }
                }
            }
            if let _unifiedNormalColor = unifiedNormalColor {
                topicBtn.setNormalTextColorWith(normalTextColor:_unifiedNormalColor)
            }else {
                if let textColors = textColors {
                    if let textColor = textColors.hb_object(for: index) {
                        topicBtn.setNormalTextColorWith(normalTextColor:textColor)
                    }
                }
            }
            
            if let _unifiedHighColor = unifiedHighColor {
                topicBtn.setHighTextColorWith(highTextColor:_unifiedHighColor)
            }else {
                if let highTextColors = highTextColors {
                    if let highTextColor = highTextColors.hb_object(for: index) {
                        topicBtn.setHighTextColorWith(highTextColor: highTextColor)
                    }
                }
            }
            topicBtn.setTitleWith(title: titles[index])
            if index == headBtnIndex {
                selectedTopic = topicBtn
                if let highImages = highImages {
                    if let highImgString = highImages.hb_object(for: index) {
                        if let highImage = UIImage.init(named: highImgString) {
                            topicBtn.setHighImageWith(highImage: highImage)   
                        }
                    }
                }
                if let _unifiedHighColor = unifiedHighColor {
                    topicBtn.setHighTextColorWith(highTextColor:_unifiedHighColor)
                    topTrackView.backgroundColor = _unifiedHighColor
                }else {
                    if let highTextColors = highTextColors {
                        if let highTextColor = highTextColors.hb_object(for: index) {
                            topicBtn.setHighTextColorWith(highTextColor: highTextColor)
                            topTrackView.backgroundColor = highTextColor
                        }
                    }
                }
                topicBtn.setSelected()
            }

            topicBtn.addTarget(self, action: #selector(jb_topicClicked(topic:)), for: .touchUpInside)
            self.topicBtns.append(topicBtn)
            self.addSubview(topicBtn)
        }
        
        self.bringSubview(toFront: topTrackView)
    }
    
    //MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        var preTopic : HBTopicButton?
        var topBtnWidth : CGFloat = 0
        var contentSizeWidth : CGFloat = 0
        var imageMarginWidth : CGFloat = 0
        for index in 0 ..< self.topicBtns.count {
            let topicBtn = topicBtns[index]
            let topicsOuterMargin = (index == 0) ? 0 : topicOuterMargin
            let realGlobalMargin = (index == 0) ? globalMargin : 0
            if let imgString = images?.hb_object(for: index) {
                if let _ = UIImage.init(named: imgString) {
                    switch position {
                    case .left,.right:
                        imageMarginWidth = imageWH + contentMargin
                        break
                    case .top,.bottom:
                        imageMarginWidth = 0
                        break
                    }
                }
            }
            topBtnWidth = (titles[index] as NSString).size(withAttributes: [NSAttributedStringKey.font:topicFont]).width + 2 * topicInnerMargin + imageMarginWidth
            contentSizeWidth += topBtnWidth + topicsOuterMargin + 2 * realGlobalMargin
            topicBtn.sizeToFit()
            if let pre = preTopic {
                topicBtn.frame = CGRect.init(x: pre.frame.maxX + topicsOuterMargin, y: 0, width: topBtnWidth, height: frame.height)
            }else {
                topicBtn.frame = CGRect.init(x: topicsOuterMargin + realGlobalMargin, y: 0, width: topBtnWidth, height: frame.height)
            }
            
            if index == selectedTopic.tag {
                topTrackView.frame = CGRect.init(x: topicBtn.frame.origin.x + topicInnerMargin, y: frame.size.height - 2.5, width:topicBtn.bounds.size.width - 2 * topicInnerMargin, height: 2.5)
            }
            preTopic = topicBtn
        }
        if let external = self.external {
            external.sizeToFit()
            if let pre = preTopic {
                if pre.frame.maxX + topicOuterMargin + globalMargin + external.bounds.width >= frame.width {
                    external.frame = CGRect.init(x: pre.frame.maxX + topicOuterMargin, y: 0, width: external.bounds.width, height: frame.height)
                    contentSizeWidth += (topicOuterMargin + external.bounds.width)
                }else {
                    let distance = frame.width - pre.frame.maxX - globalMargin - external.bounds.width
                    external.frame = CGRect.init(x: pre.frame.maxX + distance, y: 0, width: external.bounds.width, height: frame.height)
                    contentSizeWidth = frame.width
                }
            }else {
                external.frame = CGRect.init(x: frame.width - external.bounds.width - globalMargin, y: 0, width: external.bounds.width, height: frame.height)
            }
        }
        
        self.contentSize = CGSize.init(width: contentSizeWidth, height: frame.size.height)
    }
    
    /** 设置选中的 topic 的UI
     */
    func jb_setTopicInterface(topic:HBTopicButton) -> () {
        topic.setSelected()
        self.selectedTopic.setNormal()
        self.selectedTopic = topic
        self.changeTrackStatus(topic: topic)
        self.changeTopicsStatus(topic: topic)
    }
    
    @objc func jb_topicClicked(topic:HBTopicButton) -> () {
        if selectedTopic == topic { return }
        let tTag = topic.tag
        let sTag = selectedTopic.tag
        if tTag > sTag {// 左移
            offsetRatioHandler?(2,tTag)
        }else if tTag < sTag {// 右移
            offsetRatioHandler?(0,tTag)
        }else{
            offsetRatioHandler?(-1,tTag)
            return
        }
    }
    
    /// change selected-topicBtn's status
    fileprivate func changeTopicsStatus(topic:HBTopicButton) -> () {
        let scrollLength : CGFloat = frame.width
        let scrollContentLength : CGFloat =  self.contentSize.width
        let senderCenter = topic.frame.minX + topic.bounds.size.width / 2
        if scrollContentLength <= scrollLength {return}
        if (senderCenter >= (scrollLength / 2.0)) && (senderCenter <= (scrollContentLength - scrollLength / 2.0)) {
            UIView.animate(withDuration: 0.25) {
                self.contentOffset = CGPoint.init(x: senderCenter - (scrollLength / 2), y: 0)
            }
        }else {
            UIView.animate(withDuration: 0.25) {
                if senderCenter < (scrollLength / 2) {
                    self.contentOffset = CGPoint.init(x: 0, y: 0)
                }else{
                    self.contentOffset = CGPoint.init(x: scrollContentLength - self.bounds.size.width, y: 0)
                }
            }
        }
    }
    
    /// 重置 TrackView 的位置
    fileprivate func changeTrackStatus(topic:HBTopicButton) -> () {
        UIView.animate(withDuration: 0.25) {
            self.topTrackView.frame = CGRect.init(x: topic.frame.origin.x + self.topicInnerMargin, y: self.frame.size.height - 2.5, width: topic.bounds.size.width - 2 * self.topicInnerMargin, height: 2.5)
            self.topTrackView.backgroundColor = topic.titleL.textColor
        }
    }
    
    /** 重设置 topic 文本
     */
    public func hb_resetTopic(tag:Int,title:String) -> () {
        self.titles[tag] = title
        self.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /** 获取对应 topic
     */
    public func hb_getTopicBtn(tag:Int) -> HBTopicButton {
        let count = self.topicBtns.count
        if (tag < 0) || (tag >= count) {
            assert(false, "over limit !")
        }
        return self.topicBtns[tag]
    }
    
    /** 添加额外视图
     */
    func addExternalTopic(topic:UIView) -> () {
        self.externals.append(topic as AnyObject)
        self.external = topic
        self.addSubview(topic)
        self.setNeedsLayout()
    }
}
