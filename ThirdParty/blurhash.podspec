# BlurHash Podspec for MunrChat iOS Project - Updated 2025
# A very compact representation of a placeholder for an image

Pod::Spec.new do |s|
  s.name               = "blurhash"
  s.version            = "0.0.2"
  s.summary            = "A very compact representation of a placeholder for an image."
  s.description        = "A pure-Swift library for generating and decoding very compact image placeholders. Updated for MunrChat iOS."
  s.homepage           = "https://github.com/woltapp/blurhash"
  s.license            = { :type => "MIT", :file => "Swift/License.txt" }
  s.author             = { "Dag Ågren" => "paracelsus@gmail.com" }
  s.social_media_url   = "https://github.com/woltapp"
  s.swift_versions     = ["5.9", "5.10", "6.0"]
  s.ios.deployment_target = "15.0"
  s.source             = { :git => "https://github.com/woltapp/blurhash.git", :commit => "0a1f97898d9eb8952bc528cd7a8ec73d9fecf5d0" }
  s.source_files       = "Swift/*.swift"
  s.frameworks         = "Foundation", "UIKit"
  s.requires_arc       = true
end
