//
//  HBDoubleManager.swift
//  Accumulate-ProjectForSwift
//
//  Created by Bruce Jiang on 2017/4/10.
//  Copyright © 2017年 Bruce Jiang. All rights reserved.
//


import UIKit
class HBDoubleManager: UIView ,UIScrollViewDelegate {

    fileprivate var topClassView = HBTopClassView()
    fileprivate var bottomClassView = HBBotClassView()
    fileprivate var topClassHeight = CGFloat()
    fileprivate var topDivisionView = UIView()
    fileprivate var counts : Int = 0
    
    /** 是否Bounce
     */
    open var kIfBounce : Bool = true {
        didSet{
            bottomClassView.bounces = kIfBounce
        }
    }
    
    /** 滚动类型 -> 见HBScrollType
     */
    open var scrollType : HBScrollType = HBScrollType.default {
        didSet{
            self.bottomClassView.scrollType = scrollType
        }
    }
    
    /** 添加额外视图
     */
    func addExternal(external:UIView) -> () {
        self.topClassView.addExternalTopic(topic: external)
    }

    // 宽度
    fileprivate var _width : CGFloat = 0
    // 高度
    fileprivate var _height : CGFloat = 0
    // 当前点
    fileprivate var _curPoint = CGPoint()
    // 当前索引
    fileprivate var _curIndex : Int = 0
    // 宿主视图
    fileprivate var _hostView = UIView()
    // 宿主控制器
    weak fileprivate var _hostVc = UIViewController()
    
    // 主页轮播逻辑控制判断
    fileprivate var kIfCanSet : Bool = false
    fileprivate var kIfLeftHasSetted : Bool = false
    fileprivate var kIfRightHasSetted : Bool = false
    
    //MARK: - Public parameters
    public var imageWH        : CGFloat = 23 //<标题按钮图片宽高>
    public var imageToEdge    : CGFloat = 10 //<.Top 和 .Bottom情况下设置有效>
    public var contentMargin  : CGFloat = 5 //<图片与文本标签宽高>
    public var topicFont      : UIFont = UIFont.systemFont(ofSize: 14) //<字体大小>
    public var currentIndex   : Int {
        return self._curIndex
    }
    
    /** 视图切换回调
     */
    public var HB_getMain : ((_ tag:Int) -> (UIView?))?
    
    /** topic点击回调
     */
    public var HB_topicClicked : ((_ topicBtnTag:Int) -> ())?
    
    //MARK: - Interface
    // Init
    init(frame:CGRect, view:UIView) {
        super.init(frame: frame)
        self.backgroundColor = view.backgroundColor
        self.clipsToBounds = true
        self.frame = view.bounds
        self.setHostVc(view: view)
        view.addSubview(self)
        _hostView = view
    }
    
    // 找到对应宿主View所在控制器,并取消自动调整
    private func setHostVc(view:UIView) -> () {
        guard let nextV = view.next else {return}
        if nextV.isKind(of: UIViewController.self) {
            _hostVc = nextV as? UIViewController
            if #available(iOS 11.0, *) {
                
            }else {
                _hostVc?.automaticallyAdjustsScrollViewInsets = false
            }
        }else if nextV.isKind(of: UIView.self) {
            if let nextV = nextV.next as? UIView {
                self.setHostVc(view: nextV)
            }
        }
    }
    
    //MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()// 在这里可以得到宿主视图正确的高度
        _width = frame.size.width
        _height = frame.size.height
        
        self.topClassView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.topClassHeight)
        self.topClassView.setNeedsLayout()
        self.topDivisionView.frame = CGRect.init(x: 0, y: self.topClassView.frame.maxY, width:self.bounds.size.width, height: 0.5)
        self.bottomClassView.frame = CGRect.init(x: self.bottomClassView.frame.origin.x, y: self.topDivisionView.frame.maxY, width: self.bounds.size.width, height: self.bounds.size.height - self.topClassView.bounds.height - self.topDivisionView.bounds.height)
        self.bottomClassView.setNeedsLayout()
        var offsetX : CGFloat = 0
        switch self.scrollType {
        case .default:
            if self.counts == 1 {
                offsetX = 0
            }else {
                offsetX = _width
            }
            break
        case .limited:
            if self.counts == 1 {
                offsetX = 0
            }else if self.counts > 1 && self.counts <= 3 {
                offsetX = CGFloat(_curIndex) * _width
            }else if self.counts > 3 {
                if _curIndex == 0 {
                    offsetX = 0
                }else if _curIndex == (self.counts - 1) {
                    offsetX = 2 * _width
                }else {
                    offsetX = _width
                }
            }
            break
        }
        self.bottomClassView.contentOffset = CGPoint.init(x: offsetX, y: 0)
        self._curPoint.x = bottomClassView.contentOffset.x
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/**********Interface API***********/
extension HBDoubleManager {
    //MARK: - 💕public Interface Of SetTopClassView
    /**
     * height - topClassView的高度(required)
     * head - 首亮按钮索引值(optional,default '0')
     * position - 正常按钮图片数组(optional,default 'Left')
     * inner - 按钮内部边界间隔(optional,default '0')
     * outer - 按钮间间隔(optional,default '0')
     * global - 全局左右距父级边界值(optional,default '0')
     * titles - 按钮文本数组(required)
     * images - 正常按钮图片数组(optional)
     * h_images - 高亮按钮图片数组(optional)
     * textColors - 正常文本颜色数组(required)
     * h_textColors - 高亮文本颜色数组(required)
     */
    public func HB_getTop(height:CGFloat!,
                          head:Int = 0,
                          position:HBImagePositionType = .left,
                          inner:CGFloat = 0,
                          outer:CGFloat = 0,
                          global:CGFloat = 0,
                          titles:[String]!,
                          images:[String]?,
                          h_images:[String]?,
                          textColors:[UIColor]?,
                          h_textColors:[UIColor]?) -> () {
        counts = titles.count
        if titles.count <= 0 { return }
        for _ in 0 ..< self.counts {
            self.bottomClassView.mains.append(HBHolderView())
        }
        self.bottomClassView.resetHolders()
        self.topClassHeight = height
        self._curIndex = head
        topClassView.imageWH = imageWH
        topClassView.imageToEdge = imageToEdge
        topClassView.contentMargin = contentMargin
        topClassView.topicFont = topicFont
        topClassView.position = position
        topClassView.headBtnIndex = head
        topClassView.globalMargin = global
        topClassView.topicInnerMargin = inner
        topClassView.topicOuterMargin = outer
        topClassView.setTopics(titles: titles,
                               images: images,
                               highImages: h_images,
                               textColors: textColors,
                               highTextColors: h_textColors)
        
        self.addSubview(self.topClassView)
        self.topDivisionView.backgroundColor = HBRGB(0xECECEC)
        self.topClassView.offsetRatioHandler = {[weak self] (ratio,tTag) in
            guard let strongSelf = self else { return }
            if ratio > 0 {//左移
                strongSelf._curIndex = strongSelf.pre(current: tTag)
            }else {//右移
                strongSelf._curIndex = strongSelf.next(current: tTag)
            }
            UIView.animate(withDuration: 0.25, animations: {
                if self?.scrollType == .default {
                    strongSelf.bottomClassView.contentOffset = CGPoint.init(x: strongSelf._width * ratio, y: 0)
                }else {
                    if let counts = self?.counts {
                        if counts <= 3 {
                            strongSelf.bottomClassView.contentOffset = CGPoint.init(x: strongSelf._width * CGFloat(tTag) , y: 0)
                        }else {
                            if tTag == 0 {
                                strongSelf.bottomClassView.contentOffset = CGPoint.init(x: 0, y: 0)
                            }else if tTag == (counts - 1) {
                                strongSelf.bottomClassView.contentOffset = CGPoint.init(x: strongSelf._width * ratio, y: 0)
                            }else {
                                strongSelf.bottomClassView.contentOffset = CGPoint.init(x: strongSelf._width * ratio, y: 0)
                            }
                        }
                    }
                }
            }) { (false) in
                strongSelf.scrollViewDidEndDecelerating(strongSelf.bottomClassView)
            }
        }
        self.addSubview(topDivisionView)
        self.bottomClassView.HB_getMainHandler = self.HB_getMain
        self.bottomClassView.tag = self.hash
        self.bottomClassView.delegate = self
        self.bottomClassView.headIndex = head
        self.addSubview(bottomClassView)
    }

    /** hide redView
     */
    public func HB_hideRedView(tag:Int) -> () {
        self.topClassView.HB_getTopicBtn(tag: tag).redView.isHidden = true
    }
    
    /** show redView
     */
    public func HB_showRedView(tag:Int) -> () {
        self.topClassView.HB_getTopicBtn(tag: tag).redView.isHidden = false
    }
    
    /** nge topic-button title
     */
    public func HB_resetTopic(tag:Int,title:String) -> () {
        self.topClassView.HB_resetTopic(tag: tag, title: title)
    }
    
    /** change top-scrollView top-division-color
     */
    public func HB_setDivisionColor(color:UIColor) -> () {
        self.topDivisionView.backgroundColor = color
    }
    
    /** Reset TopClassView
     */
    public func HB_resetTopicsLayoutsWith(offsety:CGFloat) -> () {
        for index in 0 ..< self.topClassView.topicBtns.count {
            let topic = self.topClassView.topicBtns[index]
            let alpha = CGFloat(offsety / topic.bounds.size.height)// 由0-1
            if (offsety > 0) && (offsety < topic.bounds.size.height) {// >= 0 && <= 1
                UIView.animate(withDuration: 0.25, animations: {
                    topic.imageV.alpha = 1.0 - alpha
                    topic.titleL.frame = CGRect.init(x: 0, y: topic.bounds.size.height - 10 - topic.titleL.bounds.size.height - topic.imageV.bounds.size.height * alpha, width: topic.frame.size.width, height: topic.bounds.size.height - 20 - topic.imageV.bounds.size.height * alpha)
                    topic.titleL.font = UIFont.systemFont(ofSize: 5 * alpha + 12)
                })
            }else if (offsety <= 0) { // < 0
                UIView.animate(withDuration: 0.25, animations: {
                    topic.imageV.alpha = 1.0
                    topic.titleL.frame = CGRect.init(x: 0, y: 10 + topic.imageV.bounds.size.height * topic.imageV.alpha, width: topic.frame.size.width, height: topic.bounds.size.height - 20 - topic.imageV.bounds.size.height * topic.imageV.alpha)
                    topic.titleL.font = UIFont.systemFont(ofSize: 12)
                })
            }else{// > 1
                UIView.animate(withDuration: 0.25, animations: {
                    topic.imageV.alpha = 0
                    topic.titleL.frame = CGRect.init(x: 0, y: topic.bounds.size.height - 10 - topic.titleL.bounds.size.height - topic.imageV.bounds.size.height * topic.imageV.alpha, width: topic.frame.size.width, height: topic.bounds.size.height - 20 - topic.imageV.bounds.size.height * topic.imageV.alpha)
                    topic.titleL.font = UIFont.systemFont(ofSize: 16)
                })
            }
        }
    }
    
    /** 底部BottomClassView占满全屏或初始状态,顶部TopClassView隐藏或显示(Public Interface)
     */
    public func HB_resetBottomClassViewLayoutWith(offsety:CGFloat) -> () {
        let alpha = CGFloat(offsety / topClassView.bounds.size.height)// 由0-1
        if (offsety > 0) && (offsety < topClassView.bounds.size.height) {// >= 0 && <= 1
            UIView.animate(withDuration: 0.25, animations: {
                self.topClassView.alpha = 1.0 - alpha
                self.bottomClassView.frame = CGRect.init(x: 0, y: self.topClassView.frame.maxY - alpha * self.topClassView.bounds.size.height, width: self.bounds.size.width, height: self.bounds.size.height - (1 - alpha) * self.topClassView.bounds.size.height)
            })
        }else if (offsety <= 0) { // < 0
            UIView.animate(withDuration: 0.25, animations: {
                self.topClassView.alpha = 1.0
                self.bottomClassView.frame = CGRect.init(x: 0, y: self.topClassView.frame.maxY, width: self.bounds.size.width, height: self.bounds.size.height - self.topClassView.frame.maxY)
            })
        }else{// > 1
            UIView.animate(withDuration: 0.25, animations: {
                self.topClassView.alpha = 0
                self.bottomClassView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
            })
        }
    }
    
}

/**********UIScrollViewDelegate***********/
extension HBDoubleManager {
    
    //MARK: - UIScrollViewDelegate
    /// 正在滚动
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.tag != self.hash { return }
        
        if (scrollView.contentOffset.x > _curPoint.x){// 左滑
            if kIfLeftHasSetted {return}else {
                kIfCanSet = false
                kIfRightHasSetted = false
            }
        }else{
            if kIfRightHasSetted {return}else {
                kIfCanSet = false
                kIfLeftHasSetted = false
            }
        }
        
        guard let viewDidLoad = _hostVc?.isViewLoaded else { return }
        let kIfCan = ((abs(scrollView.contentOffset.x - _curPoint.x) >= 0.000001) && self.counts == 2 && (kIfCanSet == false) && viewDidLoad) && (self.bottomClassView.scrollType == .default)
        if (scrollView.contentOffset.x > _curPoint.x) {// 左滑
            if kIfCan {
                kIfCanSet = true
                if kIfLeftHasSetted == false {
                    if !self.bottomClassView.getMax().subviews.isEmpty { return }else {
                        self.bottomClassView.exchangeMinAndMax()
                        kIfLeftHasSetted = true
                    }
                }
            }
        }else if (scrollView.contentOffset.x < _curPoint.x) {
            if kIfCan {
                kIfCanSet = true
                if kIfRightHasSetted == false {
                    if !self.bottomClassView.getMin().subviews.isEmpty { return }else {
                        self.bottomClassView.exchangeMinAndMax()
                        kIfRightHasSetted = true
                    }
                }
            }
        }
    }
    
    /// 停止滚动
    internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        if scrollView.tag != self.hash {
            return
        }
        if abs(scrollView.contentOffset.x).truncatingRemainder(dividingBy: _width) > 0 {
            return
        }
        
        if self.counts <= 2 && self.scrollType == .default {
            kIfCanSet = false
            
            if kIfLeftHasSetted {
                if let nextView = self.bottomClassView.mains.HB_object(for: self.next(current: _curIndex)) {
                    if !nextView.isKind(of: HBHolderView.self) {
                        kIfLeftHasSetted = false
                    }
                }
            }
            
            if kIfRightHasSetted {
                if let preView = self.bottomClassView.mains.HB_object(for: self.pre(current: _curIndex)) {
                    if !preView.isKind(of: HBHolderView.self) {
                        kIfRightHasSetted = false
                    }
                }
            }
        }
        
        if (abs(scrollView.contentOffset.x - _curPoint.x) < 0.001) {
            return
        }

        if (scrollView.contentOffset.x > _curPoint.x) {// 左滑
            _curIndex = self.next(current: _curIndex)
            self.bottomClassView.turnLeft(_curIndex: _curIndex)
        }else{// 右滑
            _curIndex = self.pre(current: _curIndex)
            self.bottomClassView.turnRight(_curIndex: _curIndex)
        }
    
        self.topClassView.jb_setTopicInterface(topic: self.topClassView.topicBtns[_curIndex])
        self._curPoint.x = bottomClassView.contentOffset.x
        //可以传到外面
        HB_topicClicked?(_curIndex)
    }
    
}

extension HBDoubleManager {
    
    //MARK: - 下一页
    fileprivate func next(current:NSInteger) -> NSInteger {
        return (current + 1) % self.counts //队列指针+1
    }
    
    //MARK: - 上一页
    fileprivate func pre(current:NSInteger) -> NSInteger {
        return (current - 1 + self.counts) % self.counts // 队列指针-1
    }
    
}

extension Array {
    func HB_object(for index: Int) -> Element? {
        if index >= 0 && index < self.count {
            return self[index]
        }
        return nil
    }
}

func HBRGBA(_ colorValue: UInt32, alpha: CGFloat) -> UIColor {
    return UIColor.init(red: CGFloat((colorValue>>16)&0xFF)/256.0, green: CGFloat((colorValue>>8)&0xFF)/256.0, blue: CGFloat((colorValue)&0xFF)/256.0 , alpha: alpha)
}

func HBRGB(_ colorValue: UInt32) -> UIColor {
    return HBRGBA(colorValue, alpha: 1.0)
}
