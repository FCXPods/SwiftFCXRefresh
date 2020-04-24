//
//  ViewController.swift
//  SwiftFCXRefreshDemo
//
//  Created by 冯 传祥 on 2017/7/1.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

import UIKit
import SwiftFCXRefresh

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView = UITableView.init(frame: UIScreen.main.bounds, style: .plain)
    var headerRefreshView: FCXRefreshHeaderView?
    var rows = 15
    let cellReuseId = "CellReuseId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FCXRefresh"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(autoRefresh))

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseId)
        view.addSubview(tableView)
        
        addRefreshView()
    }
    
    @objc func autoRefresh() {
        headerRefreshView?.autoRefresh()
    }

    func addRefreshView() {
        headerRefreshView = tableView.addFCXRefreshHeader { (refreshHeader) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.rows = 15
                refreshHeader.endRefresh()
                self.tableView.reloadData()
            }}.pullingPercentHandler(handler: { (percent) in

            })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)
        switch (indexPath.row) {
        case 0:
            cell.textLabel?.text = "上下拉刷新（普通）"
        case 1:
            cell.textLabel?.text = "上下拉刷新（自动下拉加载）"
        case 2:
            cell.textLabel?.text = "上下拉刷新（自动上拉加载）"
        case 3:
            cell.textLabel?.text = "上下拉刷新（上拉无更多数据）"
        case 4:
            cell.textLabel?.text = "上下拉刷新（显示百分比）"
        case 5:
            cell.textLabel?.text = "上下拉刷新（底部间隙）"
        case 6:
            cell.textLabel?.text = "上下拉刷新（自定义颜色）"
        case 7:
            cell.textLabel?.text = "上下拉刷新（自定义文本）"
        case 8:
            cell.textLabel?.text = "上下拉刷新（隐藏时间）"
        case 9:
            cell.textLabel?.text = "上下拉刷新（隐藏状态和时间）"
        default:
            break;
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let refreshVC = RefreshTableViewController()
        refreshVC.selectedRow = indexPath.row
        navigationController?.pushViewController(refreshVC, animated: true)
    }

}

