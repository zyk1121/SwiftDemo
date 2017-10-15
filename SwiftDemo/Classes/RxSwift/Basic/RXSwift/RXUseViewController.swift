//
//  RXUseViewController.swift
//  iTestProject
//
//  Created by 张元科 on 2017/7/9.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RXUseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        SDJGUrlRouterManager.router(sourceVC: self, toURL: NSURL(string:"sdjg://router/rx/mvvm")!)
        
    }
    
}
