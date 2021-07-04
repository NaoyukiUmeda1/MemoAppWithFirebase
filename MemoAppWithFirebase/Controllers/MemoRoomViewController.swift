//
//  MemoRoomViewController.swift
//  MemoAppWithFirebase
//
//  Created by Naoyuki Umeda on 2021/06/10.

import UIKit
import Firebase

class memoRoomViewController: UIViewController {
    
    public var selectedMemoTitle : String?
    private let db = Firestore.firestore()
    
    var memoroom: MemoRoom?
    var memos = [String]()
    //memotitleのdocumentId
    var documentIdforFirebase: String = ""
    
    private let cellIdd = "cellIdd"
    
    private lazy var memoInputAccessoryView: MemoInputAccessoryView = {
        let view = MemoInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    @IBOutlet weak var returnToMemoListButton: UIBarButtonItem!
    
    @IBOutlet weak var memoRoomTableView: UITableView!
    
    @IBAction func returnToMemoViewButtton(_ sender: Any) {
        //モーダル遷移のためdismiss
        self.dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        memoRoomTableView.delegate = self
        memoRoomTableView.dataSource = self
        memoRoomTableView.estimatedRowHeight = 5
        memoRoomTableView.rowHeight = UITableView.automaticDimension
        memoRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        memoRoomTableView.keyboardDismissMode = .interactive
        
        getDocumentId()
        print("ドキュメントIDは\(documentIdforFirebase)")
        
        //Firebaseに保存してあるメモタイトルを取得
        db.collection("memoDetail").whereField("documentId", isEqualTo: documentIdforFirebase).order(by: "createdAt", descending: true).getDocuments(completion: { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                var memoDetailArray:[String] = []
                
                for doc in querySnapshot.documents {
                    let data = doc.data()
                    memoDetailArray.append(data["memoDetail"] as! String)
                }
                self.memos = memoDetailArray
                self.memoRoomTableView.reloadData()
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(documentIdforFirebase)
    }
    
    private func getDocumentId() {
        Firestore.firestore().collection("memoTitle").whereField("documentId", isEqualTo: true)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("documentId取得失敗: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("documentId取得成功\(document.documentID)")
                }
            }
        }
        
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return memoInputAccessoryView
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
}

extension memoRoomViewController: MemoInputAccessoryViewDelegate {
    func tappedMemoInputButton(text: String) {
//Firebaseにデータを保存
        let createdTime = FieldValue.serverTimestamp()
        guard let unwrappedSelectedMemoTitle = self.selectedMemoTitle else { return }
        
                db.collection("memoDetail").document().setData(
                ["memoDetail": text,
                 "memoTitle": unwrappedSelectedMemoTitle,
                "createdAt": createdTime,
                "updatedAt": createdTime,
                "uid": Auth.auth().currentUser?.uid,
                "documentId": documentIdforFirebase]
                    ,merge: true,completion: { err in
                    if let err = err {
                    print("Error")
                } else {
                    
                    //ここを編集する必要あり
                    //ここからFirebaseからデータを取得して一覧表示する
                    //documentIDがmemoTitleのものだけをもってくるようにする
                    Firestore.firestore().collection("memoDetail").order(by: "createdAt", descending: true).getDocuments(completion: { (querySnapshot, error) in
                        if let querySnapshot = querySnapshot {
                            var memoDetailArray:[String] = []
                            
                            for doc in querySnapshot.documents {
                                let data = doc.data()
                                memoDetailArray.append(data["memoDetail"] as! String)
                            }
                            self.memos = memoDetailArray
                            print(self.memos)
                            self.memoRoomTableView.reloadData()
                            print("配列にメモ題名追加成功")
                        }
                    })
                    self.memoRoomTableView.reloadData()
                    print(self.memos)
                return
                }
                }
                )}
    
}

extension memoRoomViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        memoRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celll = tableView.dequeueReusableCell(withIdentifier: cellIdd, for: indexPath) as! memoRoomTableViewCell
        celll.textShow = memos[indexPath.row]
        
        return celll
    }
}

class memoRoomTableViewCell: UITableViewCell {
    
    var textShow : String? {
        didSet{
            guard let text = textShow else { return }
            let witdh = estimaedFrameForTextView(text: text).width
            
            memoTextShowWidthConstraint.constant = witdh
            memoTextShow.text = text
        }
    }
    
    @IBOutlet weak var memoText: UILabel!
    
    @IBOutlet weak var memoTextShow: UITextField!
    
    
    @IBOutlet weak var memoTextShowWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        memoText.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        memoTextShow.layer.cornerRadius = 15
        memoTextShow.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        //memoTextShow.layer.borderWidth = 1
    }
    
    override func setSelected(_ setSelected: Bool, animated: Bool){
        super.setSelected(setSelected, animated: animated)
    }
    
    
    private func estimaedFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    }
}
