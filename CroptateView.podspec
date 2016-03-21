Pod::Spec.new do |s|
  s.name             = "CroptateView"
  s.version          = "0.2.1"
  s.summary          = "Simple view allowing to crop and rotate photos"

  s.description      = <<-DESC
                        You can easily create photo editor to crop, pan and rotate photo.
                        Editor is able to draw aspect ratio lines while cropping and avoid
                        image edges accurately while cropping and rotating image.
                       DESC

  s.homepage         = "https://github.com/k06a/CroptateView"
  s.screenshots      = "https://raw.githubusercontent.com/k06a/CroptateView/master/screenshot.png"
  s.license          = 'MIT'
  s.author           = { "Anton Bukov" => "k06aaa@gmail.com" }
  s.source           = { :git => "https://github.com/k06a/CroptateView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/k06a'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'ABCropRotateView' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'UIKit'
end
