//
//  FCXRefreshBaseView.swift
//  FCXRefresh
//
//  Created by 冯 传祥 on 2017/6/16.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

import UIKit

open class FCXRefreshBaseView: UIView {
    public var normalText: String?
    public var pullingText: String?
    public var loadingText: String?
    weak var scrollView: UIScrollView?
    ///刷新偏移量百分比
    public var pullingPercentHandler: ((_ percent: CGFloat) -> Void)?
    ///scrollView刚开始的inset
    var scrollViewOriginalEdgeInsets = UIEdgeInsets.zero
    public var refreshHandler: ((FCXRefreshBaseView) -> Void)?
    ///加载数据时悬挂的高度
    public var hangingOffsetHeight: CGFloat = 55
    public var arrowOffsetX: CGFloat = 0
    public var refreshType = FCXRefreshViewType.header
    /* 11以下系统闪退
    var contentOffsetObs: NSKeyValueObservation?
    var contentSizeObs: NSKeyValueObservation?
    var contentInsetObs: NSKeyValueObservation?
 */
    var scrollViewEdgeInsets: UIEdgeInsets {
        guard let scrollView = scrollView else {
            return UIEdgeInsets.zero
        }
        if #available(iOS 11.0, *) {
            return scrollView.adjustedContentInset
        } else {
            return scrollView.contentInset;
        }
    }
    public var pullingPercent: CGFloat = 0 {
        didSet {
            if pullingPercent != oldValue {
                pullingPercentHandler?(pullingPercent)
            }
        }
    }
    public var state = FCXRefreshViewState.noraml {
        didSet {
            if state != oldValue {
                switch state {
                case .noraml:
                    fcxChangeToStatusNormal()
                    if oldValue == .loading {//之前是在刷新,更新时间
                        fcxChangeToRefreshDate()
                    }
                case .pulling:
                    fcxChangeToStatusPulling()
                case .willLoading:
                    fcxChangeToStatusWillLoading()
                    break
                case .loading:
                    fcxChangeToStatusLoading()
                case .noMoreData:
                    fcxChangeToStatusNoMoreData()
                }
            }
        }
    }

    //MARK:初始化
    
    required public init(frame: CGRect, hangingOffsetHeight hangingH: CGFloat = 55, refreshType type: FCXRefreshViewType = .header, refreshHandler handler: @escaping (FCXRefreshBaseView) -> Void) {
        refreshType = type
        refreshHandler = handler
        hangingOffsetHeight = hangingH
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        //添加刷新的界面
        addRefreshContentView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addRefreshContentView()
    }

    //MARK:添加观察者

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
     
    // MARK: 刷新界面、状态方法

    /// 添加刷新的界面
    ///
    /// * 注：如果想自定义刷新加载界面，可在子类中重写该方法进行布局子界面
    open func addRefreshContentView() {}
    
    ///自动刷新
    open func autoRefresh() {}
    
    ///结束刷新
    open func endRefresh() {
        state = .noraml
    }
    
    ///显示没有更多数据
    open func showNoMoreData() {}
    
    ///重置没有更多的数据（消除没有更多数据的状态）
    open func resetNoMoreData() {}
    
    /// 隐藏时间
    open func hideDateView() {}
    
    /// 隐藏状态和时间
    open func hideStatusAndDateView() {}

    /// 下面是状态改变时，可以对动画等做出自定义处理
    open func fcxChangeToStatusNormal() {}
    open func fcxChangeToStatusPulling() {}
    open func fcxChangeToStatusWillLoading() {}
    open func fcxChangeToStatusLoading() {}
    open func fcxChangeToStatusNoMoreData() {}
    open func fcxChangeToRefreshDate() {}

    /// 当scrollView的contentOffset发生改变的时候调用
    ///
    /// - Parameter scrollView: scrollView
    open func scrollViewContentOffsetDidChange(scrollView: UIScrollView) {}
    
    /// 当scrollView的contentSize发生改变的时候调用
    ///
    /// - Parameter scrollView: scrollView
    open func scrollViewContentSizeDidChange(scrollView: UIScrollView) {}
    
    @discardableResult
    public func pullingPercentHandler(handler: @escaping (CGFloat) -> Void) -> Self {
        pullingPercentHandler = handler
        return self
    }
}

//MARK:刷新类型、状态

public extension FCXRefreshBaseView {
    /// 刷新的类型
    ///
    /// - header: 头部下拉刷新
    /// - footer: 底部收到加载更多
    /// - autoFooter: 底部自动加载更多
    enum FCXRefreshViewType {
        case header, footer, autoFooter
    }
    
    /// 当前的状态
    ///
    /// - noraml: 正常状态
    /// - pulling: 正在下拉或上拉
    /// - loading: 正在加载数据
    /// - noMoreData: 没有更多数据
    enum FCXRefreshViewState {
        case noraml, pulling, willLoading, loading, noMoreData
    }
}

//MARK: KVO
private var FCXKVOContext = "FCXKVOContext"
extension FCXRefreshBaseView {
    func addScrollViewObservers() {
        guard let scrollView = scrollView else {
            return
        }
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: &FCXKVOContext)
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .new, context: &FCXKVOContext)
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentInset), options: .new, context: &FCXKVOContext)
        /*
        contentOffsetObs = scrollView?.observe(\UIScrollView.contentOffset, options: .new, changeHandler: {  [weak self] (scrollView, _) in
            //正在刷新
            if self?.state == .loading {
                return;
            }
            // contentInset可能会变
            self?.scrollViewOriginalEdgeInsets = scrollView.contentInset;
            self?.scrollViewContentOffsetDidChange(scrollView: scrollView)
        })
        if refreshType != .header {
            contentSizeObs = scrollView?.observe(\UIScrollView.contentOffset, options: .new, changeHandler: { [weak self] (scrollView, _) in
                if self?.refreshType == .header {
                    return
                }
                self?.scrollViewContentSizeDidChange(scrollView: scrollView)
            })
        }
        contentInsetObs = scrollView?.observe(\UIScrollView.contentOffset, options: .new, changeHandler: { [weak self] (scrollView, _) in
            if self?.state != .loading {//不是正在加载的状态
                self?.scrollViewOriginalEdgeInsets = scrollView.contentInset
            }
        })
 */
    }
    
    func removeScrollViewObservers() {
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), context: &FCXKVOContext)
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), context: &FCXKVOContext)
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentInset), context: &FCXKVOContext)
        /*
        contentOffsetObs = nil
        contentSizeObs = nil
        contentInsetObs = nil
 */
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &FCXKVOContext,
            let scrollView = scrollView else {
                return
        }
        switch keyPath {
        case #keyPath(UIScrollView.contentOffset):
            //正在刷新
            if state == .loading {
                return;
            }
            // contentInset可能会变
            scrollViewOriginalEdgeInsets = scrollView.contentInset
            scrollViewContentOffsetDidChange(scrollView: scrollView)
        case #keyPath(UIScrollView.contentSize):
            if refreshType == .header {
                return
            }
            scrollViewContentSizeDidChange(scrollView: scrollView)
        case #keyPath(UIScrollView.contentInset):
            if state != .loading {//不是正在加载的状态
                scrollViewOriginalEdgeInsets = scrollView.contentInset
            }
        default:
            break
        }
     }
}

