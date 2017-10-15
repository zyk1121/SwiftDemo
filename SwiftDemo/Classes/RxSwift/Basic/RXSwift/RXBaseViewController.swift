//
//  RXBaseViewController.swift
//  iTestProject
//
//  Created by 张元科 on 2017/7/9.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RXBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        test_rxfunction()
        test_subject()
        test_transform()
        test_filter()
        test_combining()
        test_error()
        test_conditional()
    }
    // https://github.com/ReactiveX/RxSwift
    // https://blog.callmewhy.com/2015/09/21/rxswift-getting-started-0/
    // http://www.jianshu.com/p/69865fafa4a0
    /*主要介绍了 Rx 的基础： Observable 。 Observable<Element> 是观察者模式中被观察的对象，相当于一个事件序列 (GeneratorType) ，会向订阅者发送新产生的事件信息。事件信息分为三种：
     
     .Next(value) 表示新的事件数据。
     .Completed 表示事件序列的完结。
     .Error 同样表示完结，但是代表异常导致的完结。
     */
    let disposeBag:DisposeBag = DisposeBag()
    // MARK: - 测试RX基础功能
    func test_rxfunction() {
//        empty 是一个空的序列，它只发送 .Completed 消息。
        example("empty") {
            let emptySequence: Observable<Int> = Observable<Int>.empty()
            _ = emptySequence
                .subscribe { event in
                    print(event)
            }
        }
        
        example("never") {
            // never 是没有任何元素、也不会发送任何事件的空序列。
            let neverSequence: Observable<String> = Observable<String>.never()
            let subscription = neverSequence
                .subscribe { _ in
                    print("This block is never called.")
            }
            subscription.addDisposableTo(disposeBag)
        }
        // just 是只包含一个元素的序列，它会先发送 .Next(value) ，然后发送 .Completed(不需要addDisposableTo) 。
        example("just") {
            let singleElementSequence = Observable<Int>.just(32)
            let subscription = singleElementSequence
                .subscribe { event in
                    print(event)
            }
            subscription.addDisposableTo(disposeBag)
        }
        
        // of 可以把一系列元素转换成事件序列。(不需要addDisposableTo)
        example("of") {
            let sequenceOfElements/* : Observable<Int> */ = Observable<Int>.of(0, 1, 2, 3)
            let subscription = sequenceOfElements
                .subscribe { event in
                    print(event)
            }
            subscription.addDisposableTo(disposeBag)
        }
        
        
        example("from") {
//            let sequenceFromArray = [1, 2, 3, 4, 5].asObservable()
//            let subscription = sequenceFromArray
//                .subscribe { event in
//                    print(event)
//            }
            
            // from就是从集合中创建sequence，例如数组，字典或者Set
            Observable<Int>.from([1,2,3,4,5]).subscribe({ (event) in
                print(event)
            })
        }
 
        
        // create 可以通过闭包创建序列，通过 .on(e: Event) 添加事件。
        example("create") {
            
            let myJust = { (singleElement: Int) -> Observable<Int> in
                return Observable.create({ (observer) -> Disposable in
                    observer.on(.next(singleElement))
                    observer.on(.completed)
                    return Disposables.create()
                })
            }
            let subscription = myJust(5)
                .subscribe { event in
                    print(event)
            }
            subscription.addDisposableTo(disposeBag)
        }
        
//        failWith 创建一个没有元素的序列，只会发送失败 (.Error) 事件。
        
        example("failWith") {
            let error = NSError(domain: "Test", code: -1, userInfo: nil)
            let erroredSequence: Observable<Int> =  Observable<Int>.error(error)
            let subscription = erroredSequence
                .subscribe { event in
                    print(event)
            }
            subscription.addDisposableTo(disposeBag)
        }
        
//        deferred 会等到有订阅者的时候再通过工厂方法创建 Observable 对象，每个订阅者订阅的对象都是内容相同而完全独立的序列。
        
        example("deferred") {
            let deferredSequence: Observable<Int> = Observable<Int>.deferred {
                print("creating")
                return Observable.create({ (observer) -> Disposable  in
                    print("emmiting")
                    observer.on(.next(0))
                    observer.on(.next(1))
                    observer.on(.next(2))
                    return Disposables.create()
                }
            )}
            print("go")
            deferredSequence
                .subscribe { event in
                    print(event)
            }
            deferredSequence
                .subscribe { event in
                    print(event)
            }
        }
        
        // doOn我感觉就是在直接onNext处理时候，先执行某个方法，doOnNext( :)方法就是在subscribe(onNext:)前调用，doOnCompleted(:)就是在subscribe(onCompleted:)前面调用的。
        example("doOn") { 
            let disposeBag = DisposeBag()
            
            Observable.of("1", "2", "3", "4")
                .do(onNext: {
                    print("Intercepted:", $0) }, onError: { print("Intercepted error:", $0) }, onCompleted: { print("Completed")  })
                .subscribe(onNext: {
                    print($0) },onCompleted: { print("结束") })
                .addDisposableTo(disposeBag)
        }
    }
    
    func test_subject()
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
    
    // Transform
    func test_transform() {
//        map 就是对每个元素都用函数做一次转换，挨个映射一遍。
        
        example("map") {
            /*Transform the items emitted by an Observable by applying a function to each item
             */
            let originalSequence =  Observable<Int>.of(1,2,3)
            originalSequence
                .map { $0 * 2 }
                .subscribe { print($0) }
            
            let disposeBag = DisposeBag()
            Observable<Int>.of(1, 2, 3)
                .map { "\($0)\($0)" }
                .subscribe{ print($0) }
                .addDisposableTo(disposeBag)
        }
        
        example("flatMap") {
            let sequenceInt = Observable<Int>.of(1, 2, 3)
            let sequenceString = Observable<String>.of("A", "B", "--")
            sequenceInt
                .flatMap { int in
                    sequenceString
                }
                .subscribe {
                    print($0)
            }
        }
        
        example("flatMap2") {
            /*
             
             理解flatMap的时候假定：每一个emission的发送时间间隔是相等的
             
             Transform the items emitted by an Observable into Observables, then flatten the emissions from those into a single Observable
             
             A B C
               A B C
                 A B C
             
             A B A C B A C B C
             
             --- flatMap2 example ---
             next(A)
             next(B)
             next(A)
             next(C)
             next(B)
             next(A)
             next(C)
             next(B)
             next(C)
             completed
             
             */
            let sequenceInt = Observable<Int>.of(1, 2, 3)
            let sequenceString = Observable<String>.of("A", "B", "C")
            
            sequenceInt.flatMap { int in
                return sequenceString
                }
                .subscribe { print($0) }
        }
        
        example("flatmapLatest") {
            /*
            1a 1b
               2a 2b
                  3a 3b
            
             最新的flatmap结果：1a 2a 3a 3b
 */
                Observable<Int>.from([1,2,3])
                .flatMapLatest { value  in
                    return Observable<String>.from(["\(value)a", "\(value)b"])
                }
                .subscribe { print($0) }
        }
        
        example("flatmapLatest") {
            // 理解flatMap的时候假定：每一个emission的发送时间间隔是相等的
            let sequenceInt = Observable<Int>.of(1, 2, 3)
            let sequenceString = Observable<String>.of("A", "B", "C")
            
            sequenceInt.flatMapLatest { int in
                return sequenceString
                }
                .subscribe { print($0) }
            // A A A B C
        }
        
        example("scan") {
            // scan 有点像 reduce ，它会把每次的运算结果累积起来，作为下一次运算的输入值。
            let sequenceToSum = Observable<Int>.of(0, 1, 2, 3, 4, 5)
            sequenceToSum
                .scan(0) { acum, elem in
                    acum + elem
                }
                .subscribe {
                    print($0)
            }
        }
    }
    
    
    func test_filter() {
//        filter 只会让符合条件的元素通过。
        
        example("filter") {
            let subscription = Observable<Int>.of(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
                .filter {
                    $0 % 2 == 0
                }
                .subscribe {
                    print($0)
            }
        }
        
//        distinctUntilChanged 会废弃掉重复的事件(值Value)。
        
        example("distinctUntilChanged") {
            let subscription = Observable<Int>.of(1, 2, 3, 1, 1, 4)
                .distinctUntilChanged()
                .subscribe {
                    print($0)
            }
        }
        
//        take 只获取序列中的前 n 个事件，在满足数量之后会自动 .Completed 。
        
            example("take") {
                let subscription = Observable<Int>.of(1, 2, 3, 4, 5, 6)
                    .take(3)
                    .subscribe {
                        print($0)
                }
        }
    }
    
    func test_combining()
    {
//        startWith 会在队列开始之前插入一个事件元素。
        
        example("startWith") {
            let subscription = Observable<Int>.of(4, 5, 6)
                .startWith(3)
                .subscribe {
                    print($0)
            }
        }
        
//        如果存在两条事件队列，需要同时监听，那么每当有新的事件发生的时候，combineLatest 会将每个队列的最新的一个元素进行合并。
        
        example("combineLatest 1") {
            let intOb1 = PublishSubject<String>()
            let intOb2 = PublishSubject<Int>()
            
            Observable.combineLatest(intOb1, intOb2) {
                "\($0) \($1)"
                }
                .subscribe {
                    print($0)
            }
            intOb1.on(.next("A"))
            intOb2.on(.next(1))
            intOb1.on(.next("B"))
            intOb2.on(.next(2))
            /*
             next(A 1)
             next(B 1)
             next(B 2)
             */
        }
        
//        zip 人如其名，就是合并两条队列用的，不过它会等到两个队列的元素一一对应地凑齐了之后再合并，正如百折不撓的米斯特菜所提醒的， zip 就像是拉链一样，两根拉链拉着拉着合并到了一根上：
        
        example("zip 1") {
            let intOb1 = PublishSubject<String>()
            let intOb2 = PublishSubject<Int>()
            Observable.zip(intOb1, intOb2) {
                "\($0) \($1)"
                }
                .subscribe {
                    print($0)
            }
            intOb1.on(.next("A"))
            intOb2.on(.next(1))
            intOb1.on(.next("B"))
            intOb1.on(.next("C"))
            intOb2.on(.next(2))
            
            /*
             next(A 1)
             next(B 2)
             */
        }
        
        example("merge 1") {
            let subject1 = PublishSubject<Int>()
            let subject2 = PublishSubject<Int>()
            Observable.merge([subject1, subject2]).subscribe({ (event) in
                print(event)
            })

            subject1.on(.next(1))
            subject1.on(.next(2))
            subject2.on(.next(3))
            subject1.on(.next(4))
            subject2.on(.next(5))
        }

    }
    
    func test_error()
    {
        // catchError 可以捕获异常事件，并且在后面无缝接上另一段事件序列，丝毫没有异常的痕迹。
        example("catchError 1") {
            let sequenceThatFails = PublishSubject<Int>()
            let recoverySequence = Observable<Int>.of(100, 200)
            sequenceThatFails
                .catchError { error in
                    return recoverySequence
                }
                .subscribe {
                    print($0)
            }
            sequenceThatFails.on(.next(1))
            sequenceThatFails.on(.next(2))
            sequenceThatFails.on(.error(NSError(domain: "Test", code: 0, userInfo: nil)))
        }

        
//        retry
        
//        retry 顾名思义，就是在出现异常的时候会再去从头订阅事件序列，妄图通过『从头再来』解决异常。
        
        example("retry") {
            var count = 1 // bad practice, only for example purposes
            let funnyLookingSequence: Observable<Int> = Observable.create { observer in
                let error = NSError(domain: "Test", code: 0, userInfo: nil)
                observer.on(.next(0))
                observer.on(.next(1))
                if count < 2 {
                    observer.on(.error(error))
                    count = count + 1
                }
                observer.on(.next(2))
                observer.on(.completed)
                return Disposables.create()
            }
            funnyLookingSequence
                .retry()
                .subscribe {
                    print($0)
            }
        }
    }
    
    func test_conditional()
    {
        example("takeUntil") {
            let originalSequence = PublishSubject<Int>()
            let whenThisSendsNextWorldStops = PublishSubject<Int>()
            originalSequence
                .takeUntil(whenThisSendsNextWorldStops)
                .subscribe {
                    print($0)
            }
            originalSequence.on(.next(1))
            originalSequence.on(.next(2))
            whenThisSendsNextWorldStops.on(.next(1))// 之后结束订阅
            originalSequence.on(.next(3))
        }
        
//        takeWhile 则是可以通过状态语句判断是否继续 take 。
        
            example("takeWhile") {
                let sequence = PublishSubject<Int>()
                sequence
                    .takeWhile { int in
                        int < 2
                    }
                    .subscribe {
                        print($0)
                }
                sequence.on(.next(1))
                sequence.on(.next(2))
                sequence.on(.next(3))
            }
        
        // 这里的 reduce 和 CollectionType 中的 reduce 是一个意思，都是指通过对一系列数据的运算最后生成一个结果。
        example("reduce") {
            Observable<Int>.of(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
                .reduce(0, accumulator: +)
                .subscribe {
                    print($0)
            }
        }
    }
    
    // 
    deinit {
        print( String(describing: self.classForCoder) + String(#function))
    }
}
