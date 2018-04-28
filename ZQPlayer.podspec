Pod::Spec.new do |s|

  s.name         = "ZQPlayer"
  s.version      = "0.1.2"
  s.summary      = "一个基于AVPlayer封装的视频、音频播放器"
  s.description  = <<-DESC
                    ZQPlayer一个基于AVPlayer封装的视频、音频播放器
                   DESC

  s.homepage     = "https://github.com/qigge/ZQPlayer"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Eric" => "wangzeqi2013@foxmail.com" }

  s.platform     = :ios
  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/qigge/ZQPlayer.git", :tag => "#{s.version}" }
  s.source_files  = "ZQPlayer", "ZQPlayer/**/*.{h,m}"

  # s.public_header_files = "Classes/**/*.h"
  s.resources  = "ZQPlayer/ZQPlayerImage.bundle"

  s.frameworks = "UIKit", "AVFoundation"
  s.requires_arc = true

  s.dependency "Masonry"

end
