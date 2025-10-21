Pod::Spec.new do |s|
  s.name             = 'linkrunner'
  s.version          = '3.2.0'
  s.summary          = 'Flutter Package for linkrunner, track every click, download and dropoff for your app links'
  s.description      = <<-DESC
Flutter Package for linkrunner.io - Advanced app attribution and link tracking service. 
This package provides comprehensive app attribution tracking, deep linking capabilities, 
user event tracking, and payment analytics for Flutter applications.
                       DESC
  s.homepage         = 'https://www.linkrunner.io/'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'LinkRunner' => 'support@linkrunner.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'LinkrunnerKit', '3.2.0'
  s.platform = :ios, '15.0'
  s.swift_version = '5.9'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'SWIFT_INSTALL_OBJC_HEADER' => 'NO',
    'SWIFT_OBJC_INTERFACE_HEADER_NAME' => 'linkrunner-Swift.h',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }
end
