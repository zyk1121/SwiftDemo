//
//  AlamofireViewController.swift
//  SwiftDemo
//
//  Created by 张元科 on 2017/10/14.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit
import Alamofire

let kAdsSystemUrlProduct:String = "http://ad.sunlands.com/advertise-sv-war"

class AlamofireViewController: BaseViewController {

    let url = "\(kAdsSystemUrlProduct)/api/app/getLandpageList"
    var params:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tempStr = "dateSpanNum=3&legionFlowId=-1&pageNum=1&promoteType=&promoteProvinceId=&siteId=&orderType=desc&devicePut=all&promoteProject=&pageCount=20&legionId=-1&projectLeader=&adChannel=&orderParam=random&sitePM=&userId=1000081587"
        let tempArr = tempStr.components(separatedBy: "&")
        for item in tempArr {
            let arr = item.components(separatedBy: "=")
            if arr.count == 2 {
                params[arr[0]] = arr[1]
            }
        }
        
        // 
        GET_Request()
    }
    
    // Get请求
    func GET_Request() {
        let parameters : [String : Any] = [:]
        let tempURL = "http://www.weather.com.cn/data/cityinfo/101010100.html"
        
        //1,responseJSON
        Alamofire.request(tempURL, method: .get, parameters: parameters).responseJSON { (returnResult) in
            print("GET_Request --> GET 请求 --> returnResult = \(returnResult)")
            
//            print("firstMethod --> responseJSON() --> \(returnResult.request!)")
//            print("firstMethod --> responseJSON() --> \(returnResult.data!)")
//            print("firstMethod --> responseJSON() --> \(returnResult.result)")
            
            if let json = returnResult.result.value {
                print("firstMethod --> responseJSON --> \(json)")
                /*  返回请求地址、数据、和状态结果等信息
                 print("firstMethod --> responseJSON() --> \(returnResult.request!)")
                 print("firstMethod --> responseJSON() --> \(returnResult.data!)")
                 print("firstMethod --> responseJSON() --> \(returnResult.result)")
                 */
            }
        }
    }
    
}
