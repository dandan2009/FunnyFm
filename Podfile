source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!
install! 'cocoapods', generate_multiple_pod_projects: true


def layout
    pod 'SnapKit', '~> 4.0.0'
    pod 'pop', '~> 1.0'
    pod 'SHFullscreenPopGestureSwift'
    pod 'lottie-ios', '3.1.1'
		pod 'NVActivityIndicatorView'
		pod 'OfficeUIFabric', '0.2.11'
		pod 'Hero'
#		pod 'LookinServer', :configurations => ['Debug']
		pod 'AnimatedTabBar'
		pod 'DynamicColor', '~> 4.2.0'
end

def lib
    pod 'KeychainAccess'
    pod 'WCDB.swift'
    pod 'RxSwift'
		pod 'RxCocoa'
		pod 'PullToReach'
		pod 'Nuke', '~> 8.0.1'
		pod 'EFIconFont', :subspecs => ['Complete']
    pod 'SwiftyJSON'
    pod 'Moya'
    pod 'WechatOpenSDK'
		pod 'FeedKit', '~> 8.0'
		pod 'OneSignal', '>= 2.6.2', '< 3.0'
		pod 'FirebaseUI/Auth'
		pod 'FirebaseUI/Google'
		pod 'WhatsNewKit'
		pod 'YYText', '~> 1.0.7'
end


# 广告
def ads
#	pod 'Google-Mobile-Ads-SDK'
	pod 'GDTMobSDK', '~> 4.10.5'
end

# 性能和崩溃分析
def performance
	
	pod 'Fabric', '1.10.2'
	pod 'Crashlytics', '3.13.3'
	pod 'Firebase/Analytics'
	
end


target "FunnyFm" do
		ads
		performance
    layout
    lib
end

target 'OneSignalNotificationServiceExtension' do
	pod 'OneSignal', '>= 2.6.2', '< 3.0'
end
