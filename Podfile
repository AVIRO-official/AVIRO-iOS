# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
platform :ios, '15.0'

target 'AVIRO' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

pod 'NMapsMap'
pod 'KeychainSwift'
pod 'lottie-ios'
pod 'RealmSwift'
pod 'Toast-Swift'
pod 'AmplitudeSwift', '~> 0.4.14'
pod 'RxSwift', '6.6.0'
pod 'RxCocoa', '6.6.0'

  # Pods for AVIRO

end

target 'AVIROTests' do 

pod 'RxBlocking', '6.6.0' 
pod 'RxTest', '6.6.0'

end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end