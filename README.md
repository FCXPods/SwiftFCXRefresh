# SwiftFCXRefresh

[![CocoaPods compatible](https://img.shields.io/cocoapods/v/SwiftFCXRefresh.svg)](http://cocoadocs.org/docsets/SwiftFCXRefresh/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Platform](http://img.shields.io/cocoapods/p/SwiftFCXRefresh.svg?style=flat)](https://github.com/FCXPods/SwiftFCXRefresh)

[SwiftFCXRefresh](https://github.com/FCXPods/SwiftFCXRefresh)是一个使用Swift编写、用于上下拉刷新的控件。

## 特性

- [x] 普通上下拉刷新
- [x] 自动下拉刷新
- [x] 上拉无更多数据控制
- [x] 上下拉百分比显示
- [x] 自定义上下拉动画
- [x] 上拉底部间距控制

## 环境

- Xcode 11+
- Swift 5.2+
- iOS 8.0+

## 如何导入

### CocoaPods

```ruby
pod 'SwiftFCXRefresh'
```
### Carthage

```ogdl
github "FCXPods/SwiftFCXRefresh"
```

### Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/FCXPods/SwiftFCXRefresh", .upToNextMajor(from: "0.1.4"))
]
```

### 手动导入

把Sources下文件导入即可

## 如何使用

### 包含头文件

```swift
import SwiftFCXRefresh
```

### 上下拉刷新

```swift
//下拉刷新
headerRefreshView = tableView.addFCXRefreshHeader { [weak self] (refreshHeader) in
    self?.refreshAction()
    
//上拉加载更多
footerRefreshView = tableView.addFCXRefreshFooter { [weak self] (refreshFooter) in
    self?.loadMoreAction()
}

//自动上拉加载更多
footerRefreshView = tableView.addFCXRefreshAutoFooter { [weak self] (refreshFooter) in
    self?.loadMoreAction()
}
```

### 刷新自定义设置

```swift
//自动下拉刷新
headerRefreshView?.autoRefresh()

//自动上拉加载更多
footerRefreshView?.refreshType = .autoFooter

//上拉底部间距设置
footerRefreshView?.loadMoreBottomExtraSpace = 30
```

### 上下拉百分比

```swift
headerRefreshView?.pullingPercentHandler = { (percent) in
    headerPercentLabel.text = String.init(format: "%.2f%%", percent * 100)
}

footerRefreshView?.pullingPercentHandler = { (percent) in
    footererPercentLabel.text = String.init(format: "%.2f%%", percent * 100)
}
```

### 上下拉刷新、百分比链式调用

```swift
headerRefreshView = tableView.addFCXRefreshHeader { [weak self] (refreshHeader) in
    self?.refreshAction()
}.pullingPercentHandler(handler: { (percent) in
    //百分比
    print("current percent", percent)
})

footerRefreshView = tableView.addFCXRefreshFooter { [weak self] (refreshFooter) in
    self?.loadMoreAction()
}.pullingPercentHandler { (percent) in
    print("current percent", percent)
}
```

## 显示效果：

![FCXRefresh.gif](https://raw.githubusercontent.com/FCXPods/SwiftFCXRefresh/master/FCXRefresh.gif)


## License

SwiftFCXRefresh is released under the MIT license. See [LICENSE](https://github.com/FCXPods/SwiftFCXRefresh/blob/master/LICENSE) for details.
