//
//  RXSwiftRouter.swift
//  iTestProject
//
//  Created by 张元科 on 2017/7/9.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RXSwiftRouter: SDJGRegisterRoutersProtocol {
    static func registerModuleRouters() {
        RXBaseViewController.registerRouterVC("sdjg://router/rx/base")
        RXColdHotViewController.registerRouterVC("sdjg://router/rx/coldhot")
        RXObserverViewController.registerRouterVC("sdjg://router/rx/observe")
        RXBindUIViewController.registerRouterVC("sdjg://router/rx/bindui")
        RXUseViewController.registerRouterVC("sdjg://router/rx/use")
        RXMVVMViewController.registerRouterVC("sdjg://router/rx/mvvm")
    }
}

extension UIViewController {
    public func example(_ description: String, action: () -> ()) {
        print("\n--- \(description) example ---")
        action()
    }
    public func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: closure)
    }
    func writeSequenceToConsole<O: ObservableType>(_ name: String, sequence: O) {
        _ = sequence
            .subscribe { e in
                print("Subscription: \(name), event: \(e)")
        }
    }
}
