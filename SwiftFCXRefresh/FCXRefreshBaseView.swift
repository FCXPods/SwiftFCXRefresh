//
//  FCXRefreshBaseView.swift
//  FCXRefresh
//
//  Created by 冯 传祥 on 2017/6/16.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

import UIKit

open class FCXRefreshBaseView: UIView {
    required public init(frame: CGRect, hangingHeight hangingH: CGFloat = 60, refreshType type: FCXRefreshViewType = .header, refreshHandler handler: @escaping (FCXRefreshBaseView) -> Void) {
        refreshType = type
        refreshHandler = handler
        hangingHeight = hangingH
        super.init(frame: frame)
        
        setupContentView()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        removeScrollViewObservers()
        guard let newSuperview = newSuperview as? UIScrollView else {
            return
        }
        scrollView = newSuperview
        scrollViewOriginalEdgeInsets = newSuperview.contentInset
        addScrollViewObservers()
    }
    
    public var normalText: String?
    public var pullingText: String?
    public var loadingText: String?
    weak var scrollView: UIScrollView?
    public var pullingPercent: CGFloat = 0 {
        didSet {
            if pullingPercent != oldValue {
                pullingPercentHandler?(pullingPercent)
            }
        }
    }
    public var pullingPercentHandler: ((_ percent: CGFloat) -> Void)?
    
    //scrollView刚开始的inset
    var scrollViewOriginalEdgeInsets = UIEdgeInsets.zero
    public var refreshHandler: ((FCXRefreshBaseView) -> Void)?
    //加载数据时悬挂的高度
    public var hangingHeight: CGFloat = 60
    public var refreshType = FCXRefreshViewType.header
    public var state = FCXRefreshViewState.noraml {
        didSet {
            if state != oldValue {
                switch state {
                case .noraml:
                    fcxRefreshStateNormal()
                    if oldValue == .loading {//之前是在刷新,更新时间
                        fcxRefreshBaseViewUpdateRefreshDate()
                    }
                case .pulling:
                    fcxRefreshViewStatePulling()
                case .loading:
                    fcxRefreshViewStateLoading()
                case .noMoreData:
                    fcxRefreshViewStateNoMoreData()
                }
            }
        }
    }
    
    open func setupContentView() {}
    
    open func autoRefresh() {}
    
    open func endRefresh() {
        state = .noraml
    }
    
    //显示没有更多数据
    open func showNoMoreData() {}
    
    //重置没有更多的数据（消除没有更多数据的状态）
    open func resetNoMoreData() {}
    
    @discardableResult
    public func pullingPercentHandler(handler: @escaping (CGFloat) -> Void) -> Self {
        pullingPercentHandler = handler
        return self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//MARK:状态的处理
public extension FCXRefreshBaseView {
    /// 刷新的类型
    ///
    /// - header: 头部下拉刷新
    /// - footer: 底部收到加载更多
    /// - autoFooter: 底部自动加载更多
    public enum FCXRefreshViewType {
        case header, footer, autoFooter
    }
    
    /// 当前的状态
    ///
    /// - noraml: 正常状态
    /// - pulling: 正在下拉或上拉
    /// - loading: 正在加载数据
    /// - noMoreData: 没有更多数据
    public enum FCXRefreshViewState {
        case noraml, pulling, loading, noMoreData
    }
    
    @objc public func fcxRefreshStateNormal() {}
    @objc public func fcxRefreshViewStatePulling() {}
    @objc public func fcxRefreshViewStateLoading() {}
    @objc public func fcxRefreshViewStateNoMoreData() {}
    @objc public func fcxRefreshBaseViewUpdateRefreshDate() {}
}

//MARK: KVO
private var FCXKVOContext = "FCXKVOContext"
extension FCXRefreshBaseView {
    func addScrollViewObservers() {
        scrollView?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: &FCXKVOContext)
        scrollView?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .new, context: &FCXKVOContext)
        scrollView?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentInset), options: .new, context: &FCXKVOContext)
    }
    
    func removeScrollViewObservers() {
        guard superview is UIScrollView else {
            return
        }
        superview?.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), context: &FCXKVOContext)
        superview?.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), context: &FCXKVOContext)
        superview?.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentInset), context: &FCXKVOContext)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &FCXKVOContext,
            let scrollView = scrollView else {
                return
        }
        
        if keyPath == #keyPath(UIScrollView.contentSize) && refreshType != .header {
            self.frame.origin.y = max(scrollView.frame.size.height, scrollView.contentSize.height)
        }else if keyPath == #keyPath(UIScrollView.contentOffset) {
            //正在刷新
            if state == .loading {
                return;
            }
            scrollViewContentOffsetDidChange(scrollView: scrollView)
        }else if keyPath == #keyPath(UIScrollView.contentInset) {
            if state != .loading {//不是正在加载的状态
                scrollViewOriginalEdgeInsets = scrollView.contentInset
            }
        }
    }
    
    @objc open func scrollViewContentOffsetDidChange(scrollView: UIScrollView) {}
}

