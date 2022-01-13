Pod::Spec.new do |s|
  s.name          = "SwiftFCXRefresh"
  s.swift_version = '5.2'
  s.version       = "0.1.5"
  s.summary       = "An easy way to use pull-to-refresh and loading-more in Swift"
  s.homepage      = "https://github.com/FCXPods/SwiftFCXRefresh"
  s.license       = "MIT"
  s.author        = { "fengchuanxiang" => "fengchuanxiang@126.com" }
  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/FCXPods/SwiftFCXRefresh.git", :tag => s.version }
  s.source_files  = "Sources/*.swift"
  s.resources     = "Sources/*.png"
  s.requires_arc  = true
end
