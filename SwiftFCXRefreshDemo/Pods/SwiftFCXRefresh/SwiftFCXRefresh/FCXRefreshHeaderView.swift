//
//  FCXRefreshHeaderView.swift
//  FCXRefresh
//
//  Created by 冯 传祥 on 2017/6/16.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

import UIKit

private let createLabel = { () -> UILabel in
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12)
    label.textAlignment = .center
    label.textColor = UIColor.init(red: 150/255.0, green: 150/255.0, blue: 150/255.0, alpha: 1)
    return label
}

open class FCXRefreshHeaderView: FCXRefreshBaseView {

    let statusLabel = createLabel()
    let dateLabel = createLabel()
    let arrowImageView = UIImageView.init(image: UIImage.init(named: "arrow", in: Bundle.init(for: FCXRefreshBaseView.self), compatibleWith: nil))
    let activityView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
    
    override open func setupContentView() {
        addSubview(statusLabel)
        addSubview(dateLabel)
        addSubview(arrowImageView)
        addSubview(activityView)
        normalText = "下拉即可刷新"
        pullingText = "松开即可刷新"
        loadingText = "正在刷新..."
        
        statusLabel.text = normalText
        dateLabel.text = currentDateString()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        statusLabel.frame = CGRect.init(x: 0, y: self.frame.size.height - 45, width: self.frame.size.width, height: 15)
        dateLabel.frame = CGRect.init(x: 0, y: self.frame.size.height - 25, width: self.frame.size.width, height: 15)
        arrowImageView.frame = CGRect.init(x: self.frame.size.width/2 - 90, y: self.frame.size.height - 50 + 3, width: 15, height: 40)
        activityView.frame = arrowImageView.frame
    }

    open override func scrollViewContentOffsetDidChange(scrollView: UIScrollView) {
       
        if scrollView.contentOffset.y > -scrollViewOriginalEdgeInsets.top {
            //向上滚动到看不见头部控件，直接返回
            return
        }

        if scrollView.isDragging {//正在拖拽
            if scrollView.contentOffset.y + scrollViewOriginalEdgeInsets.top < -hangingHeight {//大于偏移量，转为pulling
                state = .pulling
            } else {//小于偏移量，转为正常normal
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
            let offsetHeight = -scrollView.contentOffset.y - scrollViewOriginalEdgeInsets.top
            if offsetHeight >= 0 && offsetHeight <= hangingHeight {
                //有时进度可能会到0.991..对精度要求没那么高可以忽略
                pullingPercent = offsetHeight/hangingHeight;
            }
        }
    }
    
    open override func fcxRefreshStateNormal() {
        statusLabel.text = normalText
        activityView.stopAnimating()
        arrowImageView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.arrowImageView.transform = .identity
            self.scrollView?.contentInset = self.scrollViewOriginalEdgeInsets
        })
    }
    
    open override func fcxRefreshViewStatePulling() {
        statusLabel.text = pullingText
        UIView.animate(withDuration: 0.2, animations: {
            self.arrowImageView.transform = CGAffineTransform.init(rotationAngle: 0.000001 - .pi)
        })
    }
    
    open override func fcxRefreshViewStateLoading() {
        statusLabel.text = loadingText
        activityView.startAnimating()
        arrowImageView.isHidden = true
        arrowImageView.transform = .identity
        UIView.animate(withDuration: 0.2, animations: {
            var edgeInset = self.scrollViewOriginalEdgeInsets
            edgeInset.top += self.hangingHeight
            self.scrollView?.contentInset = edgeInset
        })
        
        refreshHandler?(self)
    }
        
    open override func fcxRefreshBaseViewUpdateRefreshDate() {
        dateLabel.text = currentDateString()
    }
    
    open override func autoRefresh() {
        state = .loading
        UIView.animate(withDuration: 0.2, animations: {
            let contentOffset = CGPoint.init(x: self.scrollView?.contentOffset.x ?? 0, y: -self.hangingHeight - self.scrollViewOriginalEdgeInsets.top)
            self.scrollView?.contentOffset = contentOffset
        })
        { (finished) in
            self.state = .loading
        }
    }
    
    public func currentDateString() -> String {
        let threadDict = Thread.current.threadDictionary
        guard let dateFormatter = threadDict.object(forKey: "FCXRefeshDateFormatterKey") as? DateFormatter else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "最后更新：今天 HH:mm"
            threadDict.setObject(dateFormatter, forKey: "FCXRefeshDateFormatterKey" as NSCopying)
            return dateFormatter .string(from: Date())
        }
        return dateFormatter .string(from: Date())
    }
}
