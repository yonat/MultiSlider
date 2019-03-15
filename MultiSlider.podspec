
Pod::Spec.new do |s|

  s.name         = "MultiSlider"
  s.version      = "1.9.1"
  s.summary      = "UISlider clone with multiple thumbs and values, optional snap intervals, optional value labels."

  s.homepage     = "https://github.com/yonat/MultiSlider"
  s.screenshots  = ["https://raw.githubusercontent.com/yonat/MultiSlider/master/Screenshots/MultiSlider.png"]

  s.license      = { :type => "MIT", :file => "LICENSE.txt" }

  s.author             = { "Yonat Sharon" => "yonat@ootips.org" }
  s.social_media_url   = "http://twitter.com/yonatsharon"

  s.swift_version = '4.2'
  s.platform     = :ios, "9.0"
  s.requires_arc = true

  s.source       = { :git => "https://github.com/yonat/MultiSlider.git", :tag => s.version }
  s.source_files  = "Sources/*.swift"

  s.dependency 'MiniLayout'
  s.dependency 'AvailableHapticFeedback'
end
