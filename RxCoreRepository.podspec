#
# Be sure to run `pod lib lint CoreRequest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxCoreRepository'
  s.version          = '0.1.0'
  s.summary          = 'Clean Architecture'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
iOS project code-base inspired by modern architectures: Redux, RIBs
                       DESC

  s.homepage         = 'https://github.com/dungntm58/iOSRxCore'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dungntm58' => 'minhdung.uet.work@gmail.com' }
  s.source           = { :git => 'https://github.com/dungntm58/iOSRxCore', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.module_name = 'RxCoreRepository'
  s.swift_version = "5.2"
  s.framework = "Foundation"

  s.default_subspecs = 'Basics', 'DataStore', 'Request', 'Remote', 'Local', 'RemoteLocal'
  
  s.subspec 'Basics' do |ss|
    ss.source_files = 'Sources/Repository/Basics/**/*'
    ss.dependency 'RxSwift'
  end

  s.subspec 'DataStore' do |ss|
    ss.source_files = 'Sources/Repository/DataStore/**/*'
    ss.dependency 'RxCoreRepository/Basics'
  end

  s.subspec 'Request' do |ss|
    ss.source_files = 'Sources/Repository/Request/**/*'
    ss.dependency 'Alamofire'
    ss.dependency 'RxCoreRepository/Basics'
  end

  s.subspec 'Remote' do |ss|
    ss.source_files = 'Sources/Repository/Remote/**/*'
    ss.dependency 'RxCoreRepository/Basics'
    ss.dependency 'RxCoreRepository/Request'
  end

  s.subspec 'Local' do |ss|
    ss.source_files = 'Sources/Repository/Local/**/*'
    ss.dependency 'RxCoreRepository/Basics'
    ss.dependency 'RxCoreRepository/DataStore'
  end

  s.subspec 'RemoteLocal' do |ss|
    ss.source_files = 'Sources/Repository/RemoteLocal/**/*'
    ss.dependency 'RxCoreRepository/Remote'
    ss.dependency 'RxCoreRepository/Local'
  end
end
