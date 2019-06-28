//
//  GlobalConfig.swift
//  FunnyFm
//
//  Created by Duke on 2018/11/9.
//  Copyright © 2018 Duke. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import SHFullscreenPopGestureSwift
import AppCenter
import AppCenterDistribute
import AppCenterAnalytics
import AppCenterCrashes
import OneSignal

public func configureThridSDK(launchOptions: [UIApplication.LaunchOptionsKey: Any]?){
	
	MSAppCenter.start("f9778dd8-1385-462e-a4e1-fa37182cb200", withServices:[MSAnalytics.self,MSCrashes.self])
	
	let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
	
	OneSignal.initWithLaunchOptions(launchOptions,
									appId:"30cd881e-c916-44d2-8293-b2f7e2c7deae",
									handleNotificationAction: nil,
									settings: onesignalInitSettings)
	
	OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
	
	OneSignal.promptForPushNotifications(userResponse: { accepted in
		print("User accepted notifications: \(accepted)")
	})
}

public func configureNavigationTabBar() {
	SHFullscreenPopGesture.configure()
    UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    UINavigationBar.appearance().shadowImage = UIImage()
    UINavigationBar.appearance().isTranslucent = true
    UINavigationBar.appearance().titleTextAttributes = [
        NSAttributedString.Key.foregroundColor: CommonColor.title.color,
		NSAttributedString.Key.font: p_bfont(14)
    ]
}

public func configureTextfield(){
	UITextField.appearance().tintColor = CommonColor.mainRed.color
}

public func configPlayBackgroungMode(){
	let session = AVAudioSession.sharedInstance()
	do {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        try session.setCategory(.playback, mode: .default, options: .allowAirPlay)
        try session.setActive(true)
	} catch {
		print(error)
	}
}
