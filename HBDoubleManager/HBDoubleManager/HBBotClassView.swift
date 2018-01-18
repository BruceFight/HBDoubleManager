//
//  HBBotClassView.swift
//  doubleManager
//
//  Created by jianghongbao on 2017/11/3.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

/** 滚动类型
 */
enum HBScrollType {
    case `default` // infinite type
    case limited
}

class HBBotClassView: UIScrollView {
    open var holders = [HBHolderView]()
    open var mains = [UIView]()
    open var scrollType : HBScrollType = HBScrollType.default
    fileprivate var _width : CGFloat = 0
    public var headIndex : Int = 0 {
        didSet{
            if let primeView = self.hb_getMainHandler?(headIndex) {
                if let _ = self.mains.hb_object(for: headIndex) {
                    self.mains[headIndex] = primeView
                    self.setFirstMain(main:primeView)
                }else {
                    assert(false, "`headIndex` must out of index ,please make sure it's smaller than total number !")
                }
            }
        }
    }
    //@ 视图切换回调
    public var hb_getMainHandler : ((_ tag:Int) -> (UIView?))?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bounces = true
        self.isPagingEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.contentInsetAdjustmentBehavior = .never
        self.alwaysBounceVertical = false
        self.alwaysBounceHorizontal = true
        for _ in 0 ..< 3 {
            let holder = HBHolderView()
            self.holders.append(holder)
            self.addSubview(holder)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self._width = bounds.width
        var preHolder : HBHolderView?
        for i in 0 ..< holders.count {
            if let pre = preHolder {
                holders[i].frame = CGRect.init(x: pre.frame.maxX, y: 0, width: frame.size.width, height: frame.size.height)
            }else {
                holders[i].frame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            }
            holders[i].setNeedsLayout()
            preHolder = holders[i]
        }
        self.contentSize = CGSize.init(width: CGFloat(holders.count) * frame.width, height: frame.height)
        
    }
    
    //MARK: - 获取最小的视图
    func getMin() -> HBHolderView {
        var min : HBHolderView?
        var minF = CGFloat.greatestFiniteMagnitude
        for holder in holders {
            if holder.frame.origin.x < minF {
                minF = holder.frame.origin.x
                min = holder
            }
        }
        return min ?? HBHolderView()
    }
    
    //MARK: - 获取最大的视图
    func getMax() -> HBHolderView {
        var max : HBHolderView?
        var maxF = CGFloat.leastNormalMagnitude
        for holder in holders {
            if holder.frame.origin.x > maxF {
                maxF = holder.frame.origin.x
                max = holder
            }
        }
        return max ?? HBHolderView()
    }
    
    //MARK: - 获取中间的视图
    func getCenter() -> HBHolderView {
        var center : HBHolderView?
        for holder in holders {
            if holder.frame.origin.x == self.bounds.width {
                center = holder
            }
        }
        return center ?? HBHolderView()
    }
    
    /** 设置初始化视图
     */
    func setFirstMain(main:UIView) -> () {
        var position : Int = 0
        if self.scrollType == .default {
            position = (self.holders.count >= 3) ? 1 : 0
        }else {
            if 0 < self.mains.count && self.mains.count <= 3 {
                position = self.headIndex
            }else {
                if self.headIndex == 0 {
                    position = 0
                }else if self.headIndex == (self.mains.count - 1) {
                    position = 2
                }else {
                    position = 1
                }
            }
        }
        holders[position].main = main
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getIfContinue() -> Bool {
        return self.holders.count <= 1
    }
    
    /** 左滚
     */
    func turnLeft(_curIndex:Int) -> () {
        if self.holders.count <= 1 {
            return
        }
        let minV = self.getMin()
        let maxV = self.getMax()
        if self.holders.count == 2 {
            self.setMinMax(minV: minV, maxV: maxV, _curIndex: _curIndex)
            return
        }
        let centerV = self.getCenter()
        if self.scrollType == .default {
            self.scrollLeftNormal(_curIndex: _curIndex, minV: minV, maxV: maxV, centerV: centerV)
        }else {
            if _curIndex == 0 {
                self.scrollLeftLimitedAndEqualThree(range: 0 ..< 3, minV: minV, maxV: maxV, centerV: centerV)
            }else if _curIndex == (self.mains.count - 1) {
                self.scrollLeftLimitedAndEqualThree(range: _curIndex - 2 ..< self.mains.count, minV: minV, maxV: maxV, centerV: centerV)
            }else {
                if self.mains.count <= 3 {
                    if var main = self.mains.hb_object(for: _curIndex) {
                        if main.isKind(of: HBHolderView.self) {
                            guard let newMain = hb_getMainHandler?(_curIndex) else{return}
                            main = newMain
                        }
                        centerV.main = main
                        self.mains[_curIndex] = main
                    }
                }else {
                    self.scrollLeftNormal(_curIndex: _curIndex, minV: minV, maxV: maxV, centerV: centerV)
                }
            }
        }
    }
    
    /** (左滚)限制状态下个数为三的视图设置
     */
    fileprivate func scrollLeftLimitedAndEqualThree(range:CountableRange<Int>,
                                                    minV:HBHolderView,
                                                    maxV:HBHolderView,
                                                    centerV:HBHolderView) -> () {
        for i in range {
            if var main = self.mains.hb_object(for: i) {
                if main.isKind(of: HBHolderView.self) {
                    guard let newMain = hb_getMainHandler?(i) else{return}
                    main = newMain
                }
                if i == range.startIndex {
                    minV.main = main
                }else if i == range.startIndex + 1 {
                    centerV.main = main
                }else {
                    maxV.main = main
                }
                self.mains[i] = main
            }
        }
    }
    
    /** (左滚)正常的轮播效果
     */
    fileprivate func scrollLeftNormal(_curIndex:Int,
                                      minV:HBHolderView,
                                      maxV:HBHolderView,
                                      centerV:HBHolderView) -> () {
        var maxF = maxV.frame
        maxF.origin.x += _width
        minV.frame = maxF
        // 创建内容
        if var main = self.mains.hb_object(for: _curIndex) {
            if main.isKind(of: HBHolderView.self) {
                guard let newMain = hb_getMainHandler?(_curIndex) else{return}
                main = newMain
            }
            maxV.main = main
            self.mains[_curIndex] = main
        }
        
        self.holders = self.holders.map({ (holder) -> HBHolderView in
            holder.frame.origin.x -= _width
            return holder
        })
        
        let next = self.next(current: _curIndex)
        if var nextMain = self.mains.hb_object(for: next) {
            if nextMain.isKind(of: HBHolderView.self) {
                guard let newMain = hb_getMainHandler?(next) else{return}
                nextMain = newMain
            }
            minV.main = nextMain
            self.mains[next] = nextMain
        }
        
        let pre = self.pre(current: _curIndex)
        if var preMain = self.mains.hb_object(for: pre) {
            if preMain.isKind(of: HBHolderView.self) {
                guard let newMain = hb_getMainHandler?(pre) else{return}
                preMain = newMain
            }
            centerV.main = preMain
            self.mains[pre] = preMain
        }
        
        if let _ = self.holders.hb_object(for: 0) ,
            let _ = self.holders.hb_object(for: 1) ,
            let _ = self.holders.hb_object(for: 2) {
            self.holders[0] = centerV
            self.holders[1] = maxV
            self.holders[2] = minV
        }
        self.setNeedsLayout()
        self.setContentOffset(CGPoint.init(x: _width, y: 0), animated: false)
    }
    
    /** 右滚
     */
    func turnRight(_curIndex:Int) -> () {
        let minV = self.getMin()
        let maxV = self.getMax()
        if self.holders.count <= 1 { return }
        if self.holders.count == 2 {
            self.setMinMax(minV: minV, maxV: maxV, _curIndex: _curIndex)
            return
        }
        let centerV = self.getCenter()
        if self.scrollType == .default {
            self.scrollRightNormal(_curIndex: _curIndex, minV: minV, maxV: maxV, centerV: centerV)
        }else {
            if _curIndex == 0 {
                self.scrollRightLimitedAndEqualThree(range: 0 ..< 3, minV: minV, maxV: maxV, centerV: centerV)
            }else if _curIndex == (self.mains.count - 1) {
                self.scrollRightLimitedAndEqualThree(range: _curIndex - 2 ..< self.mains.count, minV: minV, maxV: maxV, centerV: centerV)
            }else {
                if self.mains.count <= 3 {
                    if var main = self.mains.hb_object(for: _curIndex) {
                        if main.isKind(of: HBHolderView.self) {
                            guard let newMain = hb_getMainHandler?(_curIndex) else{return}
                            main = newMain
                        }
                        centerV.main = main
                        self.mains[_curIndex] = main
                    }
                }else {
                    self.scrollRightNormal(_curIndex: _curIndex, minV: minV, maxV: maxV, centerV: centerV)
                }
            }
        }
        
    }
    
    /** (右滚)限制状态下个数为三的视图设置
     */
    fileprivate func scrollRightLimitedAndEqualThree(range:CountableRange<Int>,
                                                     minV:HBHolderView,
                                                     maxV:HBHolderView,
                                                     centerV:HBHolderView) -> () {
        for j in range {
            if var main = self.mains.hb_object(for: j) {
                if main.isKind(of: HBHolderView.self) {
                    guard let newMain = hb_getMainHandler?(j) else{return}
                    main = newMain
                }
                if j == range.startIndex {
                    minV.main = main
                }else if j == range.startIndex + 1 {
                    centerV.main = main
                }else {
                    maxV.main = main
                }
                self.mains[j] = main
            }
        }
    }
    
    /** (右滚)正常的轮播效果
     */
    fileprivate func scrollRightNormal(_curIndex:Int,
                                       minV:HBHolderView,
                                       maxV:HBHolderView,
                                       centerV:HBHolderView) -> () {
        // 把最左一张移到最右
        var minF = minV.frame
        minF.origin.x -= _width
        maxV.frame = minF
        
        // 创建内容
        if var main = self.mains.hb_object(for: _curIndex) {
            if main.isKind(of: HBHolderView.self) {
                guard let newMain = hb_getMainHandler?(_curIndex) else{return}
                main = newMain
            }
            minV.main = main
            self.mains[_curIndex] = main
        }
        
        self.holders = self.holders.map({ (holder) -> HBHolderView in
            holder.frame.origin.x -= _width
            return holder
        })
        
        let pre = self.pre(current: _curIndex)
        if var preMain = self.mains.hb_object(for: pre) {
            if preMain.isKind(of: HBHolderView.self) {
                guard let newMain = hb_getMainHandler?(pre) else{return}
                preMain = newMain
            }
            maxV.main = preMain
            self.mains[pre] = preMain
        }
        
        let next = self.next(current: _curIndex)
        if var nextMain = self.mains.hb_object(for: next) {
            if nextMain.isKind(of: HBHolderView.self) {
                guard let newMain = hb_getMainHandler?(next) else{return}
                nextMain = newMain
            }
            centerV.main = nextMain
            self.mains[next] = nextMain
        }
        
        if let _ = self.holders.hb_object(for: 0) ,
            let _ = self.holders.hb_object(for: 1) ,
            let _ = self.holders.hb_object(for: 2) {
            self.holders[0] = maxV
            self.holders[1] = minV
            self.holders[2] = centerV
        }
        self.setNeedsLayout()
        self.setContentOffset(CGPoint.init(x: _width, y: 0), animated: false)
    }
    
    /** 个数为二时的设置
     */
    func setMinMax(minV:HBHolderView,
                   maxV:HBHolderView,
                   _curIndex:Int) -> () {
            // 创建内容
        if var main = self.mains.hb_object(for: _curIndex) {
            if main.isKind(of: HBHolderView.self) {
                guard let newMain = hb_getMainHandler?(_curIndex) else{return}
                main = newMain
            }
            if _curIndex == 0 {
                minV.main = main
            }else {
                maxV.main = main
            }
            self.mains[_curIndex] = main
        }
        if let _ = self.holders.hb_object(for: 0) ,
        let _ = self.holders.hb_object(for: 1) {
            self.holders[0] = minV
            self.holders[1] = maxV
        }
    }
    
    /** 最大最小视图交换
     */
    func exchangeMinAndMax() -> () {
        let minV = self.getMin()
        let maxV = self.getMax()
        let minVF = minV.frame
        minV.frame = maxV.frame
        maxV.frame = minVF
        if let _ = self.holders.hb_object(for: 0) ,
        let _ = self.holders.hb_object(for: 2) {
            self.holders[0] = maxV
            self.holders[2] = minV
        }
    }
    
    //MARK: - 下一页
    fileprivate func next(current:NSInteger) -> NSInteger {
        return (current + 1) % mains.count //队列指针+1
    }
    
    //MARK: - 上一页
    fileprivate func pre(current:NSInteger) -> NSInteger {
        return (current - 1 + mains.count) % mains.count // 队列指针-1
    }
    
    /** 调整 holder 个数
     */
    func resetHolders() -> () {
        if self.mains.count < self.holders.count && self.mains.count > 0 {
            let diff = self.holders.count - self.mains.count
            switch diff {
            case 1:
                switch scrollType {
                case .default:
                    
                    break
                case .limited:
                    self.holders.removeLast()
                    break
                }
                break
            case 2:
                self.holders.removeFirst()
                self.holders.removeLast()
                break
            default:break
            }
        }
    }
}
