//
//  FCXRefreshBaseView.swift
//  FCXRefresh
//
//  Created by 冯 传祥 on 2017/6/16.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

import UIKit

open class FCXRefreshBaseView: UIView {
    required public init(frame: CGRect, hangingOffsetHeight hangingH: CGFloat = 55, refreshType type: FCXRefreshViewType = .header, refreshHandler handler: @escaping (FCXRefreshBaseView) -> Void) {
        refreshType = type
        refreshHandler = handler
        hangingOffsetHeight = hangingH
        super.init(frame: frame)
        //添加刷新的界面
        addRefreshContentView()
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
    var contentOffsetObs: NSKeyValueObservation?
    var contentSizeObs: NSKeyValueObservation?
    var contentInsetObs: NSKeyValueObservation?
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
    public var pullingPercentHandler: ((_ percent: CGFloat) -> Void)?
    
    ///scrollView刚开始的inset
    var scrollViewOriginalEdgeInsets = UIEdgeInsets.zero
    public var refreshHandler: ((FCXRefreshBaseView) -> Void)?
    ///加载数据时悬挂的高度
    public var hangingOffsetHeight: CGFloat = 55
    public var arrowOffsetX: CGFloat = 0
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
                case .willLoading:
                    break
                case .loading:
                    fcxRefreshViewStateLoading()
                case .noMoreData:
                    fcxRefreshViewStateNoMoreData()
                }
            }
        }
    }
        
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

    /// 下面是状态改变时，可以对动画等作出d自定义处理
    open func fcxChangeToStatusNormal() {}
    open func fcxChangeToStatusPulling() {}
    open func fcxChangeToStatusWillLoading() {}
    open func fcxChangeToStatusLoading() {}
    open func fcxChangeToStatusNoMoreData() {}

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
    
    @objc func fcxRefreshStateNormal() {}
    @objc func fcxRefreshViewStatePulling() {}
    @objc func fcxRefreshViewStateLoading() {}
    @objc func fcxRefreshViewStateNoMoreData() {}
    @objc func fcxRefreshBaseViewUpdateRefreshDate() {}
}

//MARK: KVO
private var FCXKVOContext = "FCXKVOContext"
extension FCXRefreshBaseView {
    func addScrollViewObservers() {
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
            contentSizeObs = scrollView?.observe(\UIScrollView.contentOffset, changeHandler: { [weak self] (scrollView, _) in
                if self?.refreshType == .header {
                    return
                }
                self?.scrollViewContentSizeDidChange(scrollView: scrollView)
            })
        }
        contentInsetObs = scrollView?.observe(\UIScrollView.contentOffset, changeHandler: { [weak self] (scrollView, _) in
            if self?.state != .loading {//不是正在加载的状态
                self?.scrollViewOriginalEdgeInsets = scrollView.contentInset
            }
        })
    }
    
    func removeScrollViewObservers() {
        contentOffsetObs = nil
        contentSizeObs = nil
        contentInsetObs = nil
    }
    
    /// 当scrollView的contentOffset发生改变的时候调用
    ///
    /// - Parameter scrollView: scrollView
    @objc open func scrollViewContentOffsetDidChange(scrollView: UIScrollView) {}
    
    /// 当scrollView的contentSize发生改变的时候调用
    ///
    /// - Parameter scrollView: scrollView
    @objc open func scrollViewContentSizeDidChange(scrollView: UIScrollView) {}

}

