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
        POST_Request()
//        GET_Request()
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
    
    // post
    func POST_Request(){
        
        // https://github.com/Alamofire/Alamofire
        // http://www.jianshu.com/p/dc7e7d5b0ae6
        
        //request(host_url, method:.post, parameters : parameters)
//         let urlstring = "dateSpanNum=3&legionFlowId=-1&pageNum=1&promoteType=&promoteProvinceId=&siteId=&orderType=desc&devicePut=all&promoteProject=&pageCount=20&legionId=-1&projectLeader=&adChannel=&orderParam=random&sitePM=&userId=1000081587"
//        let urlstring = "\(host_url)type=\(top)&key=\(appkey)"
        
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: nil).responseJSON { (returnResult) in
            print("POST_Request --> post 请求 --> returnResult = \(returnResult)")
        }
        /*
        Alamofire.request(url, method:.post).responseJSON { (returnResult) in
            print("POST_Request --> post 请求 --> returnResult = \(returnResult)")
            //            switch returnResult.result.isSuccess {
            //            case true:
            //                print("数据获取成功!")
            //            case false:
            //                print(returnResult.result.error ?? Error.self)
            //            }
            
        }
 */
    }

    
    /*
     
     Parameter Encoding
     
     Alamofire supports three types of parameter encoding including: URL, JSON and PropertyList. It can also support any custom encoding that conforms to the ParameterEncoding protocol.
     
     URL Encoding
     
     The URLEncoding type creates a url-encoded query string to be set as or appended to any existing URL query string or set as the HTTP body of the URL request. Whether the query string is set or appended to any existing URL query string or set as the HTTP body depends on the Destination of the encoding. The Destination enumeration has three cases:
     
     .methodDependent - Applies encoded query string result to existing query string for GET, HEAD and DELETE requests and sets as the HTTP body for requests with any other HTTP method.
     .queryString - Sets or appends encoded query string result to existing query string.
     .httpBody - Sets encoded query string result as the HTTP body of the URL request.
     The Content-Type HTTP header field of an encoded request with HTTP body is set to application/x-www-form-urlencoded; charset=utf-8. Since there is no published specification for how to encode collection types, the convention of appending [] to the key for array values (foo[]=1&foo[]=2), and appending the key surrounded by square brackets for nested dictionary values (foo[bar]=baz).
     
     GET Request With URL-Encoded Parameters
     
     let parameters: Parameters = ["foo": "bar"]
     
     // All three of these calls are equivalent
     Alamofire.request("https://httpbin.org/get", parameters: parameters) // encoding defaults to `URLEncoding.default`
     Alamofire.request("https://httpbin.org/get", parameters: parameters, encoding: URLEncoding.default)
     Alamofire.request("https://httpbin.org/get", parameters: parameters, encoding: URLEncoding(destination: .methodDependent))
     
     // https://httpbin.org/get?foo=bar
     POST Request With URL-Encoded Parameters
     
     let parameters: Parameters = [
     "foo": "bar",
     "baz": ["a", 1],
     "qux": [
     "x": 1,
     "y": 2,
     "z": 3
     ]
     ]
     
     // All three of these calls are equivalent
     Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters)
     Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters, encoding: URLEncoding.default)
     Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
     
     // HTTP body: foo=bar&baz[]=a&baz[]=1&qux[x]=1&qux[y]=2&qux[z]=3
     JSON Encoding
     
     The JSONEncoding type creates a JSON representation of the parameters object, which is set as the HTTP body of the request. The Content-Type HTTP header field of an encoded request is set to application/json.
     
     POST Request with JSON-Encoded Parameters
     
     let parameters: Parameters = [
     "foo": [1,2,3],
     "bar": [
     "baz": "qux"
     ]
     ]
     
     // Both calls are equivalent
     Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters, encoding: JSONEncoding.default)
     Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters, encoding: JSONEncoding(options: []))
     
     // HTTP body: {"foo": [1, 2, 3], "bar": {"baz": "qux"}}
     
     */
    
    
    /*
     
     
     response()
     responseData()
     responseString(encoding: NSStringEncoding)
     responseJSON(options:NSJSONReadingOptions)
     responsePropertyList(options: NSPropertyListReadOptions)
     //2,response()
     //        Alamofire.request(main_url, method:.get, parameters: parameters).response { (response) in
     //            print("response = \(response.response)")
     //            print("data = \(response.data)")
     //            print("error = \(response.error)")
     //
     //
     //            if let data = response.data , let utf8string = String(data: data , encoding:.utf8) {
     //                print("utf8string = \(utf8string)")
     //            }
     //
     //        }
     
     
     
     
     //3,responseData()
     //        Alamofire.request(main_url, method: .get, parameters: parameters).responseData { (responseData) in
     //            debugPrint("responseData : \(responseData)")
     //
     //            if let data = responseData.data, let utf8string = String(data: data, encoding: .utf8) {
     //                print("utf8string = \(utf8string)")
     //            }
     //
     //        }
     
     
     
     //        //4,responseString
     //        Alamofire.request(main_url, method: .get, parameters: parameters).responseString { (responseString) in
     //            debugPrint("responseString() --> Sucess = \(responseString.result.isSuccess)")
     //             debugPrint("responseString : \(responseString)")
     //
     //            if let data = responseString.data , let utf8string = String(data: data, encoding: .utf8) {
     //               print("utf8string = \(utf8string)")
     //            }
     //        }
     
     
     
     // 5. responsePropertyList()  下面解释
     
     
     
     //6.在response方法中还有一个方法  参数：queue：请求队列 --> 就是默认在主线程中执行~但是我们可以自定义调度队列。
     //        let customQueue = DispatchQueue.global(qos: .utility)
     //        Alamofire.request(main_url, method: .get, parameters: parameters).responseJSON(queue: customQueue) { (returnResult) in
     //            print("请求队列 --> \(returnResult)")
     //        }
     
     作者：SHyH5
     链接：http://www.jianshu.com/p/dc7e7d5b0ae6
     來源：简书
     著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
     
     
     //下载 上传
     
     func downloadAnduploadMethod() {
     //下载文件
     Alamofire.download(host_img_url).responseJSON { (returnResult) in
     if let data = returnResult.result.value {
     let image = UIImage(data : data as! Data)
     print("\(image)")
     }else {
     print("download is fail")
     }
     }
     
     //还可以看下载进度
     Alamofire.download(host_img_url).downloadProgress { (progress) in
     print("download progress = \(progress.fractionCompleted)")
     }.responseJSON { (returnResult) in
     if let data = returnResult.result.value {
     let image = UIImage(data : data as! Data)
     print("\(image)")
     }else {
     print("download is fail")
     }
     }
     
     }
     
     作者：SHyH5
     链接：http://www.jianshu.com/p/dc7e7d5b0ae6
     來源：简书
     著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
     
     
     
     
     */
    
}
