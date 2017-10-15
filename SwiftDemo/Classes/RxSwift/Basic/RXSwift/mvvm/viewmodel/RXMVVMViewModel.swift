//
//  RXMVVMViewModel.swift
//  iTestProject
//
//  Created by 张元科 on 2017/7/12.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RXMVVMViewModel: NSObject {
    let request:RXMVVMRequest = RXMVVMRequest()
    func userLogin(name:String,password:String) -> Observable<UserModel> {
        return Observable.create({ (observer) -> Disposable in
            var dic = [String:String]()
            dic["username"] = name
            dic["password"] = password
            self.request.fetchDataWith(param: dic) { (result, error) in
                if error != nil {
                    observer.onError(error!)
                } else {
                    let um = self.convertToModel(param: result as? [String:String])
                    observer.onNext(um)
                    observer.onCompleted()
                }
            }
            // 不需要处理dispose信息时的返回值Disposables.create()，当需要中断网络请求时可以在此处处理
            return Disposables.create()
        })
    }
    
    // 将字典转换成模型
    func convertToModel(param:[String:String]?) -> UserModel {
        if param == nil {
            return UserModel()
        }
        let um = UserModel()
        um.isLogin = true
        um.userName = param?["username"] ?? ""
        um.password = param?["password"] ?? ""
        um.age = 20
        return um
    }
    
    deinit {
        print(self)
    }
}
