//
//  MemoListViewController.swift
//  MemoAppWithFirebase
//
//  Created by Naoyuki Umeda on 2021/06/09.

import UIKit
import Firebase
import PKHUD


class memoListViewController : UIViewController {
    
    //Firrstoreにデータを保存するところで使用
    private let db = Firestore.firestore()
    var ref: DocumentReference? = nil
    var memorooms = [MemoRoom]()
    
    
    private let cellId = "cellId"
    public var selectedMemoList : String?
    
//var memoListTheme : [String] = ["はじめてのメモ"]
//Firebase との接続のために以下に変更
//メモの題名の配列
    var memoListTheme : [String] = []
    
    
    var user: User? {
        didSet {
            print("user", user?.name)
        }
    }
    
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var memoListNavigationBar: UINavigationBar!
    
    @IBOutlet weak var memoListTableView: UITableView!
    
    @IBAction func logOutButton(_ sender: Any) {
                // ①ログイン済みかどうかを確認
                if Auth.auth().currentUser != nil {
                    // ②ログアウトの処理
                    do {
                        try Auth.auth().signOut()
                        print("ログアウト完了")
                        // ③成功した場合はログイン画面へ遷移
                        let storyboard = UIStoryboard(name: "Login", bundle: nil)
                        let login = storyboard.instantiateViewController(identifier: "logInViewController") as logInViewController
                        login.modalPresentationStyle = .fullScreen
                        self.present(login, animated: true, completion: nil)
                    } catch let error as NSError {
                        print("ログアウト失敗: " + error.localizedDescription)
                        // ②が失敗した場合
                        let dialog = UIAlertController(title: "ログアウト失敗", message: error.localizedDescription, preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(dialog, animated: true, completion: nil)
                    }
                }
            }
    
    @IBAction func addNewMemoListButton(_ sender: Any) {
        var alertTextField: UITextField?
        
        let alert = UIAlertController(
            title: "新しいメモリストを作成",
            message: "",
            preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField(
            configurationHandler: {(textField: UITextField!) in
                alertTextField = textField })
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertAction.Style.cancel,
                handler: nil))
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.default) { _ in
                if let text = alertTextField?.text {
                    
                    //Firebaseにデータを保存
                    if let user = Auth.auth().currentUser {
                        let createdTime = FieldValue.serverTimestamp()
                        
                        self.db.collection("memoTitle").document().setData(
                        ["memoTitle": text,
                        "createdAt": createdTime,
                        "updtedAt": createdTime,
                        "uid": Auth.auth().currentUser?.uid,
                        "documentId": Firestore.firestore().collection("memoTitle").document().documentID
                        ],merge: true,completion: { err in
                            if let err = err {
                            print("Error")
                        } else {
                            print("配列にメモ題名追加成功")
                            
                            //ここからFirebaseからデータを取得して一覧表示する
                            // FirestoreからTodoを取得する処理
                            
                            Firestore.firestore().collection("memoTitle").order(by: "createdAt", descending: true).getDocuments(completion: { (querySnapshot, error) in
                                if let querySnapshot = querySnapshot {
                                    var titleArray:[String] = []
                                    
                                    for doc in querySnapshot.documents {
                                        let data = doc.data()
                                        titleArray.append(data["memoTitle"] as! String)
                                    }
                                    self.memoListTheme = titleArray
                                    print(self.memoListTheme)
                                    self.memoListTableView.reloadData()
                                }
                            })
                            self.memoListTableView.reloadData()
                            print(self.memoListTheme)
                        return
                        }
                        }
                    )}
                }
            }
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getTitleDataFromFirestore() {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("memoTitle").order(by: "createdAt", descending: true).getDocuments(completion: { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    var titleArray:[String] = []

                    for doc in querySnapshot.documents {
                        let data = doc.data()
                        titleArray.append(data["memoTitle"] as! String)
                    }
                    self.memoListTheme = titleArray
                    print("取得成功")
                } else if let error = error {
                    print("取得失敗")
                }
            })
        }
    }
    
    //6/22に追加　使用する？
//    private func fetchMemoRoomsInfoFromFirestore() {
//        Firestore.firestore().collection("memoRooms").getDocuments { (snapshots, err) in
//            if let err = err {
//                print("memoRoomsの情報取得に失敗しました")
//                return
//            }
//            snapshots?.documents.forEach( { (snapshots) in
//                let dic = snapshots.data()
//                let memoRoom = MemoRoom(dic: dic)
//
//                self.memorooms.append(memoRoom)
//                self.memoListTableView.reloadData()
//                print("memoRoomsの情報取得に成功しました")
//            })
//            }
//        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoListTableView.delegate = self
        memoListTableView.dataSource = self
        self.memoListNavigationBar.titleTextAttributes = [.foregroundColor:UIColor.black]
        //self.parent?.navigationItem.title = "メモ一覧"
        
        //Firebaseに保存してあるメモタイトルを取得
        Firestore.firestore().collection("memoTitle").order(by: "createdAt", descending: true).getDocuments(completion: { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                var titleArray:[String] = []
                var documentIdArray:[String] = []
                
                for doc in querySnapshot.documents {
                    let data = doc.data()
                    print(doc.documentID)
                    titleArray.append(data["memoTitle"] as! String)
                    documentIdArray.append(doc.documentID as! String)
                }
                self.memoListTheme = titleArray
                print(self.memoListTheme)
                self.memoListTableView.reloadData()
            }
        })
//        self.memoListTableView.reloadData()
        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewwillappear")
        //fetchMemoRoomsInfoFromFirestore()
    }
    }

extension memoListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoListTheme.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! memoListTableViewCell
        
        cell.memoTitle.text = memoListTheme[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped table view")
        
        let memoList = memoListTheme[indexPath.row]
        self.selectedMemoList = memoList
        
        guard let unwrappedSelectedMemoList = selectedMemoList else { return }
        print(unwrappedSelectedMemoList)
        
        let storyboard = UIStoryboard.init(name: "MemoRoom", bundle: nil)
        let next = storyboard.instantiateViewController(withIdentifier: "memoRoomViewController") as! memoRoomViewController
        navigationController?.pushViewController(next, animated: true)
        next.modalPresentationStyle = .fullScreen
        
        //memoRoomViewControllerに情報を渡す
        next.selectedMemoTitle = unwrappedSelectedMemoList
        self.present(next, animated: true, completion: nil)
        
    }
    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    //スワイプしたセルを削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            memoListTheme.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}

class memoListTableViewCell : UITableViewCell {
    
    @IBOutlet weak var memoColor: UIImageView!
    
    @IBOutlet weak var memoTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        memoColor.layer.cornerRadius = 24
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
