//
//  RefreshTableViewController.swift
//  SwiftFCXRefreshDemo
//
//  Created by 冯 传祥 on 2017/7/1.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

import UIKit
import SwiftFCXRefresh

class RefreshTableViewController: UITableViewController {
    var selectedRow = 0
    var rows = 20
    let refreshCellReuseId = "RefreshCellReuseId"
    var headerRefreshView: FCXRefreshHeaderView?
    var footerRefreshView: FCXRefreshFooterView?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FCXRefresh"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: refreshCellReuseId)
        addRefreshView()
        setupConfig()
    }

    //自动下拉刷新
    @objc func autoRefresh() {
        headerRefreshView?.autoRefresh()
    }

    //添加上下拉刷新
    func addRefreshView() {
        headerRefreshView = tableView.addFCXRefreshHeader { [weak self] (refreshHeader) in
            self?.refreshAction()
        }

        //自动上拉加载
        if selectedRow == 2 {
            footerRefreshView = tableView.addFCXRefreshAutoFooter { [weak self] (refreshHeader) in
                self?.loadMoreAction()
            }
        } else {//普通上拉记载
            footerRefreshView = tableView.addFCXRefreshFooter { [weak self] (refreshHeader) in
                self?.loadMoreAction()
            }
        }
        
        //显示百分比显示
        if selectedRow == 4 {
            let headerPercentLabel: UILabel = {
                let headerPercentLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 44))
                headerPercentLabel.textAlignment = .center
                headerPercentLabel.layer.borderWidth = 0.5
                headerPercentLabel.layer.borderColor = UIColor.lightGray.cgColor
                return headerPercentLabel
            }()
            let footererPercentLabel: UILabel = {
                let footererPercentLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 44))
                footererPercentLabel.textAlignment = .center
                footererPercentLabel.layer.borderWidth = 0.5
                footererPercentLabel.layer.borderColor = UIColor.lightGray.cgColor
                return footererPercentLabel
            }()
            tableView.tableHeaderView = headerPercentLabel
            tableView.tableFooterView = footererPercentLabel
            
            headerPercentLabel.text = "0%"
            footererPercentLabel.text = headerPercentLabel.text
            
            headerRefreshView?.pullingPercentHandler = { (percent) in
                headerPercentLabel.text = String.init(format: "%.2f%%", percent * 100)
            }
            
            footerRefreshView?.pullingPercentHandler = { (percent) in
                footererPercentLabel.text = String.init(format: "%.2f%%", percent * 100)
            }
            
            //百分比显示也支持下面这种方式
            /*
             headerRefreshView = tableView.addFCXRefreshHeader { [weak self] (refreshHeader) in
             self?.refreshAction()
             }.pullingPercentHandler(handler: { (percent) in
             //百分比
             print("current percent", percent)
             })
             
             footerRefreshView = tableView.addFCXRefreshFooter { [weak self] (refreshHeader) in
             self?.loadMoreAction()
             }.pullingPercentHandler { (percent) in
             print("current percent", percent)
             }
             */
        }
    }
    
    func setupConfig() {
        switch selectedRow {
        case 0:
            self.title = "普通"
        case 1://自动下拉刷新
            self.title = "自动下拉刷新"
            headerRefreshView?.autoRefresh()
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "自动刷新", style: .done, target: self, action: #selector(autoRefresh))
        case 2://自动加载更多
            self.title = "自动上拉加载更多"
            footerRefreshView?.refreshType = .autoFooter;
        case 3:
            self.title = "上拉无更多数据"
        case 4://显示百分比
            self.title = "显示百分比"
           let headerPercentLabel: UILabel = {
                let headerPercentLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 44))
                headerPercentLabel.textAlignment = .center
                headerPercentLabel.layer.borderWidth = 0.5
                headerPercentLabel.layer.borderColor = UIColor.lightGray.cgColor
                return headerPercentLabel
            }()
            let footererPercentLabel: UILabel = {
                let footererPercentLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 44))
                footererPercentLabel.textAlignment = .center
                footererPercentLabel.layer.borderWidth = 0.5
                footererPercentLabel.layer.borderColor = UIColor.lightGray.cgColor
                return footererPercentLabel
            }()
            tableView.tableHeaderView = headerPercentLabel
            tableView.tableFooterView = footererPercentLabel
            
            headerPercentLabel.text = "0%"
            footererPercentLabel.text = headerPercentLabel.text
            
            headerRefreshView?.pullingPercentHandler = { (percent) in
                headerPercentLabel.text = String.init(format: "%.2f%%", percent * 100)
            }
            
            footerRefreshView?.pullingPercentHandler = { (percent) in
                footererPercentLabel.text = String.init(format: "%.2f%%", percent * 100)
            }
            
            //百分比显示也支持下面这种方式
            /*
             headerRefreshView = tableView.addFCXRefreshHeader { [weak self] (refreshHeader) in
             self?.refreshAction()
             }.pullingPercentHandler(handler: { (percent) in
             //百分比
             print("current percent", percent)
             })
             
             footerRefreshView = tableView.addFCXRefreshFooter { [weak self] (refreshHeader) in
             self?.loadMoreAction()
             }.pullingPercentHandler { (percent) in
             print("current percent", percent)
             }
             */
        case 5://底部间隙
            self.title = "底部间隙"
            footerRefreshView?.loadMoreBottomExtraSpace = 30;
        case 6://自定义颜色
            self.title = "自定义颜色"
            headerRefreshView?.dateLabel.textColor = .red;
            headerRefreshView?.statusLabel.textColor = .blue;
            footerRefreshView?.statusLabel.textColor = .magenta;
        case 7://自定义文本
            self.title = "自定义文本"
            headerRefreshView?.normalText = "normal"
            headerRefreshView?.pullingText = "pulling"
            headerRefreshView?.loadingText = "loading"
            
            footerRefreshView?.normalText = "normal"
            footerRefreshView?.pullingText = "pulling"
            footerRefreshView?.loadingText = "loading"
            footerRefreshView?.noMoreDataText = "NoData"
        case 8://隐藏时间
            self.title = "隐藏时间"
            headerRefreshView?.arrowOffsetX = 35
            headerRefreshView?.hideDateView()
            break;
        case 9://隐藏状态和时间
            self.title = "隐藏状态和时间"
            headerRefreshView?.hideStatusAndDateView()
            footerRefreshView?.hideStatusAndDateView()
        default:
            break
        }
    }
    
    //下拉刷新操作
    func refreshAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.rows = 20
            weakSelf.footerRefreshView?.resetNoMoreData()
            weakSelf.headerRefreshView?.endRefresh()
            weakSelf.tableView.reloadData()
        }
    }
    
    //上拉加载更多
    func loadMoreAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            guard let weakSelf = self,
                let footerRefreshView = self?.footerRefreshView else {
                return
            }
            
            weakSelf.rows += 20
            
            if weakSelf.selectedRow == 3 && weakSelf.rows >= 40 {
                //
                footerRefreshView.showNoMoreData()
            } else {
                footerRefreshView.endRefresh()
            }
            weakSelf.tableView.reloadData()
        }

    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: refreshCellReuseId, for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }

}
