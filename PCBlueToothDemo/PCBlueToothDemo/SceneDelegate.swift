//
//  SceneDelegate.swift
//  PCBlueToothDemo
//
//  Created by 彭祖鑫 on 2023/7/7.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        let url = URLContexts.first!.url
        let fileName = url.lastPathComponent  // Gets the full filename (with suffix) from the path
        var path = url.absoluteString // The full url string
        path = URLDecodedString(path) // Solves the url encoding problem
        let mutableString = NSMutableString(string: path)
        
        print(mutableString)
        
        //
        if path.hasPrefix("file://") { // Determines if it is a file by prefix
            
            // At this point, the file is stored locally, and can be used on your own pages
            let dict = ["fileName":fileName,
                        "filePath":mutableString] as [String : Any]
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FileNotification"), object: nil, userInfo: dict)
            
        }
        
    }
    
    // When the file name is in Chinese, solve the url encoding problem
    func URLDecodedString(_ str: String) -> String {
        guard let decodedString = str.removingPercentEncoding else {
            return str
        }
        print("decodedString = \(decodedString)")
        return decodedString
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
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


}

