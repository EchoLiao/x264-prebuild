Pod::Spec.new do |s|
  s.name                = "x264-prebuild@EchoLiao"
  s.version             = "20141123.2245.2"
  s.summary             = "x264 static libraries compiled for iOS"
  s.homepage            = "http://www.videolan.org/developers/x264.html"
  s.author              = { "Echo Liao" => "echoliao8@gmail.com" }
  s.requires_arc        = false
  s.platform            = :ios
  s.source              = { :http => "http://github.com/EchoLiao/x264-prebuild/raw/master/x264-iOS-20141123.2245.2-stable.tgz" }
  s.preserve_paths      = "include/**/*.h"
  s.vendored_libraries  = 'lib/*.a'
  s.libraries           = 'x264'
  s.xcconfig            = { 'HEADER_SEARCH_PATHS' => "\"${PODS_ROOT}/#{s.name}/include\"" }
end
