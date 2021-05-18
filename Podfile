# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'E-Shop' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for E-Shop
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Gallery'
  pod 'InstantSearchClient'
  pod 'EmptyDataSet-Swift'
  pod 'NVActivityIndicatorView/AppExtension'
  pod 'JGProgressHUD'
  pod 'PayPal-iOS-SDK'
  pod 'Stripe'
  pod 'Alamofire'

  target 'E-ShopTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'E-ShopUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end
