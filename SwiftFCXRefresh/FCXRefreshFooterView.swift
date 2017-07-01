//
//  FCXRefreshFooterView.swift
//  FCXRefresh
//
//  Created by 冯 传祥 on 2017/6/16.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

import UIKit

open class FCXRefreshFooterView: FCXRefreshBaseView {
    var noMoreDataText = "没有更多数据"
    let statusLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = UIColor.init(red: 150/255.0, green: 150/255.0, blue: 150/255.0, alpha: 1)
        return label
    }()
    
    lazy var arrowImageView = UIImageView.init(image: UIImage.init(named: "arrow", in: Bundle.init(for: FCXRefreshBaseView.self), compatibleWith: nil))
    let activityView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)

    override open func setupContentView() {
        addSubview(statusLabel)

        if refreshType != .autoFooter {
            arrowImageView.transform = CGAffineTransform.init(rotationAngle: 0.000001 - .pi)
            addSubview(arrowImageView)
        }
        addSubview(activityView)

        normalText = "上拉加载更多"
        pullingText = "松开可加载更多"
        loadingText = "正在加载更多..."
        statusLabel.text = normalText
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        statusLabel.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 60)
        if refreshType != .autoFooter {
            arrowImageView.frame = CGRect.init(x: self.frame.size.width/2 - 90, y: 11, width: 15, height: 40)
            activityView.frame = arrowImageView.frame
        } else {
            activityView.frame = CGRect.init(x: self.frame.size.width/2 - 90, y: 11, width: 15, height: 40)
        }
    }

    open override func scrollViewContentOffsetDidChange(scrollView: UIScrollView) {
        if state == .noMoreData {//没有更多数据
            return
        }
        
        //scrollview实际显示内容高度
        let realHeight = scrollView.frame.size.height - scrollViewOriginalEdgeInsets.top - scrollViewOriginalEdgeInsets.bottom
        /// 计算超出scrollView的高度
        let beyondScrollViewHeight = scrollView.contentSize.height - realHeight
        
        guard beyondScrollViewHeight > 0 else {
            //scrollView的实际内容高度没有超出本身高度不处理
            return
        }
        
        //刚刚出现底部控件时出现的offsetY
        let offSetY = beyondScrollViewHeight - scrollViewOriginalEdgeInsets.top
        // 当前scrollView的contentOffsetY超出offsetY的高度
        let beyondOffsetHeight = scrollView.contentOffset.y - offSetY
        guard beyondOffsetHeight > 0 else {
            return;
        }
        
        if scrollView.isDecelerating && refreshType == .autoFooter {//如果是自动加载更多
            state = .loading
            return;
        }

        if scrollView.isDragging {
            if beyondOffsetHeight >= hangingHeight {
                state = .pulling
            } else {
                state = .noraml
            }
        } else {
            if state == .pulling {
                state = .loading
            } else {
                state = .noraml
            }
        }
        
        if pullingPercentHandler != nil {
            if beyondOffsetHeight <= hangingHeight {
                //有时进度可能会到0.991..对精度要求没那么高可以忽略
                pullingPercent = beyondOffsetHeight/hangingHeight;
            }
        }
    }
    
    open override func fcxRefreshStateNormal() {
        statusLabel.text = normalText
        activityView.stopAnimating()
        arrowImageView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.arrowImageView.transform = CGAffineTransform.init(rotationAngle: 0.000001 - .pi)
            self.scrollView?.contentInset = self.scrollViewOriginalEdgeInsets
        })
    }
    
    open override func fcxRefreshViewStatePulling() {
        statusLabel.text = pullingText
        UIView.animate(withDuration: 0.2, animations: {
            self.arrowImageView.transform = .identity
        })
    }
    
    open override func fcxRefreshViewStateLoading() {
        statusLabel.text = loadingText
        activityView.startAnimating()
        arrowImageView.isHidden = true
        arrowImageView.transform = CGAffineTransform.init(rotationAngle: 0.000001 - .pi)
        UIView.animate(withDuration: 0.2, animations: {
            var edgeInset = self.scrollViewOriginalEdgeInsets
            edgeInset.bottom += self.hangingHeight
            self.scrollView?.contentInset = edgeInset
        })
        
        refreshHandler?(self as FCXRefreshBaseView)
    }

    open override func fcxRefreshViewStateNoMoreData() {
        statusLabel.text = noMoreDataText
    }
    
    open override func showNoMoreData() {
        fcxRefreshStateNormal()
        state = .noMoreData
        if refreshType != .autoFooter {
            arrowImageView.isHidden = true
        }
    }
    
    open override func resetNoMoreData() {
        state = .noraml
    }
}
