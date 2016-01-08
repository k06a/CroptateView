Pod::Spec.new do |s|
  s.name             = "ABCropRotateView"
  s.version          = "0.1.0"
  s.summary          = "Simple view allowing to crop and rotate photos"

  s.description      = <<-DESC
                       DESC

  s.homepage         = "https://github.com/k06a/ABCropRotateView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Anton Bukov" => "k06aaa@gmail.com" }
  s.source           = { :git => "https://github.com/k06a/ABCropRotateView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/k06a'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'ABCropRotateView' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'UIKit'
end
