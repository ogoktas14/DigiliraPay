//
//  SceneDelegate.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 8.08.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit
import Locksmith
@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var bg:UIView?
    var logo:UIImageView?
    private var isCertificatePinning: Bool = true
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        let isCydia = UIDevice.current.isJailBroken
        
        if isCydia {
            exit(-1)
        }
        
        for urlContext in connectionOptions.urlContexts {
            let url = urlContext.url
            
            OpenUrlManager.onURL = { res in
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(res) {
                    let defaults = UserDefaults.standard
                    defaults.set(encoded, forKey: "QRARRAY2")
                }
                NotificationCenter.default.post(name: .didReceiveData, object: nil)
                
            }
            OpenUrlManager.parseUrlParams(openUrl: url)
            
            // handle url and options as needed
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        if let isBlocked = UserDefaults.standard.value(forKey: "isBlocked") as? Bool {
            if isBlocked {
                NotificationCenter.default.post(name: Notification.Name(.foo), object: nil)
                return

            }
        }
        
        if let selfied = UserDefaults.standard.value(forKey: "isSelfied") as? Bool {
            if selfied {
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

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
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
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
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
        
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: "deviceToken")
        
        // 3. Save the token to local storeage and post to app server to generate Push Notification. ...
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Received push notification: \(userInfo)")
        let aps = userInfo["aps"] as! [String: Any]
        print("\(aps)")
    }
    
    func scene(_ scene: UIScene,openURLContexts URLContexts: Set<UIOpenURLContext>){
        
        if let url = URLContexts.first?.url{
            
            OpenUrlManager.onURL = { res in
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(res) {
                    let defaults = UserDefaults.standard
                    defaults.set(encoded, forKey: "QRARRAY2")
                }
                NotificationCenter.default.post(name: .didReceiveData, object: nil)
                
            }
            OpenUrlManager.parseUrlParams(openUrl: url)
        }
        
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
    
    
}

