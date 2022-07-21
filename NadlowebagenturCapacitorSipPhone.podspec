require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name = 'NadlowebagenturCapacitorSipPhone'
  s.version = package['version']
  s.summary = package['description']
  s.license = package['license']
  s.homepage = package['repository']['url']
  s.author = package['author']
  s.source = { :git => package['repository']['url'], :tag => s.version.to_s }
  s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
  s.ios.deployment_target  = '13.0'

  s.dependency 'Capacitor'

  s.dependency 'linphone-sdk'
  s.dependency 'linphone-sdk/basic-frameworks'
  s.dependency 'linphone-sdk/app-extension-swift'

  s.swift_version = '5.1'
end
