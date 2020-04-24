//
//  FCXRefreshFooterView.swift
//  FCXRefresh
//
//  Created by 冯 传祥 on 2017/6/16.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

import UIKit

open class FCXRefreshFooterView: FCXRefreshBaseView {
    public var noMoreDataText = "没有更多数据" {
        didSet {
            statusLabel.text = noMoreDataText
        }
    }
    ///加载更多底部显示时额外的高度
    public var loadMoreBottomExtraSpace: CGFloat = 0
    ///加载更多时忽略ContentSize的高度是否大于自身frame高度（判断高度性能更好，默认值NO，也就是当ContentSize高度小于自身frame高度时不会加载更多），这里是为了处理数据内容小于自身高度还需自动加载更多
    public var loadMoreIgnoreContentSize = false
    public let statusLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = UIColor.init(red: 150/255.0, green: 150/255.0, blue: 150/255.0, alpha: 1)
        return label
    }()
    
    lazy var arrowImageView = UIImageView.init(image: UIImage.init(named: "fcx_arrow", in: Bundle.init(for: FCXRefreshBaseView.self), compatibleWith: nil))
    let activityView = UIActivityIndicatorView.init(style: .gray)

    override open func addRefreshContentView() {
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
        if !statusLabel.isHidden {
            statusLabel.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: hangingOffsetHeight)
        }
        if refreshType == .autoFooter {
            activityView.frame = CGRect.init(x: self.frame.size.width/2 - 80, y: (hangingOffsetHeight - 40)/2.0, width: 15, height: 40)
        } else {
            arrowImageView.frame = CGRect.init(x: self.frame.size.width/2 - (statusLabel.isHidden ? 7.5 : 80) + arrowOffsetX, y: (hangingOffsetHeight - 40)/2.0, width: 15, height: 40)
            activityView.frame = arrowImageView.frame
        }
    }
    
    open override func hideStatusAndDateView() {
        statusLabel.isHidden = true
        setNeedsLayout()
    }

    open override func scrollViewContentSizeDidChange(scrollView: UIScrollView) {
        self.frame.origin.y = (max(scrollView.frame.size.height - self.scrollViewEdgeInsets.top - self.scrollViewEdgeInsets.bottom, scrollView.contentSize.height)) + self.loadMoreBottomExtraSpace
    }
    
    open override func scrollViewContentOffsetDidChange(scrollView: UIScrollView) {
        if state == .noMoreData {//没有更多数据
            return
        }
        
        let edgeTop = self.scrollViewEdgeInsets.top
        let edgeBotom = self.scrollViewEdgeInsets.bottom + self.loadMoreBottomExtraSpace
        //scrollview实际显示内容高度
        let realHeight = scrollView.frame.size.height - edgeTop - edgeBotom
        /// 计算超出scrollView的高度
        var beyondScrollViewHeight = scrollView.contentSize.height - realHeight
        
        if beyondScrollViewHeight <= 0 {
            if loadMoreIgnoreContentSize {
                beyondScrollViewHeight = 0
            } else {//scrollView的实际内容高度没有超出本身高度不处理
                return
            }
        }
        
        //刚刚出现底部控件时出现的offsetY
        let offSetY = beyondScrollViewHeight - edgeTop
        // 当前scrollView的contentOffsetY超出offsetY的高度
        let beyondOffsetHeight = scrollView.contentOffset.y - offSetY
        guard beyondOffsetHeight > 0 else {
            return;
        }
        if refreshType == .autoFooter {//如果是自动加载更多
            //大于偏移量，转为加载更多loading
            state = .loading;
            return
        }
        
        if scrollView.isDragging {
            if beyondOffsetHeight >= hangingOffsetHeight {
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
            pullingPercent = min(beyondOffsetHeight, hangingOffsetHeight)/hangingOffsetHeight;
        }
    }
    
    open override func fcxChangeToStatusNormal() {
        statusLabel.text = normalText
        activityView.stopAnimating()
        arrowImageView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.arrowImageView.transform = CGAffineTransform.init(rotationAngle: 0.000001 - .pi)
            self.scrollView?.contentInset = self.scrollViewOriginalEdgeInsets
        })
    }
    
    open override func fcxChangeToStatusPulling() {
        statusLabel.text = pullingText
        UIView.animate(withDuration: 0.2, animations: {
            self.arrowImageView.transform = .identity
        })
    }
    
    open override func fcxChangeToStatusLoading() {
        statusLabel.text = loadingText
        activityView.startAnimating()
        arrowImageView.isHidden = true
        arrowImageView.transform = CGAffineTransform.init(rotationAngle: 0.000001 - .pi)
        UIView.animate(withDuration: 0.2, animations: {
            var edgeInset = self.scrollViewOriginalEdgeInsets
            edgeInset.bottom += (self.hangingOffsetHeight + self.loadMoreBottomExtraSpace)
            self.scrollView?.contentInset = edgeInset
        })
        
        refreshHandler?(self as FCXRefreshBaseView)
    }

    open override func fcxChangeToStatusNoMoreData() {
        statusLabel.text = noMoreDataText
    }
    
    open override func showNoMoreData() {
        fcxChangeToStatusNormal()
        state = .noMoreData
        if refreshType != .autoFooter {
            arrowImageView.isHidden = true
        }
    }
    
    open override func resetNoMoreData() {
        state = .noraml
    }
}
