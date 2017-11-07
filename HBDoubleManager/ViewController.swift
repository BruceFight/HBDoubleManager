//
//  ViewController.swift
//  HBDoubleManager
//
//  Created by jianghongbao on 2017/11/7.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var manager : HBDoubleManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = HBDoubleManager.init(frame: self.view.bounds, view: view)
        let label = UIButton()
        label.setTitle("external", for: .normal)
        label.setTitleColor(.red, for: .normal)
        label.addTarget(self, action: #selector(dosomething), for: .touchUpInside)
        manager?.addExternal(external:label)
        self.view.addSubview(manager!)
        
        manager?.HB_getMain = {[weak self](tag) in
            let colors = [UIColor.red,.blue,.black,.orange,.yellow,.green,.gray]
            let view = UIView()
            view.backgroundColor = colors[tag]
            return view
        }
        
        manager?.HB_topicClicked = {[weak self](tag) in
            print("❤️ --- \(tag)")
        }
        
        manager?.HB_setMain(height: 55,
                            headIndex: 3,
                            position: .left,
                            topicInnerMargin: 20,
                            topicOuterMargin: 20,
                            titles: ["中","国","共","产","党","万","岁"],
                            images: nil,
                            highImages: nil,
                            textColors: nil,
                            highTextColors: nil,
                            globalMargin: 15)
        
        
    }
    
    @objc func dosomething() -> () {
        manager?.HB_showRedView(tag: 0)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

