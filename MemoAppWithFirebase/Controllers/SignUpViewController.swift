
import UIKit
import Firebase
import PKHUD

struct  User {
    let name : String
    let createdAt : Timestamp
    let email : String
    var uid : String?
    
    init(dic: [String: Any]){
        self.name = dic["name"] as! String
        self.createdAt = dic["createdAt"] as! Timestamp
        self.email = dic["email"] as! String
}
}

class signUpViewController: UIViewController {

    
    @IBOutlet weak var resisterButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBAction func tappedResisterButton(_ sender: Any) {
        handleAuthToFirebase()
    }
    
    @IBAction func tappedAlreadyHaveAccountButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginviewcontroller = storyboard.instantiateViewController(identifier: "logInViewController") as logInViewController
        let navController = UINavigationController(rootViewController: loginviewcontroller)
        navigationController?.pushViewController(navController, animated: true)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    
    private func handleAuthToFirebase() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("認証情報の取得に失敗しました。\(err)")
                HUD.hide {(_) in
                    HUD.flash(.error, delay: 1)
                }
                return
            }
            self.addUserInfoToFirestore(email: email)
        }
    }
    
    
    private func addUserInfoToFirestore(email: String){
        print("認証情報の取得に成功しました")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let name = self.userNameTextField.text else { return }
        
        let docDate = ["email":email, "name": name, "createdAt" : Timestamp()] as [String: Any]
        let userRef = Firestore.firestore().collection("users").document(uid)
        
            userRef.setData(docDate) { (err) in
            if let err = err {
                print("Firestoreへの保存へ失敗しました \(err)")
                HUD.hide {(_) in
                    HUD.flash(.error, delay: 1)
                }
                return
            }
            print("Firestoreへの保存へ成功しました")
                
            userRef.getDocument{(snapshot, err) in
                if let err = err {
                    print("ユーザー情報の取得に失敗しました\(err)")
                    HUD.hide {(_) in
                        HUD.flash(.error, delay: 1)
                    }
                    return
                }
                guard let data = snapshot?.data() else { return }
                let user = User.init(dic: data)
                print("ユーザー情報の取得ができました\(user.name)")
                
                HUD.hide {(_) in
                    HUD.flash(.success, delay: 1)
                }
                
                let storyboard = UIStoryboard(name: "MemoList", bundle: nil)
                let memoListViewController = storyboard.instantiateViewController(identifier: "memoListViewController") as memoListViewController
                memoListViewController.user = user
                memoListViewController.modalPresentationStyle = .fullScreen
                self.present(memoListViewController, animated: true, completion: nil)
                }
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resisterButton.isEnabled = false
        resisterButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        resisterButton.layer.cornerRadius = 5
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        userNameTextField.delegate = self
        
        passwordTextField.isSecureTextEntry = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    //キーボードが出てきた時の処理が受け取れる
    @objc func showKeyboard(notification: Notification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        let resisterButonMaxY = resisterButton.frame.maxY
        
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

extension signUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {

        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        let userNameIsEmpty = userNameTextField.text?.isEmpty ?? true
        
        if emailIsEmpty || passwordIsEmpty || userNameIsEmpty {
            resisterButton.isEnabled = false
            resisterButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        } else {
            resisterButton.isEnabled = true
            resisterButton.backgroundColor = UIColor.rgb(red: 255, green: 141, blue: 0)
        }
    }
}

