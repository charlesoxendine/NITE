//
//  AppDelegate.swift
//  NITE
//
//  Created by Charles Oxendine on 4/11/22.
//

import UIKit
import Firebase
import SCSDKLoginKit
import SendBirdSDK
import SendBirdUIKit
import RevenueCat

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        Purchases.logLevel = .debug
        
        let APPID = "29E0A5DC-4102-454D-ACB0-59EC1403BC17"
        SBDMain.initWithApplicationId(APPID, useCaching: false) {
            print("Successfully initialized Sendbird application")
        } completionHandler: { error in
            print("[SENDBIRD] Error initializing app with message: \(error?.localizedDescription ?? "")")
        }
        
        SBUStringSet.Empty_No_Channels = "No Matches, get swiping!"
        SBUStringSet.ChannelList_Header_Title = "Matches"
        
        // set channel list theme
        let channelListTheme = SBUChannelListTheme(
            leftBarButtonTintColor: .themeBlueGray(),
            rightBarButtonTintColor: .themeBlueGray()
        )

        let channelTheme = SBUChannelTheme(leftBarButtonTintColor: .themeBlueGray(),
                                           rightBarButtonTintColor: .themeBlueGray(),
                                           menuTextColor: .themeBlueGray(),
                                           menuItemTintColor: .themeBlueGray(),
                                           channelStateBannerTextColor: .themeBlueGray(),
                                           channelStateBannerBackgroundColor: .themeBlueGray())
        
        let listTheme = SBUMessageCellTheme(leftBackgroundColor: .themeLight(), rightBackgroundColor: .themeBlueGray(), userMessageLeftTextColor: .black, userMessageRightTextColor: .white)
        
        let newTheme = SBUTheme(
            channelListTheme: channelListTheme, channelTheme: channelTheme, messageCellTheme: listTheme)

        SBUTheme.set(theme: newTheme)
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if SCSDKLoginClient.application(app, open: url, options: options) {
          return true
        }
        
        return true
    }
}
