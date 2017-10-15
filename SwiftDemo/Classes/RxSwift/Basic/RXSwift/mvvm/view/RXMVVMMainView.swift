//
//  RXMVVMMainView.swift
//  iTestProject
//
//  Created by 张元科 on 2017/7/12.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class RXMVVMMainView: UIView {

    // 定义属性
    private let disposeBag = DisposeBag()
    private lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.text = "姓名:"
        self.addSubview(label)
        return label
    }()
    private lazy var passLabel:UILabel = {
        let label = UILabel()
        label.text = "密码:"
        self.addSubview(label)
        return label
    }()
    lazy var username:UITextField = {
        let textField = UITextField()
        textField.background = UIImage(named: "commom_app_bg_image_disabled")
        textField.placeholder = "请输入用户名"
        self.addSubview(textField)
        return textField
    }()
    lazy var password:UITextField = {
        let textField = UITextField()
        textField.background = UIImage(named: "commom_app_bg_image_disabled")
        textField.placeholder = "请输入密码"
        self.addSubview(textField)
        return textField
    }()
    lazy var longinButton:UIButton = {
        let button = UIButton()
        button.setTitle("登录", for: [])
        button.setBackgroundImage(UIImage(named:"commom_app_bg_image_normal"), for: .normal)
        button.setBackgroundImage(UIImage(named:"commom_app_bg_image_heighted"), for: .highlighted)
        button.isEnabled = false
        self.addSubview(button)
        return button

    }()
    lazy var showResult:UILabel = {
        let label = UILabel()
        label.text = "结果:"
        self.addSubview(label)
        return label
    }()
    // init
    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = UIColor.red
        setupUI()
        bindUI()
        setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
    }
    
    func bindUI() {
        
        Observable.combineLatest(username.rx.text,password.rx.text).subscribe {[weak self] (event) in
            guard let v1 = event.element?.0,
                let v2 = event.element?.1 else {
                    return
            }
         
            self?.longinButton.isEnabled = v1.characters.count >= 6 && v2.characters.count >= 6
        }.addDisposableTo(disposeBag)
    }
    
    // 布局
    override func updateConstraints() {
        nameLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self).offset(40)
            make.left.equalTo(self).offset(40)
        }
        passLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.left.equalTo(nameLabel)
        }
        username.snp.remakeConstraints { (make) in
            make.top.equalTo(nameLabel)
            make.left.equalTo(nameLabel.snp.right).offset(10)
            make.width.equalTo(200)
            make.height.equalTo(30)
            make.centerY.equalTo(nameLabel)
        }
        
        password.snp.remakeConstraints { (make) in
            make.top.equalTo(passLabel)
            make.left.equalTo(passLabel.snp.right).offset(10)
            make.width.equalTo(200)
            make.height.equalTo(30)
             make.centerY.equalTo(passLabel)
        }
        
        longinButton.snp.remakeConstraints { (make) in
            make.top.equalTo(passLabel.snp.bottom).offset(20)
            make.left.equalTo(passLabel)
            make.right.equalTo(password)
            make.height.equalTo(35)
        }
        showResult.snp.remakeConstraints { (make) in
            make.top.equalTo(longinButton.snp.bottom).offset(30)
            make.left.equalTo(self).offset(40)
            make.right.equalTo(self).offset(-40)
            make.height.equalTo(40)
        }
        super.updateConstraints()
    }
}
