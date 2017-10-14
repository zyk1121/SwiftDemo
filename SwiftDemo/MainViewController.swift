//
//  ViewController.swift
//  SwiftDemo
//
//  Created by 张元科 on 2017/10/12.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit
import SnapKit

class MainViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    var itemKeys = ["01-Alamofire",
                    "02-SwiftJSON"
                    ]
    var items:[String:String] = ["01-Alamofire":"YK://router/alamofire/AlamofireViewController",
                                 "02-SwiftJSON":"YK://router/swiftjson/SwiftJSONViewController",
                                 ]
    var tableView:UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 返回按钮
        let returenButtonItem = UIBarButtonItem()
        returenButtonItem.title = "返回"
        self.navigationItem.backBarButtonItem = returenButtonItem
    }
    
    override func loadView() {
        super.loadView()
        self.setupUI()
        self.view.setNeedsUpdateConstraints()
    }
    
    func setupUI() {
        tableView = UITableView(frame: self.view.frame, style: UITableViewStyle.plain)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self,
                                 forCellReuseIdentifier: "SwiftCell")
        self.view.addSubview(tableView!)
    }
    
    override func updateViewConstraints() {
        self.tableView?.snp.remakeConstraints({ (make) in
            _ = make.edges.equalTo(self.view)
        })
        super.updateViewConstraints()
    }
    
    
    /// MARK:table delegate datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //为了提供表格显示性能，已创建完成的单元需重复使用
        /*unable to dequeue a cell with identifier SwiftCell - must register a nib or a class for the identifier or connect a prototype cell in a storyboard'*/
        let identify:String = "SwiftCell"
        //同一形式的单元格重复使用，在声明时已注册
        let cell = tableView.dequeueReusableCell(withIdentifier: identify,
                                                 for: indexPath) as UITableViewCell
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.textLabel?.text = itemKeys[indexPath.row]
        return cell
        
    }
    
    func findKeyForRow(row:Int) -> String {
        let keys = items.keys
        
        for (index, item) in keys.enumerated() {
            if index == row {
                return item
            }
        }
        return "defaultkey"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView!.deselectRow(at: indexPath, animated: true)
        self.selectRow(row: indexPath.row)
    }
    
    /// 选中某一行
    func selectRow(row : Int) {
        let key = itemKeys[row]
        YKUrlRouterManager.router(sourceVC: self, toURL: URL(string:items[key]!)!)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
}

