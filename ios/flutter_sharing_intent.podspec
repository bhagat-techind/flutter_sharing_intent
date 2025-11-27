#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_sharing_intent.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_sharing_intent'
  s.version          = '1.0.1'
  s.summary          = 'Sharing intent plugin for Flutter.'
  s.description      = <<-DESC
 A Flutter plugin to receive sharing data in iOS and Android.
                       DESC
  s.homepage         = 'https://www.techind.co/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'techind' => 'techind@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'
#     'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }

  s.static_framework = false

  # Add resource bundle for Apple manifest policy
  s.resource_bundle = {
    'MySDKPrivacy' => ['Resources/PrivacyInfo.xcprivacy']
  }
  s.swift_version = '5.0'
end
