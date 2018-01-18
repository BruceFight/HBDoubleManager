//
//  ViewController.swift
//  HBDoubleManager
//
//  Created by jianghongbao on 2017/11/7.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    fileprivate let colors = [UIColor.red,.blue,.black,.orange,.yellow,.green,.gray]
    var manager : HBDoubleManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = HBDoubleManager.init(frame: view.bounds, view: view)
        manager?.scrollType = .limited
        let label = UIButton()
        label.setTitle("external", for: .normal)
        label.setTitleColor(.red, for: .normal)
        label.addTarget(self, action: #selector(dosomething), for: .touchUpInside)
        manager?.addExternal(external:label)
        view.addSubview(manager!)
        
        manager?.hb_getMain = {[weak self](tag) in
            let view = UIView()
            view.backgroundColor = self?.colors[tag]
            return view
        }
        
        manager?.hb_topicClicked = {[weak self](tag) in
            print("❤️ --- \(tag)")
        }
        
        manager?.hb_getTop(height: 55,
                           head: 0,
                           position: .left,
                           inner: 20,
                           outer: 20,
                           global: 15,
                           titles: ["中","国"],//,"共","产","党","万","岁"
                           images: nil,
                           h_images: nil,
                           textColors: nil,
                           h_textColors: nil)
        
    }
    
    @objc func dosomething() -> () {
        manager?.hb_showRedView(tag: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

