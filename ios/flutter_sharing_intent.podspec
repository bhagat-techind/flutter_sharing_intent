#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_sharing_intent.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_sharing_intent'
  s.version          = '1.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'https://www.techind.co/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'techind' => 'techind@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
#   s.public_header_files = 'Classes/**/*.h'
  s.exclude_files = 'Classes/Shared/**/*'
  s.subspec 'SharedCore' do |core|
    core.source_files = 'Classes/Shared/**/*.{swift}'
    core.public_header_files = 'Classes/Shared/**/*.h'
    core.frameworks = 'MobileCoreServices', 'UIKit', 'AVFoundation'
    core.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
#       core.source_files = [
#         'Classes/Shared/**/*.{swift,h,m}',
#         'Classes/SharedConstants.swift'
#       ]
#     core.swift_version = '5.0'
  end
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  # Add resource bundle for Apple manifest policy
  s.resource_bundle = {
    'MySDKPrivacy' => ['Resources/PrivacyInfo.xcprivacy']
  }
  s.swift_version = '5.0'
end
