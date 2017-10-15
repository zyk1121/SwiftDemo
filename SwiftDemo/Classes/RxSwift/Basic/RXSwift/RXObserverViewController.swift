//
//  RXObserverViewController.swift
//  iTestProject
//
//  Created by 张元科 on 2017/7/9.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


 var testGloble:TestObject = TestObject()
//var tempArray:[TestObject] = [TestObject]()

class RXObserverViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        test_obserable0()
        test_obserable1()
        test_obserable2()
        
        //  // 没有对象引用当前对象当前对象就能释放
    }
    
    
    var dispt : Disposable?
    
    func test_obserable0() {
        // 同步执行，无循环引用（同一个线程，主线程）
        // obeserver->link->closure->self->dispt(obeserver)
        // completed的时候断开了 (没有了循环引用)obeserver->link->
        // closure->self->dispt(obeserver)
        dispt = Observable<Int>.of(1, 2, 3).subscribe { (event) in
            self.test_dealloced()// 无循环引用（）
            print(event)
        }
        
//        dispt.dispose()
        
        
        test_obserable00()
    }
    
    func test_obserable00()
    {
        // 结合test_obserable0分析是否有循环引用
        let myJust = { (singleElement: Int) -> Observable<Int> in
            return Observable.create({ (observer) -> Disposable in
                observer.on(.next(singleElement))
//                observer.on(.completed) // 执行这行代码的话不会有循环引用
                // 不需要处理dispose信息时的返回值
                return Disposables.create()
            })
        }
        dispt = myJust(5)
            .subscribe { event in
                self.test_dealloced()// 有循环引用
                print(event)
        }
        dispt?.dispose()// 这行代码可以解除循环引用 或者使用weak
    }
    
    
    let disposeBag  = DisposeBag()
    var test:TestObject = TestObject()
    
    func test_obserable1() {
        // 通知(swift中对象释放之后监听自动移除)
        NotificationCenter.default.addObserver(testGloble, selector: #selector(testfunc(noti:)), name: NSNotification.Name.init(rawValue: "123456"), object: nil)
//        tempArray.append(testGloble)
//        //
//        testGloble = TestObject()
        NotificationCenter.default.rx.notification( NSNotification.Name.init(rawValue: "123456")).subscribe { (event) in
            print(event)
            self.test_dealloced()// 循环引用（提前调用ddd.dispose() 或者 weak解决）
        }.addDisposableTo(disposeBag)
        // 没有.addDisposableTo(disposeBag)也会有循环引用
//        ddd.dispose() // 能解除循环引用
        /*
         return Disposables.create {
         self.base.removeObserver(nsObserver)
         }
         
         
 */
        /*
        
        let dispose = NotificationCenter.default.rx.notification( NSNotification.Name.init(rawValue: "123456")).subscribe { (event) in
            print(event)
            self.test_dealloced()// 循环引用
            }
        dispose.dispose()// 不addDisposableTo(disposeBag)，这样也能解除循环引用
 */
        
        // 循环引用分析：rx->noti->block->self   dispose->rx
        // addDisposableTo(disposeBag)  : self->disposeBag->dispose
    }
    
    func test_dealloced() {
        print(#function)
    }
    
    private var myContext = 0
    func test_obserable2(){
        
        test.stu = Student()
//        addObserver(test, forKeyPath: "testStr", options: .new, context: &myContext)
        
        /*
        test.rx.observe(String.self, "testStr").subscribe {[weak self] (event) in
            print(event)
//            self.test_dealloced()// 循环引用
            self?.test_dealloced()// 解除循环引用
        }.addDisposableTo(disposeBag)
        test.testStr = "hello"
 
 */
        
        /*
         _ = root.rx.observeWeakly(String.self, "property")
         .subscribe(onNext: { n in
         latest = n
         })
         
         _ = root.rx.deallocated
         .subscribe(onCompleted: {
         isDisposed = true
         })

         
         */
        test.rx.deallocated.subscribe { (event) in
            print(event)
        }
        // .addDisposableTo(disposeBag)之后会先执行dispose后不再进入block
        
        // 不ok
//        test.rx.observe(String.self, "stu.name").subscribe { (event) in
//            print(event)
//        }.addDisposableTo(disposeBag)
        
        
        // 循环引用分析
        
        let dis = test.rx.observe(String.self, "testStr").subscribe {(event) in
            print(event)
//                        self.test_dealloced()// 循环引用/ 循环引用（提前调用dis.dispose() 或者 weak解决）
//            self?.test_dealloced()// 解除循环引用
            }
        test.testStr = "hello"
//        dis.dispose()
    
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            if let newValue = change?[NSKeyValueChangeKey.newKey] {
                print("str changed: \(newValue)")
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }

    }
    
    //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "123456"), object: nil, userInfo: nil)
        
        test.testStr = "hello2"
        
//        test.stu?.name = "abcd"
    }
    
    func testfunc(noti:Notification) {
        print(#function)
    }
    
    deinit {
         // 通知(swift中对象释放之后监听自动移除)
//        NotificationCenter.default.removeObserver(self)
//    self.removeObserver(test, forKeyPath: "testStr")
        print(self)
    }
}

// 自定义测试类
class Company:NSObject {
    var comName:String?
}

class Person:NSObject {
    dynamic var name:String?
    var age:Int = 0
    var comp:Company?
}

class Student:Person {
    var classNo:Int = 0
}


class TestObject:NSObject {
    dynamic var stu:Student?
    dynamic var testStr:String?
    // dynamic 实现KVO要添加的修饰符
    
    func testfunc(noti:Notification) {
        print(#function)
    }
}

/*
 
 swift Defer语法
 标签： swiftdefer语法
 2016-04-12 10:00 470人阅读 评论(0) 收藏 举报
 分类： Swift（10）
 版权声明：本文为博主原创文章，转载请附上原文地址。
 文章转载自：
 http://www.jianshu.com/p/eb718439551f
 
 
 //defer 语句
 /*
 延缓推迟,相当于把操作放入栈中，后加入的先执行
 */
 
 /*
 分析代码:
 
 定位到目录并打开指定文件夹,倘若打开文件夹失败则结束函数。
 主要到defer的用法，这条语句并不会马上执行，而是被推入栈中，直到函数结束时才再次被调用。
 打开文件，倘若失败则结束函数。
 defer内容关闭文件，这条语句一样不会被马上执行，而是推入栈中，此时它位于defer{closeDirectory()}语句的上方，直到函数结束时才再次被调用。
 倘若一切都顺利，函数运行到最后了，开始从栈中依次弹出方才推入的defer语句，首先是closeFile(),其次是closeDirectory()。确实当我们处理完文件，需要先关闭文件，再关闭文件夹。如果文件打开失败，则直接执行关闭文件夹
 */
 
 func doSthWithDefer() {
 //
 openDirectory()
 defer {closeDirectory() }
 openFile()
 defer { closeFile() }
 }
 
 //打开目录
 func openDirectory() {}
 //关闭目录
 func closeDirectory() {}
 //打开文件
 func openFile() {}
 //关闭文件
 func closeFile() {}
 
 关于defer的作用域
 /*
 并不是函数结束时开始执行defer栈推出操作，而是每当一个作用域结束就进行该作用域defer执行
 函数分析：
 当参数name==""时，先执行print("1-1")，之后进入if判断语句，进入作用域2，defer {print("2-2")}是等作用域2执行完成之后再执行，所以作用域2的输出顺序是2-1、2-3、2-2
 接着执行print("1-2")，输出1-2
 defer {print("1-3")}，把print("1-3")操作加入作用域1的栈中，执行print("1-4")，输出1-4，执行print("1-5")，输出1-5
 defer {print("1-6")}，把print("1-6")操作加入作用域1的栈中
 作用域1完成，执行栈中的defer操作，后进先出的执行顺序，输出1-6、1-3
 */
 func lookforSth(name:String) {
 //作用域1整个函数是作用域
 
 print("1-1")
 
 if name == "" {
 //作用域2 if作用域
 print("2-1")
 defer {
 print("2-2")
 }
 print("2-3")
 }
 print("1-2")
 
 defer {
 print("1-3")
 }
 print("1-4")
 
 if name == "hello" {
 //作用域3
 print("3-1")
 defer {
 print("3-2")
 }
 print("3-3")
 
 defer {
 print("3-4")
 }
 }
 print("1-5")
 defer {
 print("1-6")
 }
 }
 

 
 
 */

/*
 
 extension ObservableType {
 /**
 Subscribes an event handler to an observable sequence.
 
 - parameter on: Action to invoke for each event in the observable sequence.
 - returns: Subscription object used to unsubscribe from the observable sequence.
 */
 public func subscribe(_ on: @escaping (Event<E>) -> Void)
 -> Disposable {
 let observer = AnonymousObserver { e in
 on(e)
 }
 return self.subscribeSafe(observer)
 }

 
 extension ObservableType {
 /// All internal subscribe calls go through this method.
 fileprivate func subscribeSafe<O: ObserverType>(_ observer: O) -> Disposable where O.E == E {
 return self.asObservable().subscribe(observer)
 }
 }

 
 class Producer<Element> : Observable<Element> {
 override init() {
 super.init()
 }
 
 override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == Element {
 if !CurrentThreadScheduler.isScheduleRequired {
 // The returned disposable needs to release all references once it was disposed.
 let disposer = SinkDisposer()
 let sinkAndSubscription = run(observer, cancel: disposer)
 disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)
 
 return disposer
 }
 else {
 return CurrentThreadScheduler.instance.schedule(()) { _ in
 let disposer = SinkDisposer()
 let sinkAndSubscription = self.run(observer, cancel: disposer)
 disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)
 
 return disposer
 }
 }
 }
 
 
 
 final fileprivate class AnonymousObservable<Element> : Producer<Element> {
 typealias SubscribeHandler = (AnyObserver<Element>) -> Disposable
 
 let _subscribeHandler: SubscribeHandler
 
 init(_ subscribeHandler: @escaping SubscribeHandler) {
 _subscribeHandler = subscribeHandler
 }
 
 override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
 let sink = AnonymousObservableSink(observer: observer, cancel: cancel)
 let subscription = sink.run(self)
 return (sink: sink, subscription: subscription)
 }


 
 
 // 销毁
 
    dis.dispose()
 
 
 func dispose() {
 let previousState = AtomicOr(DisposeState.disposed.rawValue, &_state)
 
 if (previousState & DisposeStateInt32.disposed.rawValue) != 0 {
 return
 }
 
 if (previousState & DisposeStateInt32.sinkAndSubscriptionSet.rawValue) != 0 {
 guard let sink = _sink else {
 rxFatalError("Sink not set")
 }
 guard let subscription = _subscription else {
 rxFatalError("Subscription not set")
 }
 
 sink.dispose()
 subscription.dispose()
 
 _sink = nil
 _subscription = nil
 }
 }
 
 // 观察者销毁（观察者拥有闭包）
 
 final class AnonymousObserver<ElementType> : ObserverBase<ElementType> {
 typealias Element = ElementType
 
 typealias EventHandler = (Event<Element>) -> Void
 
 private let _eventHandler : EventHandler
 
 init(_ eventHandler: @escaping EventHandler) {
 #if TRACE_RESOURCES
 let _ = Resources.incrementTotal()
 #endif
 _eventHandler = eventHandler
 }
 
 override func onCore(_ event: Event<Element>) {
 return _eventHandler(event)
 }
 
 #if TRACE_RESOURCES
 deinit {
 let _ = Resources.decrementTotal()
 }
 #endif
 deinit {
 print("dddd")
 }
 }
 
 */
