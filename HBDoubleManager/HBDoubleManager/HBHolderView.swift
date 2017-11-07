//
//  HBHolderView.swift
//  doubleManager
//
//  Created by jianghongbao on 2017/11/2.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class HBHolderView: UIView {
    private struct AssociatedKeys {
        static var main = "HBHolderView_main"
    }
    
    open var main : UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.main) as? UIView
        }
        
        set {
            if let newValue = newValue {
                _ = self.subviews.map({ (v) -> Void in
                    v.removeFromSuperview()
                })
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.main,
                    newValue as UIView?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                newValue.frame = self.bounds
                self.addSubview(newValue)
            }
        }
    }

    //MARK: - Interface
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = HBRGB(0xfafafa)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let main = self.main {
            main.frame = self.bounds
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

