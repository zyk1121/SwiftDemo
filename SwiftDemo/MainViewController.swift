//
//  ViewController.swift
//  SwiftDemo
//
//  Created by 张元科 on 2017/10/12.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "Swift3.0"
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        YKUrlRouterManager.router(sourceVC: self, toURL: URL(string:"YK://router/swiftjson/SwiftJSONViewController")!)
    }
}

