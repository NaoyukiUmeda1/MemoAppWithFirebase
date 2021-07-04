//
//  SceneDelegate.swift
//  MemoAppWithFirebase
//
//  Created by Naoyuki Umeda on 2021/06/09.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
 
        let window = UIWindow(windowScene: scene as! UIWindowScene)
        self.window = window
        window.makeKeyAndVisible()

        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let firstSecene = storyboard.instantiateViewController(identifier: "signUpViewController")
        firstSecene.modalPresentationStyle = .fullScreen
        window.rootViewController = firstSecene
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}

