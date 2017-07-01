# SwiftFCXRefresh
常用的上下拉刷新功能都支持可自定义，只需简单的两三行代码即可完成，主要支持以下功能：
* 普通上下拉刷新
* 自动上下拉刷新
* 上拉无更多数据控制
* 上下拉百分比显示
* 自定义上下拉动画

## 环境
* Xcode 8.0+
* Swift 3.0+
* iOS 8.0+

## 如何导入
* 1.手动导入
```objc
把SwiftFCXRefresh文件夹导入即可
```
* 2.使用CocoaPods
```objc
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'SwiftFCXRefresh'
end
```
## 如何使用
包含头文件
```objc
import SwiftFCXRefresh
```
下拉刷新
```objc
headerRefreshView = tableView.addFCXRefreshHeader { [weak self] (refreshHeader) in
    self?.refreshAction()
}
```

自动下拉刷新调用
```objc
headerRefreshView?.autoRefresh()
```

上拉加载更多
```objc
footerRefreshView = tableView.addFCXRefreshAutoFooter { [weak self] (refreshHeader) in
    self?.loadMoreAction()
}
```

自动上拉刷加载更多
```objc
footerRefreshView = tableView.addFCXRefreshAutoFooter { [weak self] (refreshHeader) in
    self?.loadMoreAction()
}
```

上下拉百分比显示
```objc
headerRefreshView?.pullingPercentHandler = { (percent) in
    headerPercentLabel.text = String.init(format: "%.2f%%", percent * 100)
}

footerRefreshView?.pullingPercentHandler = { (percent) in
    footererPercentLabel.text = String.init(format: "%.2f%%", percent * 100)
}
```

上下拉刷新、百分比链式调用
```objc
headerRefreshView = tableView.addFCXRefreshHeader { [weak self] (refreshHeader) in
    self?.refreshAction()
}.pullingPercentHandler(handler: { (percent) in
    //百分比
    print("current percent", percent)
})

footerRefreshView = tableView.addFCXRefreshFooter { [weak self] (refreshHeader) in
    self?.loadMoreAction()
}.pullingPercentHandler { (percent) in
    print("current percent", percent)
}
```

显示效果：
![](FCXRefresh.gif)
