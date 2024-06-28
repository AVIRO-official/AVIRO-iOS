# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
platform :ios, '15.0'

target 'AVIRO' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

pod 'NMapsMap'
pod 'KeychainSwift', '22.0.0'
pod 'lottie-ios', '4.4.1'
pod 'RealmSwift', '10.48.0'
pod 'Toast-Swift', '5.1.0'
pod 'AmplitudeSwift', '1.4.5'
pod 'RxSwift', '6.6.0'
pod 'RxCocoa', '6.6.0'
pod 'RxDataSources', '~> 5.0' 

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