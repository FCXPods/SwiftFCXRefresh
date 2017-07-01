//
//  UIScrollView+FCXRefresh.swift
//  FCXRefresh
//
//  Created by 冯 传祥 on 2017/6/19.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

import UIKit

extension UIScrollView {
    @discardableResult
    open func addFCXRefreshHeader(handler: @escaping (FCXRefreshBaseView) -> Void) -> FCXRefreshHeaderView {
        let refreshHeaderView = FCXRefreshHeaderView.init(frame: CGRect.init(x: 0, y: -60, width: self.frame.size.width, height: 60), hangingHeight: 60, refreshType: .header, refreshHandler: handler)
        self.addSubview(refreshHeaderView)
        return refreshHeaderView;
    }
    
    @discardableResult
    open func addFCXRefreshFooter(handler: @escaping (FCXRefreshBaseView) -> Void) -> FCXRefreshFooterView {
        let refreshFooterView = FCXRefreshFooterView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 60), hangingHeight: 60, refreshType: .footer, refreshHandler: handler)
        self.addSubview(refreshFooterView)
        return refreshFooterView;
    }
    
    @discardableResult
    open func addFCXRefreshAutoFooter(handler: @escaping (FCXRefreshBaseView) -> Void) -> FCXRefreshFooterView {
        let refreshView = FCXRefreshFooterView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 60), hangingHeight: 60, refreshType: .autoFooter, refreshHandler: handler)
        self.addSubview(refreshView)
        return refreshView;
    }
}
