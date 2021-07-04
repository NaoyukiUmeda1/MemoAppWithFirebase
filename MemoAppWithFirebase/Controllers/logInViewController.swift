//
//  LogInViewController.swift
//  MemoAppWithFirebase
//  Created by Naoyuki Umeda on 2021/06/13.

import UIKit
import Firebase

class logInViewController: UIViewController {
    
    
    @IBOutlet weak var emailtextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    
    @IBAction func tappedLogInButton(_ sender: Any) {
        print("loginButton")
        
        guard let email = emailtextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("認証情報の取得に失敗しました。\(err)")
                return
                
            }
            print("ログインに成功しました")
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let userRef = Firestore.firestore().collection("users").document(uid)
            
            userRef.getDocument{(snapshot, err) in
                if let err = err {
                    print("ユーザー情報の取得に失敗しました\(err)")
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                let user = User.init(dic: data)
                print("ユーザー情報の取得ができました")
                self.presentToMainViewController()
                }
            }
    }
    
    private func presentToMainViewController() {
        let storyboard = UIStoryboard(name: "MemoList", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(identifier: "memoListViewController") as memoListViewController
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
    }

    @IBAction func tappedDontHaveAccountButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInButton.isEnabled = false
        logInButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        logInButton.layer.cornerRadius = 5
        
        emailtextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    //キーボードが出てきた時の処理が受け取れる
    //キーボード以外のところを触るとキーボードが下になくなってくれる
    @objc func showKeyboard(notification: Notification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        let resisterButonMaxY = logInButton.frame.maxY
        
        let distance = resisterButonMaxY - keyboardMinY + 20
        
        let transform = CGAffineTransform(translationX: 0, y: -distance)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = transform
        })
    }

    @objc func hideKeyboard(){
        print("hideKeyboard is hide")
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = .identity
        })
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension logInViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {

        let emailIsEmpty = emailtextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        
        if emailIsEmpty || passwordIsEmpty {
            logInButton.isEnabled = false
            logInButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        } else {
            logInButton.isEnabled = true
            logInButton.backgroundColor = UIColor.rgb(red: 255, green: 141, blue: 0)
        }
    
}
}
