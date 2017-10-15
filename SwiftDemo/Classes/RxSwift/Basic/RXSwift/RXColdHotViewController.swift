//
//  RXColdHotViewController.swift
//  iTestProject
//
//  Created by 张元科 on 2017/7/9.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RXColdHotViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        test_coldObserable()
        test_hotObserable()
    }
    
    // http://www.jianshu.com/p/69865fafa4a0
    
    /*
     
     关于冷热 Observable 的异同，跟冷热信号的异同是类似的，网上已经有很多资料了，我就不详细展开了。简而言之，Cold Observable（以下简称 CO）只有在被订阅的时候才会发射事件，每次有新的订阅者都会把之前所有的事件都重新发射一遍； Hot Observable（以下简称 HO）则是实时的，一旦有新的事件它就发射，不管有没有被订阅，而新的订阅者并不会接收到订阅前已经发射过的事件(实在想接收之前的也不是不可以，但是序列不会重新发送，只是发送之前已经发送过的值)。
     
     HO 有点“推模型”的意思，它会 push 新的事件过来，一些实时性要求较高的场景（譬如各种响应事件、通知消息等）
     
     而 CO 则有点“拉模型”的意思，只在需要的时候去 pull（subscribe），所以在封装网络请求和一些异步操作的时候，可以使用 CO。
     
     */
    /*
     一般的Obserable都是冷序列（信号）
     
     而
     
     Subject：是热序列（信号）
     PublishSubject 
     ReplaySubject
     BehaviorSubject
     Variable 是基于 BehaviorSubject 的一层封装，它的优势是：不会被显式终结。即：不会收到 .Completed 和 .Error 这类的终结事件，它会主动在析构的时候发送 .Complete 。
     */
    let disposeBag:DisposeBag = DisposeBag()
    // CO
    func test_coldObserable() {
        example("create") {
            
            // 不需要处理dispose信息时的返回值
            let myJust = { (singleElement: Int) -> Observable<Int> in
                return Observable.create({ (observer) -> Disposable in
                    observer.on(.next(singleElement))
                    observer.on(.completed)
                    // 不需要处理dispose信息时的返回值
                    return Disposables.create()
                })
            }
            let subscription = myJust(5)
                .subscribe { event in
                    print(event)
            }
            
//            print(subscription) SinkDisposer
            /*
             SinkDisposer
             private var _sink: Disposable? = nil
             private var _subscription: Disposable? = nil
             */
            subscription.addDisposableTo(disposeBag)
        }
        
        
        example("create2") {
            
            let disposeProcessCode  = {()->() in
                print("自定义信号dispose的回调代码")
                //可以dispose时取消网络请求处理
            }
            // 不需要处理dispose信息时的返回值
            let myJust = { (singleElement: Int) -> Observable<Int> in
                return Observable.create({ (observer) -> Disposable in
                    observer.on(.next(singleElement))
//                    observer.on(.completed)
                    // 不需要处理dispose信息时的返回值Disposables.create()
                    return Disposables.create(with: disposeProcessCode)
                })
            }
            let dispose = myJust(5)
                .subscribe { event in
                    print(event)
            }
            
            dispose.dispose()
            
            //            print(dispose) SinkDisposer
            /*
             SinkDisposer
             private var _sink: Disposable? = nil// 订阅者事件
             private var _subscription: Disposable? = nil // 自定义取消时的事件
             */
            dispose.addDisposableTo(disposeBag)
        }

    }
    
    // HO
    // 比如有多个定位需求：订阅定位序列值可以使用HO
    func test_hotObserable()
    {
        //        接下来是关于 Subject 的内容。 Subject 可以看做是一种代理和桥梁。它既是订阅者又是订阅源，这意味着它既可以订阅其他 Observable 对象，同时又可以对它的订阅者们发送事件。
        // PublishSubject 会发送订阅者从订阅之后的事件序列。
        example("PublishSubject") {
            let subject = PublishSubject<String>()
            writeSequenceToConsole("1", sequence: subject)
            subject.on(.next("a"))
            subject.on(.next("b"))
            writeSequenceToConsole("2", sequence: subject)
            subject.on(.next("c"))
            subject.on(.next("d"))
        }
        // ReplaySubject 在新的订阅对象订阅的时候会补发所有已经发送过的数据队列， bufferSize 是缓冲区的大小，决定了补发队列的最大值。如果 bufferSize 是1，那么新的订阅者出现的时候就会补发上一个事件，如果是2，则补两个，以此类推。
        example("ReplaySubject") {
            let subject = ReplaySubject<String>.create(bufferSize: 1)
            writeSequenceToConsole("1", sequence: subject)
            subject.on(.next("a"))
            subject.on(.next("b"))
            writeSequenceToConsole("2", sequence: subject)
            subject.on(.next("c"))
            subject.on(.next("d"))
        }
        // BehaviorSubject 在新的订阅对象订阅的时候会发送最近发送的事件，如果没有则发送一个默认值。
        
        example("BehaviorSubject") {
            let subject = BehaviorSubject(value: "z")
            writeSequenceToConsole("1", sequence: subject)
            subject.on(.next("a"))
            subject.on(.next("b"))
            writeSequenceToConsole("2", sequence: subject)
            subject.on(.next("c"))
            subject.on(.completed)
        }
        
        /*
         
         Variable
         
         
         Variable 是基于 BehaviorSubject 的一层封装，它的优势是：不会被显式终结。即：不会收到 .Completed 和 .Error 这类的终结事件，它会主动在析构的时候发送 .Complete 。
         */
        
        example("Variable") {
            let variable = Variable<String>("z")
            writeSequenceToConsole("1", sequence: variable.asObservable())
            variable.value = "a"
            variable.value = "b"
            writeSequenceToConsole("2", sequence: variable.asObservable())
            variable.value = "c"
        }
        
        /*
         
         PublishSubject, ReplaySubject和BehaviorSubject是不会自动发出completed事件的。
         
         Variable
         
         Variable是BehaviorSubject一个包装箱，就像是一个箱子一样，使用的时候需要调用asObservable()拆箱，里面的value是一个BehaviorSubject，他不会发出error事件，但是会自动发出completed事件。
         */
        
    }

}
