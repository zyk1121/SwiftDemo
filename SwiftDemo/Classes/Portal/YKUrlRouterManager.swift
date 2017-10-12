//
//  YKUrlRouterManager.swift
//
//  Created by 张元科 on 2017/7/5.
//  Copyright © 2017年 YK. All rights reserved.
//

import UIKit
import Foundation

/**
 YKUrlRouterManager.swift
 
 1> 实现功能：URLRoute，注册需要支持URL跳转的页面，实现根据不同的方式（push，model等方式）展示页面VC
 2> 注册入口：registerRouters方法，会在App Launch的时候调用；内部会调用不同模块的注册方法，每个模块需要一个类实现YKRegisterRoutersProtocol协议，并在registerModuleRouters方法中注册自己的VC和Method；同时在routerModules属性中添加实现了该协议的类，注意添加类的前缀（命名空间）
 3> 命名规则：YK://router/模块名/二级目录/三级目录/..?parameter=XXX
 VC栗子:
 YK://router/ykcourseproject/courselist/coursedetail
 YK://router/ykquestionbankproject/subjectdetail
 YK://router/xxx/setting/about/?parameter=123
 Method栗子：
 YK://method/模块名/二级目录/三级目录/..?parameter=XXX
 4> 注意事项：默认UIViewController已经实现了registerRouterVC方法，内部使用init()初始化，需要自定义构造器的可以重写该方法，内部修改即可
 */


// 页面跳转类型（其中none只是创建了页面并未进行跳转，满足添加子控制器的需求）
public enum YKTransfromType : Int {
    case push       = 0
    case model      = 1
    case modelNav   = 2
    case none       = 3
}

// 每个模块需要实现一个该协议的类，用于模块内部VC和method的注册
public protocol YKRegisterRoutersProtocol {
    static func registerModuleRouters()
}

// 用于注册VC Router的闭包定义，会在页面跳转的时候执行闭包
public typealias YKRouterHandler = (_ url:URL, _ transferType:YKTransfromType, _ sourceVC:UIViewController, _ userInfo:[String:Any]?, _ animated:Bool) -> UIViewController?

// 用于注册Method的闭包定义，会在执行方法的时候执行闭包
public typealias YKMethodHandler = (_ param:Any?)->(Any?)

// MARK: - 统一的页面跳转方式
public class YKUrlRouterManager
{
    // 模块实现的注册router的类名称
    private static let routerModules:[String] = []
    private static var routerMap:Dictionary<String,[YKRouterHandler]> = [:]
    private static var methodMap:Dictionary<String,YKMethodHandler> = [:]
    
    /* 路由注册的入口，需要在didFinishLaunchingWithOptions中调用 */
    public static func registerRouters()
    {
        routerMap.removeAll()
        methodMap.removeAll()
        
        for item in routerModules {
            guard let registerModule = NSClassFromString(item) else {
                continue
            }
            
            guard let registerClass = registerModule as? YKRegisterRoutersProtocol.Type else {
                continue
            }
            
            registerClass.registerModuleRouters()
        }
    }
    // MARK:页面Router注册以及调用方法
    public static func registerRouterWithHandler(handler:@escaping YKRouterHandler, prefixURL:URL)
    {
        let key = keyFromURL_router(url: prefixURL)
        let realKey = (key != nil) ? key! : kYKDefaultPortalKey
        
        if (routerMap[realKey] != nil) {
            routerMap[realKey]?.append(handler)
        } else {
            routerMap[realKey] = [YKRouterHandler]()
            routerMap[realKey]?.append(handler)
        }
    }
    
    // router
    public static func router(sourceVC:UIViewController, toURL URL:URL, transferType:YKTransfromType = .push,userInfo:[String:Any]? = nil, animated:Bool = true, completion:((_ viewController:UIViewController?,_ error:NSError?)->Void)? = nil)
    {
        var keysPool:[[String]] = [[String]]()
        let hostKey = keyFromURL_router(url: URL)
        if hostKey != nil {
            keysPool.append([hostKey!])
        }
        let leftPossibleKeys:[String]? = extractAllLeftPossibleKeysFromURL_router(URL: URL)
        if leftPossibleKeys != nil {
            if leftPossibleKeys!.count > 0 {
                keysPool.append(leftPossibleKeys!)
            }
        }
        
        var destinationViewController:UIViewController?
        for itemArray in keysPool {
            let handlers = self._combineHandlerArraysWithKeys(keys: itemArray)
            destinationViewController = self.batchPerformHandlers(handlers: handlers!, withURL: URL, transferType: transferType, withSourceViewController: sourceVC,userInfo: userInfo,animated:animated)
            if destinationViewController != nil {
                break
            }
        }
        
        var portalError:NSError?
        if destinationViewController == nil {
            portalError = NSError.init(domain: kYKRouterErrorDomian, code: -1, userInfo: nil)
        } else {
        }
        
        if completion != nil{
            completion!(destinationViewController, portalError)
        }
    }
    
    // MARK:页面Method注册以及调用方法
    public static func registerMethodWithHandler(handler:@escaping YKMethodHandler, prefixURL:URL)
    {
        let key = keyFromURL_router(url: prefixURL)
        let realKey = (key != nil) ? key! : kYKDefaultMethodKey
        methodMap[realKey] = handler
    }
    
    // method call
    public static func callMethod(withURL:URL,param:Any?,completion:((_ result:Any?,_ error:NSError?)->Void)?) {
        let key = keyFromURL_router(url: withURL)
        let realKey = (key != nil) ? key! : kYKDefaultMethodKey
        guard let methodHandler = methodMap[realKey] else {
            if completion != nil {
                let methodError = NSError.init(domain: kYKMethodErrorDomian, code: -1, userInfo: nil)
                completion!(nil,methodError)
            }
            return
        }
        let result = methodHandler(param)
        
        if completion != nil {
            completion!(result,nil)
        }
    }
    
    // MARK:私有类方法
    private static func _combineHandlerArraysWithKeys(keys:[String]?)->[YKRouterHandler]?
    {
        if keys == nil {
            return nil
        }
        var tempArray:[YKRouterHandler] = [YKRouterHandler]()
        for key in keys! {
            if((routerMap[key] != nil) && (routerMap[key]?.count)! > 0) {
                tempArray += routerMap[key]!
            }
        }
        return tempArray
    }
    
    private static func batchPerformHandlers(handlers:[YKRouterHandler],withURL URL:URL,transferType:YKTransfromType,withSourceViewController sourceVC:UIViewController,userInfo:[String:Any]?,animated:Bool)->UIViewController?
    {
        if handlers.count == 0 {
            return nil
        }
        var viewController:UIViewController?
        
        for item in handlers {
            viewController = item(URL, transferType, sourceVC,userInfo,animated)
            if viewController != nil {
                break
            }
        }
        return viewController
    }
}

// MARK: - 全局方法
func keyFromURL_router(url:URL?)->String?
{
    guard let url = url else {
        return nil
    }
    return "\(url.scheme!)://\(url.host!)\(url.path)"
}

func extractAllLeftPossibleKeysFromURL_router(URL:URL?)->[String]?
{
    guard let url = URL else {
        return nil
    }
    var pathItems:[String] = (url.path.components(separatedBy: "/"))
    if pathItems.count <= 1 {
        return nil
    }
    pathItems.removeFirst()
    pathItems.removeLast()
    var pathArray:[String] = []
    for item in pathItems {
        let last = pathArray.last
        
        let prefix : String = (last != nil) ? last! : ""
        pathArray.append("\(prefix)/\(item)")
    }
    if pathArray.count <= 0 {
        return nil
    }
    pathArray.reverse()
    
    var results:[String] = []
    // 匹配策略是最长的先被匹配，所以倒序遍历
    for item in pathArray {
        results.append("\(url.scheme!)://\(url.host!)\(item)")
    }
    
    return results
}


// MARK: - URL扩展
extension URL
{
    public func hasSameTrunkWithURL(_ url:URL) -> Bool {
        return (self.path == url.path) && (self.host == url.host) && (self.scheme == url.scheme)
    }
}

// MARK: - UIViewController扩展(Router & Method)
extension UIViewController {
    
    // VC注册，子类需要的话可以重写
    open class func registerRouterVC(_ routerURL:String)
    {
        guard let tempRouterURL = URL(string:routerURL) else {
            return
        }
        YKUrlRouterManager.registerRouterWithHandler(handler: { (transferURL:URL, transferType:YKTransfromType, sourceVC:UIViewController, userInfo:[String:Any]?, animated:Bool) -> UIViewController? in
            if transferURL.hasSameTrunkWithURL(tempRouterURL) {
                let viewController = self.init()
                viewController.setRouterInfo(userInfo: userInfo)
                if transferType == .push {
                    if let nav = sourceVC.navigationController {
                        // navController
                        nav.pushViewController(viewController, animated: animated)
                    } else {
                        // modal nav vc
                        sourceVC.modelVC(viewController, true, animated)
                    }
                } else if transferType == .model {
                    sourceVC.modelVC(viewController, false, animated)
                }else if transferType == .modelNav {
                    sourceVC.modelVC(viewController, true, animated)
                } else {
                }
                return viewController
            } else {
                return nil
            }
        }, prefixURL: tempRouterURL)
    }
    
    // 弹出视图(present)
    open func modelVC(_ viewController:UIViewController,_ navModel:Bool = false, _ animated:Bool = true) {
        if (self.presentedViewController != nil) {
            // 有弹出视图，获取当前最顶部视图，再model(如果还不能model，可以push)
            if let topVC = self.routerTopVC() {
                if (topVC.presentedViewController == nil) {
                    // 可以弹出视图
                    if navModel {
                        topVC.presentNavControllerWithVC(viewController,animated)
                    } else {
                        topVC.present(viewController, animated: animated, completion: nil)
                    }
                } else {
                    // 还不能弹出视图(尝试push)
                    if (self.navigationController != nil) {
                        self.navigationController?.pushViewController(viewController, animated: animated)
                    } else if (topVC.navigationController != nil) {
                        topVC.navigationController?.pushViewController(viewController, animated: animated)
                    }
                }
            }
        } else {
            // 无弹出视图
            if navModel {
                self.presentNavControllerWithVC(viewController, animated)
            } else {
                self.present(viewController, animated: animated, completion: nil)
            }
        }
    }
    // Model带导航控制器的VC
    open func presentNavControllerWithVC(_ viewController:UIViewController, _ animated:Bool = true)
    {
        var naviModelVC:UIViewController?
        // 1.导航控制器类名称(命名空间)
        let clsName = "YKNavigationController"
        // 2.通过命名空间和类名转换成类
        let cls : AnyClass? = NSClassFromString(clsName)
        // swift 中通过Class创建一个对象,必须告诉系统Class的类型
        if let clsType = cls as? UINavigationController.Type {
            // 3.通过Class创建对象
            let navVC = clsType.init(rootViewController: viewController)
            // 导航控制器支持看到底部视图，需要自己设置导航控制器view的背景颜色
            navVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            naviModelVC = navVC
        } else {
            // 不添加导航控制器，直接model当前的VC
            naviModelVC = viewController
        }
        // 4.直接model当前的VC
        if naviModelVC != nil {
            self.present(naviModelVC!, animated: animated, completion: nil)
        } else {
            self.present(viewController, animated: animated, completion: nil)
        }
    }
    
    // 当前视图VC
    open func routerTopVC() -> UIViewController? {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            return routerVisibleVC(rootVC)
        }
        return  nil
    }
    open func routerVisibleVC(_ vc:UIViewController) -> UIViewController {
        if vc is UITabBarController {
            return routerVisibleVC((vc as! UITabBarController).selectedViewController!)
        } else if vc is UINavigationController {
            return routerVisibleVC((vc as! UINavigationController).visibleViewController!)
        } else if vc.presentedViewController != nil {
            return routerVisibleVC(vc.presentedViewController!)
        } else if vc.childViewControllers.count > 0 {
            return routerVisibleVC(vc.childViewControllers.last!)
        }
        return vc
    }
    
    // 子类需要处理userinfo的时候重写
    open func setRouterInfo(userInfo:[String:Any]?) {
        
    }
    // 方法注册，子类需要的话可以重写
    open class func registerMethod(_ methodURL:String) {
        guard let tempMethodURL = URL(string:methodURL) else {
            return
        }
        YKUrlRouterManager.registerMethodWithHandler(handler: { (param:Any?) -> (Any?) in
            return self.callRouterMethod(param: param)
        }, prefixURL: tempMethodURL)
    }
    // 默认执行的方法调用，子类需要的话可以重写
    open class func callRouterMethod(param:Any?) -> Any? {
        return nil
    }
}

// MARK: - 导航控制器自定义
public class YKNavigationController: UINavigationController {
    
    override public var shouldAutorotate: Bool{
        return self.viewControllers.last!.shouldAutorotate
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return self.viewControllers.last!.supportedInterfaceOrientations
    }
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return self.viewControllers.last!.preferredInterfaceOrientationForPresentation
    }
}

// MARK: - 私有定义
// 默认注册Portal的Key
fileprivate let kYKDefaultPortalKey = "defaultPortalKeyYK";
// 默认注册Method的Key
fileprivate let kYKDefaultMethodKey = "defaultMethodKeyYK";
// Router默认错误Domain
fileprivate let kYKRouterErrorDomian = "com.sunlands.router.error";
// Method默认错误Domain
fileprivate let kYKMethodErrorDomian = "com.sunlands.method.error";

