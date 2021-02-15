//
//  AppDelegate.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 8.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit
import LocalAuthentication
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func applicationDidEnterBackground(_ application: UIApplication) {


        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let selfied = UserDefaults.standard.value(forKey: "isSelfied") as? Bool {
            if selfied {
                NotificationCenter.default.post(name: Notification.Name(.bar), object: nil)
            }
        }
        
        if let identity = UserDefaults.standard.value(forKey: "isIdentity") as? Bool {
            if identity {
                NotificationCenter.default.post(name: Notification.Name(.bar), object: nil)
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.window?.viewWithTag(74396893368329)?.alpha = 0
        }, completion: {_ in
            self.window?.viewWithTag(74396893368329)?.removeFromSuperview()
        })
        
        NotificationCenter.default.post(name: .didCompleteTask, object: nil)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let isCydia = UIDevice.current.isJailBroken
        
        if isCydia {
            exit(-1)
        }
        
        return true

    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        if UserDefaults.standard.value(forKey: "isSecure") == nil {
            blur()
            return
        }
        guard let isOnScreen = UserDefaults.standard.value(forKey: "biometrics") as? Bool  else { return }
        if isOnScreen {return}
        blur()
    }
     
    func blur() {
        let screenSize: CGRect = UIScreen.main.bounds
        
        if let img = UIImage(named: "appLogoWhite") {
            let myView = DLGradient(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
            let myLogo = UIImageView(frame: CGRect(x: (screenSize.width/2) - (img.size.width / 2),
                                                   y: (screenSize.height/2) - (img.size.height / 2),
                                                   width: img.size.width,
                                                   height: img.size.height))
            
            myLogo.image = img
            
            myView.addSubview(myLogo)
            myView.tag = 74396893368329
            
            self.window?.addSubview(myView)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // 1. Convert device token to string
    let tokenParts = deviceToken.map { data -> String in
    return String(format: "%02.2hhx", data)
    }
    let token = tokenParts.joined()
    // 2. Print device token to use for PNs payloads
    print("Device Token: \(token)")
    let bundleID = Bundle.main.bundleIdentifier;
        print("Bundle ID: \(token) \(String(describing: bundleID))");
    // 3. Save the token to local storeage and post to app server to generate Push Notification. ...
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: "deviceToken")

    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    print("Received push notification: \(userInfo)")
    let aps = userInfo["aps"] as! [String: Any]
    print("\(aps)")
            let defaults = UserDefaults.standard
            defaults.set(aps, forKey: "notification")
            NotificationCenter.default.post(name: .didReceiveData, object: nil)

    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        
        OpenUrlManager.notSupportedYet = { res, network in
            
        }
        
        OpenUrlManager.onURL = { res in
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(res) {
                let defaults = UserDefaults.standard
                defaults.set(encoded, forKey: "QRARRAY2")
            }
            NotificationCenter.default.post(name: .didReceiveData, object: nil)
            
        }
        OpenUrlManager.parseUrlParams(openUrl: url)
        
        
        

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
}


protocol DisplaysSensitiveData {
    func hideSensitiveData()
    func showSensitiveData() // we make a mess, we clean it up
}
