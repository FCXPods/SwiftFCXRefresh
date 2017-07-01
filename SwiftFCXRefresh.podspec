Pod::Spec.new do |s|
  s.name         = "SwiftFCXRefresh"
  s.version      = "0.1.0"
  s.summary      = "Swift版上下拉刷新."
  s.description  = <<-DESC
		提供简便的上下拉刷新，支持自定义，只需简单的两三行代码即可.
                   DESC
  s.homepage     = "https://github.com/fengchuanxiang/SwiftFCXRefresh"
  s.license      = "MIT"
  s.author             = { "fengchuanxiang" => "fengchuanxiang@126.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/fengchuanxiang/SwiftFCXRefresh.git", :tag => s.version }
  s.source_files  = "SwiftFCXRefresh/"
  s.resources = "SwiftFCXRefresh/*.png"
  s.requires_arc = true
end
