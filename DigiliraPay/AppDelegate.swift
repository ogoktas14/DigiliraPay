//
//  AppDelegate.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 8.08.2019.
//  Copyright © 2019 Ilao. All rights reserved.
//

import UIKit
import LocalAuthentication
import IQKeyboardManagerSwift
import WavesSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var visualEffectView = UIVisualEffectView()
    var window: UIWindow?

    func applicationDidEnterBackground(_ application: UIApplication) {


        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        WavesSDK.initialization(servicesPlugins: .init(data: [],
                                                       node: [],
                                                       matcher: []),
                                enviroment: .init(server: .testNet, timestampServerDiff: 0))
        return true
        
        // Override point for customization after application launch.
        if let isSecure = UserDefaults.standard.value(forKey: "isSecure") as? Bool
        {
            if isSecure
            {
                authenticateUser()
                visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
                visualEffectView.frame = window?.rootViewController?.view.frame ?? CGRect(x: 0,
                                                                                          y: 0,
                                                                                          width: UIScreen.main.bounds.width,
                                                                                          height: UIScreen.main.bounds.height)
                window?.rootViewController?.view.addSubview(visualEffectView)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(authenticateUser))
                visualEffectView.addGestureRecognizer(tapGesture)
            }
        }
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.overrideKeyboardAppearance = true
        IQKeyboardManager.shared.keyboardAppearance = .light
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
                
        
        return true
    }

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let URL = OpenUrlManager.parseUrlParams(openUrl: url)!
        UserDefaults.standard.set(URL, forKey: "QRARRAY")        
        NotificationCenter.default.post(name: .didReceiveData, object: nil)

        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    @objc func authenticateUser()
    {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Identify yourself!"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        print("OK")
                        self.visualEffectView.removeFromSuperview()
                    } else {
                        print("NO")
                        exit(EXIT_SUCCESS)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            window?.rootViewController!.present(ac, animated: true)
        }
    }
}


protocol DisplaysSensitiveData {
    func hideSensitiveData()
    func showSensitiveData() // we make a mess, we clean it up
}
