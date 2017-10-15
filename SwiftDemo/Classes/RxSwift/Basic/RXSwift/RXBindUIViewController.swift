//
//  RXBindUIViewController.swift
//  iTestProject
//
//  Created by 张元科 on 2017/7/9.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

// 没有对象引用当前对象 当前对象就能释放
class RXBindUIViewController: UIViewController {

    //属性定义
    lazy var btn1:UIButton = {
        let button = UIButton()
        button.setTitle("按钮1", for: [])
        button.setTitleColor(UIColor.red, for: [])
        button.backgroundColor = UIColor.gray
        self.view.addSubview(button)
        return button
    }()
    lazy var label1:UILabel = {
        let label = UILabel()
        self.view.addSubview(label)
        return label
    }()
    
    lazy var label2:UILabel = {
        let label = UILabel()
        self.view.addSubview(label)
        return label
    }()
    
    lazy var label3:UILabel = {
        let label = UILabel()
        self.view.addSubview(label)
        return label
    }()
    
    lazy var sw:UISwitch = {
        let sw = UISwitch()
        self.view.addSubview(sw)
        return sw
    }()
    
    lazy var segment:UISegmentedControl = {
        let seg = UISegmentedControl(items: ["123","456","789"])
        self.view.addSubview(seg)
        return seg
    }()
    
    lazy var slider:UISlider = {
        let slid = UISlider()
        self.view.addSubview(slid)
        return slid
    }()
    lazy var textField:UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.gray
          self.view.addSubview(textField)
        return textField
    }()
    //
    dynamic var label1Text:String = "hello"
    
    
    
    var label2Test = Variable<String>("abc")
    
    // label3Text
    var rx_label3Text = Variable<String>("")
    var label3Text : String {
        get {
            return rx_label3Text.value
        }
        
        set {
            rx_label3Text.value = newValue
        }
    }
    
    let disposeBag = DisposeBag()
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupData()
        setupUI()
        bindUI()
        updateViewConstraints()
        view.updateConstraintsIfNeeded()
        testTimer()
    }
    
    func testTimer() {
         Observable<NSInteger>.interval(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (sec) in
                print("\(sec) s")
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
    }
    
    func setupData() {
        
    }
    
    func setupUI() {
        
    }
    
    func bindUI()
    {
        /*
        btn1.rx.controlEvent(UIControlEvents.touchUpInside).subscribe {[weak self] (event) in
//            self.test_deinit()
            self?.test_deinit()
            print(event)
            // self->btn1->
            // observer->sink->closure->self
            // btn1->controlTarget(addTarget)->block->observer->sink->closure->self->btn1
            // 没有self不会循环引用
        }.addDisposableTo(disposeBag)
 */
        /*
        let dis = btn1.rx.controlEvent(UIControlEvents.touchUpInside).subscribe {[weak self] (event) in
            //            self.test_deinit()
            self?.test_deinit()
            print(event)
            // self->btn1->
            // observer->sink->closure->self
            // btn1->controlTarget(addTarget)->block->observer->sink->closure->self->btn1
            // 没有self不会循环引用
            }
        dis.dispose()// 点击按钮就不响应了
 */
        btn1.rx.controlEvent(UIControlEvents.touchUpInside).subscribe {[weak self] (event) in
            //            self.test_deinit()
            self?.test_deinit()
            print(event)
            // self->btn1->
            // observer->sink->closure->self
            // btn1->controlTarget(addTarget)->block->observer->sink->closure->self->btn1
            // 没有self不会循环引用
        }.addDisposableTo(disposeBag)
        
        _ = Observable.just("normal").subscribe(btn1.rx.title(for: .normal))
//        _ = Observable.just("normal").subscribe(button.rx.title(for: .selected))
//        _ = Observable.just("normal").subscribe(button.rx.title())
//        _ = Observable.just(NSAttributedString(string: "normal")).subscribe(button.rx.attributedTitle(for: []))
//        _ = Observable.just(NSAttributedString(string: "normal")).subscribe(button.rx.attributedTitle(for: .selected))
//        _ = Observable.just(image).subscribe(button.rx.image(for: .normal))
//        _ = Observable.just(image).subscribe(button.rx.image(for: .selected))
//        _ = Observable.just(image).subscribe(button.rx.image())
//        _ = Observable.just(image).subscribe(button.rx.backgroundImage(for: .normal))
        
        // button
        
        
        
        // Label（初始化label的值）
        _ = Observable<String>.just("测试Lable字符串").bind(to: label1.rx.text)
        // 利用kvo绑定label的值(有循环引用)
//        _ = self.rx.observe(String.self, "label1Text").bind(to: label1.rx.text)
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
//            self.label1Text = "12345678"
//        }
        
        
        // label2
        _ = label2Test.asObservable().bind(to: label2.rx.text)
        label2Test.value = "eeee"
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
            self.label2Test.value = "ddddd"
        }
        // label3
        _ = rx_label3Text.asObservable().bind(to: label3.rx.text)
        label3Text = "333"
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
            self.label3Text = "uuuuuu"
        }
        
        // switch
        _ = Observable<Bool>.just(true).bind(to: sw.rx.isOn)
        
        // also test two way binding
//        let switchValue = Variable(true)
//        _  = switchValue.asObservable().bind(to: sw.rx.value)
//        switchValue.asObservable().subscribe { (event) in
//            print(event)
//        }
        /*
        _ = sw.rx.controlEvent(UIControlEvents.valueChanged).subscribe {[weak self] (event) in
            print(event)
            print(self?.sw.isOn)
        }
 */
        sw.rx.isOn.asObservable().subscribe {[weak self] (event) in
            self?.test_deinit()
            print(event)
        }.addDisposableTo(disposeBag)
        
        // segment
        _ = Observable<Int>.just(1).bind(to: segment.rx.value)
        segment.rx.selectedSegmentIndex.asObservable().subscribe { (event) in
            print(event)
        }.addDisposableTo(disposeBag)
        
        // slider
        _ = Observable<Float>.just(0.6).bind(to: slider.rx.value)
//        slider.rx.value .asObservable().subscribe { (event) in
//            print(event)
//        }.addDisposableTo(disposeBag)
        slider.rx.value.asObservable().subscribe { (event) in
            print(event)
            }.addDisposableTo(disposeBag)
        
        

        /*
         
         #if !RX_NO_MODULE
         manager.requestWhenInUseAuthorization()
         #endif
         
         manager.rx.didUpdateLocations
         .subscribe(onNext: { x in
         print("rx.didUpdateLocations \(x)")
         })
         .disposed(by: disposeBag)
         
         _ = manager.rx.didFailWithError
         .subscribe(onNext: { x in
         print("rx.didFailWithError \(x)")
         })
         
         manager.rx.didChangeAuthorizationStatus
         .subscribe(onNext: { status in
         print("Authorization status \(status)")
         })
         .disposed(by: disposeBag)
         
         manager.startUpdatingLocation()
         */
        
        // textField
//        _ = Observable<String>.just("123").bind(to: textField.rx.text)
//        textField.rx.value.asObservable().subscribe { (event) in
//            print(event)
//            
//            }.addDisposableTo(disposeBag)
        
//        _ = textField.rx.value.asObservable().bind(to: label3.rx.text)
        /*
         
         let searchResults = searchBar.rx_text
         .throttle(0.3, scheduler: MainScheduler.instance)
         .distinctUntilChanged()
         .flatMapLatest { query -> Observable<[Repository]> in
         if query.isEmpty {
         return Observable.just([])
         }
         
         return doSearchAPI(query).retry(3)
         .catchErrorJustReturn([])
         }
         .observeOn(MainScheduler.instance)
         
         */
//        
//        textField.rx.value.asObservable()
//        .throttle(0.3, scheduler: MainScheduler.instance)
//        .distinctUntilChanged()
//            .flatMapLatest { (str) -> Observable<String> in
//            return Observable<String>.just("网络请求\(String(describing: str))")
//        }.subscribe {[weak self] (event) in
//            self?.label3Text = event.element!
//        }
        

//        textField.rx.text.orEmpty
//        .throttle(0.3, scheduler: MainScheduler.instance)
//        .distinctUntilChanged()
//            .subscribe {[weak self] (event) in
//            self?.label3Text = event.element!
//        }
        
//        orEmpty /// Transforms control property of type `String?` into control property of type `String`.
        // 搜索框
        /*
        textField.rx.text.orEmpty
            .throttle(3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe {[weak self] (event) in
                self?.label3Text = event.element!
        }
 */
        
        
        /*
         Driver
         
         Driver从名字上可以理解为驱动（我自己会亲切地把它叫做"老司机"），在功能上它类似被观察者（Observable），而它本身也可以与被观察者相互转换（Observable: asDriver, Driver: asObservable），它驱动着一个观察者，当它的事件流中有事件涌出时，被它驱动着的观察者就能进行相应的操作。一般我们会将一个Observable被观察者转换成Driver后再进行驱动操作：
         
         我们沿用上面例子中的UILabel私有扩展，并修改下binding方法：
         
         func binding() {
         textField.rx_text
         .asDriver()
         .drive(label.rx_sayHelloObserver)
         .addDisposableTo(disposeBag)
         }
         可见，Driver的drive方法与Observable的方法bindTo用法非常相似，事实上，它们的作用也是一样，说白了就是被观察者与观察者的绑定。
         
         链接：http://www.jianshu.com/p/431f645cb805
         http://blog.csdn.net/Hello_Hwc/article/details/51859330
         來源：简书
         著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
         */
        /*
        textField.rx.text
            .asDriver().drive(label3.rx.text).addDisposableTo(disposeBag)
        
 */
        /*
        其实，比较与Observable，Driver有以下的特性：
        
        它不会发射出错误(Error)事件:错误事件的特殊处理
        对它的观察订阅是发生在主线程(UI线程)的：自动切换到主线程
        自带shareReplayLatestWhileConnected：自动转换为热观察者（热信号）：共享结果：不会重复进行网络请求等
 */
        
        // 冷观察者（冷信号），每一次subscribe都会触发一次网络请求（不一定符合所有的情况）
        /*
        let request = textField.rx.text.orEmpty
            .throttle(1, scheduler: MainScheduler.instance)
            .distinctUntilChanged().flatMapLatest {[weak self] (param) -> Observable<String> in
                (self?.networkRequest(param: param))!
        }
        
        request.subscribe { (event) in
            print("1:")
            print(event)
        }
        
        request.subscribe { (event) in
            print("2:")
            print(event)
        }
 */
        // 利用Driver进行优化
        /*
        let request = textField.rx.text.orEmpty
            .throttle(1, scheduler: MainScheduler.instance)
            .distinctUntilChanged().flatMapLatest {[weak self] (param) -> Observable<String> in
                (self?.networkRequest(param: param))!
        }.asDriver(onErrorJustReturn: "error str").asObservable()
        // asDriver 只进行一次网络请求，两个订阅者共享结果
        /*
         其实，比较与Observable，Driver有以下的特性：
         
         它不会发射出错误(Error)事件:错误事件的特殊处理
         对它的观察订阅是发生在主线程(UI线程)的：自动切换到主线程
         自带shareReplayLatestWhileConnected：自动转换为热观察者（热信号）：共享结果：不会重复进行网络请求等
         */
        
        request.subscribe { (event) in
            print("1:")
            print(event)
        }.addDisposableTo(disposeBag)

        request.subscribe { (event) in
            print("2:")
            print(event)
        }.addDisposableTo(disposeBag)
 */
        
        // 子线程处理后返回结果
        let request = textField.rx.text.orEmpty
            .throttle(1, scheduler: MainScheduler.instance)
            .distinctUntilChanged().flatMapLatest {[weak self] (param) -> Observable<String> in
                (self?.networkRequest2(param: param))!
            }.asDriver(onErrorJustReturn: "error str").asObservable()
        // asDriver 只进行一次网络请求，两个订阅者共享结果
        /*
         其实，比较与Observable，Driver有以下的特性：
         
         它不会发射出错误(Error)事件:错误事件的特殊处理
         对它的观察订阅是发生在主线程(UI线程)的：自动切换到主线程
         自带shareReplayLatestWhileConnected：自动转换为热观察者（热信号）：共享结果：不会重复进行网络请求等
         */
        
        request.subscribe { (event) in
            print("1:")
            print(Thread.current)
            print(event)
            }.addDisposableTo(disposeBag)
        
        request.subscribe { (event) in
            print("2:")
            print(Thread.current)
            print(event)
            }.addDisposableTo(disposeBag)
        
        
        // asDriver drive(bindto)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) { 
            _ = Observable<String>.just("hhhhh").asDriver(onErrorJustReturn: "error").drive(self.label3.rx.text)
            self.test()
        }
        
        
        
    }
    
    func test() {
        
        // 转换为热序列（热信号）
        print("~~~~~~~~~")
        let ob = networkRequest2(param: "12345678").asDriver(onErrorJustReturn: "errr").asObservable()
        ob.subscribe { (event) in
            print(event)
        }
        ob.subscribe { (event) in
            print(event)
        }
        ob.subscribe { (event) in
            print(event)
        }
        print("~~~~~~~~~")
    }
    
    func networkRequest2(param:String) -> (Observable<String>) {
        
        print("request2....")
        let obserable = Observable<String>.create { (observer) -> Disposable in
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.0) {
                // 子线程发送：asDriver会切换到主线程
                observer.onNext("net result:\(param)")
                //                observer.onCompleted()// flatMapLatest之后的序列不进行completed和error的发送（原因未查）
                //                observer.onError()
            }
            return Disposables.create()// 不需要返回
        }
//        CurrentThreadScheduler.instance
//        ConcurrentDispatchQueueScheduler.init(queue: DispatchQueue.global())
        return obserable
    }
    
    /*
     RxSwift内置的Scheduler
     
     通常，使用内置的Scheduler足矣。
     
     CurrentThreadScheduler(串行) 当前线程Scheduler，默认使用的
     MainScheduler(串行) 主线程
     SerialDispatchQueueScheduler 封装了GCD的串行队列
     ConcurrentDispatchQueueScheduler 封装了GCD的并行队列，这个在有任务要在后台执行的时候很有用
     OperationQueueScheduler 封装了NSOperationQueue
     例子四，在后台Scheduler之行任务，然后在主线程上更新UI
     

     */
    /*一般我们在对Observable进行map操作后，我们会在后面加上shareReplay(1)或shareReplayLatestWhileConnected，以防止以后被观察者被多次订阅观察后，map中的语句会多次调用：
     
     let rx_textChange = textField.rx_text
     .map { return "Good \($0)" }
     .shareReplay(1)
     rx_textChange
     .subscribeNext { print("1 -- \($0)") }
     .addDisposableTo(disposeBag)
     rx_textChange
     .subscribeNext { print("2 -- \($0)") }
     .addDisposableTo(disposeBag)
     在Driver中，框架已经默认帮我们加上了shareReplayLatestWhileConnected，所以我们也没必要再加上"replay"相关的语句了。
     
     链接：http://www.jianshu.com/p/431f645cb805
     來源：简书
     著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
     
     
     
     共享监听Sharing subscription－shareReplay
     
     这个是很常用的，比如一个Obserable用做网络请求，通常，当你这样调用的时候，会创建两个序列，也就是会进行两次网络请求，这是不需要的
     
     let network = networkWithText(text)
     let subscription1 = network
     .subscribeNext { n in
     //创建第一个序列
     }
     let subscription2 = network
     .subscribeNext { n in
     //创建第二个序列
     }
     1
     2
     3
     4
     5
     6
     7
     8
     9
     1
     2
     3
     4
     5
     6
     7
     8
     9
     为了共享一个序列，你只需要这这样调用
     
     let network = networkWithText(text).shareReplay(1)
     1
     1
     就只会进行一次网络请求，两个subscription共享结果，也就是shareReplay的意思
     
     
     */
    
    func networkRequest(param:String) -> (Observable<String>) {
        
        print("request....")
        let obserable = Observable<String>.create { (observer) -> Disposable in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                observer.onNext("net result:\(param)")
//                observer.onCompleted()// flatMapLatest之后的序列不进行completed和error的发送（原因未查）
//                observer.onError()
            }
            return Disposables.create()// 不需要返回
        }
        
        return obserable
        
//        let ob = Variable<String>("")
//        print("request")
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
//            ob.value = "result:\(param)"
//        }
//        return ob.asObservable()
    }

    
//    func networkRequest(param:String) -> (Observable<String>) {
//        let ob = Variable<String>("")
//        print("request")
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) { 
//            ob.value = "result:\(param)"
//        }
//        return ob.asObservable()
//    }
    
    func test_deinit() {
        print(#function)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        btn1.snp.remakeConstraints { (make) in
            make.top.equalTo(self.view).offset(64)
            make.left.equalTo(self.view)
            make.height.equalTo(30)
            make.width.equalTo(60)
        }
        
        label1.snp.remakeConstraints { (make) in
            make.top.equalTo(btn1.snp.bottom).offset(10)
            make.left.equalTo(self.view)
            make.height.equalTo(30)
            make.width.equalTo(300)
        }
        label2.snp.remakeConstraints { (make) in
            make.top.equalTo(label1.snp.bottom).offset(10)
            make.left.equalTo(self.view)
            make.height.equalTo(30)
            make.width.equalTo(300)
        }
        label3.snp.remakeConstraints { (make) in
            make.top.equalTo(label2.snp.bottom).offset(10)
            make.left.equalTo(self.view)
            make.height.equalTo(30)
            make.width.equalTo(300)
        }
        
        sw.snp.remakeConstraints { (make) in
            make.top.equalTo(label3.snp.bottom).offset(10)
            make.left.equalTo(self.view)
        }
        
        segment.snp.remakeConstraints { (make) in
            make.top.equalTo(sw.snp.bottom).offset(10)
            make.left.equalTo(self.view)
            make.width.equalTo(200)
            make.height.equalTo(30)
        }
        slider.snp.remakeConstraints { (make) in
            make.top.equalTo(segment.snp.bottom).offset(10)
            make.left.equalTo(self.view)
            make.width.equalTo(300)
            make.height.equalTo(10)
        }
        textField.snp.remakeConstraints { (make) in
            make.top.equalTo(slider.snp.bottom).offset(10)
            make.left.equalTo(self.view)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
    }

    deinit {
        // timer也能自动释放
        print(self)
    }
}


/*
 override func viewDidLoad() {
 super.viewDidLoad()
 
 datePicker.date = Date(timeIntervalSince1970: 0)
 
 // MARK: UIBarButtonItem
 
 bbitem.rx.tap
 .subscribe(onNext: { [weak self] x in
 self?.debug("UIBarButtonItem Tapped")
 })
 .disposed(by: disposeBag)
 
 // MARK: UISegmentedControl
 
 // also test two way binding
 let segmentedValue = Variable(0)
 _ = segmentedControl.rx.value <-> segmentedValue
 
 segmentedValue.asObservable()
 .subscribe(onNext: { [weak self] x in
 self?.debug("UISegmentedControl value \(x)")
 })
 .disposed(by: disposeBag)
 
 
 // MARK: UISwitch
 
 // also test two way binding
 let switchValue = Variable(true)
 _ = switcher.rx.value <-> switchValue
 
 switchValue.asObservable()
 .subscribe(onNext: { [weak self] x in
 self?.debug("UISwitch value \(x)")
 })
 .disposed(by: disposeBag)
 
 // MARK: UIActivityIndicatorView
 
 switcher.rx.value
 .bind(to: activityIndicator.rx.isAnimating)
 .disposed(by: disposeBag)
 
 // MARK: UIButton
 
 button.rx.tap
 .subscribe(onNext: { [weak self] x in
 self?.debug("UIButton Tapped")
 })
 .disposed(by: disposeBag)
 
 
 // MARK: UISlider
 
 // also test two way binding
 let sliderValue = Variable<Float>(1.0)
 _ = slider.rx.value <-> sliderValue
 
 sliderValue.asObservable()
 .subscribe(onNext: { [weak self] x in
 self?.debug("UISlider value \(x)")
 })
 .disposed(by: disposeBag)
 
 
 // MARK: UIDatePicker
 
 // also test two way binding
 let dateValue = Variable(Date(timeIntervalSince1970: 0))
 _ = datePicker.rx.date <-> dateValue
 
 
 dateValue.asObservable()
 .subscribe(onNext: { [weak self] x in
 self?.debug("UIDatePicker date \(x)")
 })
 .disposed(by: disposeBag)
 
 
 // MARK: UITextField
 
 // also test two way binding
 let textValue = Variable("")
 _ = textField.rx.textInput <-> textValue
 
 textValue.asObservable()
 .subscribe(onNext: { [weak self] x in
 self?.debug("UITextField text \(x)")
 })
 .disposed(by: disposeBag)
 
 
 // MARK: UIGestureRecognizer
 
 mypan.rx.event
 .subscribe(onNext: { [weak self] x in
 self?.debug("UIGestureRecognizer event \(x.state)")
 })
 .disposed(by: disposeBag)
 
 
 // MARK: UITextView
 
 // also test two way binding
 let textViewValue = Variable("")
 _ = textView.rx.textInput <-> textViewValue
 
 textViewValue.asObservable()
 .subscribe(onNext: { [weak self] x in
 self?.debug("UITextView text \(x)")
 })
 .disposed(by: disposeBag)
 
 // MARK: CLLocationManager
 
 #if !RX_NO_MODULE
 manager.requestWhenInUseAuthorization()
 #endif
 
 manager.rx.didUpdateLocations
 .subscribe(onNext: { x in
 print("rx.didUpdateLocations \(x)")
 })
 .disposed(by: disposeBag)
 
 _ = manager.rx.didFailWithError
 .subscribe(onNext: { x in
 print("rx.didFailWithError \(x)")
 })
 
 manager.rx.didChangeAuthorizationStatus
 .subscribe(onNext: { status in
 print("Authorization status \(status)")
 })
 .disposed(by: disposeBag)
 
 manager.startUpdatingLocation()
 
 
 
 }
 */
