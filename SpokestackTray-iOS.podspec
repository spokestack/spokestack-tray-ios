Pod::Spec.new do |s|
  s.name = 'SpokestackTray-iOS'
  s.module_name = 'SpokestackTray'
  s.version = '0.0.4'
  s.license = 'Apache'
  s.summary = 'Spokestack provides an extensible speech UI interface'
  s.homepage = 'https://www.spokestack.io'
  s.authors = { 'Spokestack' => 'support@spokestack.io' }
  s.source = { :git => 'https://github.com/spokestack/spockstack-tray-ios.git', :tag => s.version.to_s }
  s.license = {:type => 'Apache', :file => 'LICENSE'}
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.exclude_files = 'SpokestackTrayExample/*.*', 'SpokestackTray/Info.plist'
  s.source_files = 'SpokestackTray/**/*.{swift,h,m,c}'
  s.public_header_files = 'SpokestackTray/SpokestackTray.h'
  s.dependency "Spokestack-iOS", "13.1.4"
  s.static_framework = true
end

