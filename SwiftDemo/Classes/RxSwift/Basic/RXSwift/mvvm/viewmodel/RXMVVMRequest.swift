//
//  RXMVVMRequest.swift
//  iTestProject
//
//  Created by 张元科 on 2017/7/12.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit

class RXMVVMRequest: NSObject {
    func fetchDataWith(param:[String:String],completion:((_ result:Any?,_ error:Error?)->Void)?) {
        
        guard let username = param["username"],
            let password = param["password"] else {
                if completion != nil {
                    completion!(nil,NSError(domain: "dddddd", code: -1, userInfo: nil))
                }
            return
        }
    
        // 模拟网络请求
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5) {
            var dic:[String:String] = [:]
            dic["username"] = username
            dic["password"] = password
            if completion != nil {
                completion!(dic,nil)
            }
        }
    }
    
    deinit {
        print(self)
    }
}
