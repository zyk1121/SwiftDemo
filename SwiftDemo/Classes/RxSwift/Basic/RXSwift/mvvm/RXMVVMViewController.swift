//
//  RXMVVMViewController.swift
//  iTestProject
//
//  Created by 张元科 on 2017/7/12.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class RXMVVMViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    let mainView = RXMVVMMainView()
    let mainViewModel = RXMVVMViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        self.title = "MVVM"
//        Observable<String>.just("MVVM").bind(to: self.rx.title).addDisposableTo(disposeBag)
        setupUI()
        bindUI()
        view.setNeedsUpdateConstraints()
    }
    
    func setupUI() {
        view.addSubview(mainView)
    }
    
    func bindUI() {
        // 登录按钮点击
        mainView.longinButton.rx.controlEvent(UIControlEvents.touchUpInside).asObservable().subscribe {[weak self] (event) in
            self?.loginButtonClicked()
        }.addDisposableTo(disposeBag)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        mainView.snp.remakeConstraints { (make) in
            make.top.equalTo(view).offset(64)
            make.left.right.bottom.equalTo(view)
        }
    }
    
    private func loginButtonClicked()
    {
//        print(#function)
        guard let userName = mainView.username.text,
        let password = mainView.password.text else {
            return
        }
        
//        mainViewModel.userLogin(name: userName, password: password).subscribe { (event) in
//            print(event)
//        }.addDisposableTo(disposeBag)
        print("-----开始登录请求，加载中....")
        mainViewModel.userLogin(name: userName, password: password).subscribe(onNext: {[weak self] (usermodel) in
            print("请求成功")
            let strongSelf = self!
            if usermodel.isLogin {
                // fatal error: `drive*` family of methods can be only called from `MainThread`.
//                This is required to ensure that the last replayed `Driver` element is delivered on `MainThread`.
                
//                Observable<String>.just("登录成功：\(usermodel.userName)").asDriver(onErrorJustReturn: "登录失败").asObservable().bind(to:strongSelf.mainView.showResult.rx.text).addDisposableTo(strongSelf.disposeBag)
                DispatchQueue.main.async {
                     Observable<String>.just("登录成功：\(usermodel.userName)").asDriver(onErrorJustReturn: "登录失败").asObservable().bind(to:strongSelf.mainView.showResult.rx.text).addDisposableTo(strongSelf.disposeBag)
                }
            }
            
        }, onError: { (error) in
            print("请求失败")
            print("----加载loading完成")
        }, onCompleted: { 
            print("完成onCompleted")
            print("----加载loading完成")
        }) { 
            print("取消订阅")// 需要的时候特殊处理
        }.addDisposableTo(disposeBag)
    }

    deinit {
        print(self)
    }
}
