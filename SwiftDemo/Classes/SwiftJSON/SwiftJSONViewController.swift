//
//  SwiftJSONViewController.swift
//  SwiftDemo
//
//  Created by 张元科 on 2017/10/12.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SwiftJSONViewController: BaseViewController {

    var label = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor.red
        label.frame = CGRect(x: 0, y: 100, width: 320, height: 100)
        label.textColor = UIColor.red
        view.addSubview(label)
        title = "效率很低，不使用"
        GET_Request()
    }
    
    // Get请求
    func GET_Request() {
        let parameters : [String : Any] = [:]
        let tempURL = "http://www.weather.com.cn/data/cityinfo/101010100.html"
        //1,responseJSON
        Alamofire.request(tempURL, method: .get, parameters: parameters).responseJSON { (returnResult) in
            
            if let json = returnResult.result.value as? [String:Any]{
                let swiftjsonData = JSON(json)
//                print(swiftjsonData)
                /* 性能很差：
                时间 8s CPU 100% 内存增加几十兆（应该基本不增加），不能使用（相比ObjectMapper 循环10000次 基本无感）
                for item in (0 ..< 10000) {
                     let dd = "\(swiftjsonData["weatherinfo"]["city"] ) 的天气：\(swiftjsonData["weatherinfo"]["weather"] ) 更新时间：\(swiftjsonData["weatherinfo"]["ptime"] )"
                }
              */
                
                DispatchQueue.main.async {
                    self.label.text = "\(swiftjsonData["weatherinfo"]["city"] ) 的天气：\(swiftjsonData["weatherinfo"]["weather"] ) 更新时间：\(swiftjsonData["weatherinfo"]["ptime"] )"
                }
            }
        }
    }
}
