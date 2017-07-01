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
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "自动刷新", style: .done, target: self, action: #selector(autoRefresh))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseId)
        view.addSubview(tableView)
        
        addRefreshView()
    }
    
    func autoRefresh() {
        headerRefreshView?.autoRefresh()
    }

    func addRefreshView() {
        headerRefreshView = tableView.addFCXRefreshHeader { (refreshHeader) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.rows = 15
                
                refreshHeader.endRefresh()
                self.tableView.reloadData()
            }}.pullingPercentHandler(handler: { (percent) in
                print("current percent is", percent)
            })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel?.text = "下拉刷新+上拉刷新";
            case 1:
                cell.textLabel?.text = "自动下拉刷新+上拉刷新";
            case 2:
                cell.textLabel?.text = "下拉刷新+上拉自动刷新";
            case 3:
                cell.textLabel?.text = "下拉刷新+上拉刷新(控制加载个数)";
            case 4:
                cell.textLabel?.text = "下拉刷新+上拉刷新(显示百分比)";
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

