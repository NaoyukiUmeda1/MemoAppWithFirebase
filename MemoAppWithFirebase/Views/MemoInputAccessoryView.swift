//
//  MemoInputAccessoryView.swift
//  MemoAppWithFirebase
//
//  Created by Naoyuki Umeda on 2021/06/10.

import UIKit

protocol MemoInputAccessoryViewDelegate : class {
    func tappedMemoInputButton(text: String)
}

class MemoInputAccessoryView: UIView {
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var memoInputButton: UIButton!
    
    @IBAction func tappedMemoInputButton(_ sender: Any) {
        guard let text = memoTextView.text else { return }
        delegate?.tappedMemoInputButton(text: text)
//        self.setFromXib()
    }
    
    weak var delegate: MemoInputAccessoryViewDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nibInit()
        setupView()
        autoresizingMask = .flexibleHeight
    }
    
//    required init?(coder aDecoder: NSCoder) {
//            super.init(coder: aDecoder)
//            self.setFromXib()
//        }

//    private func setFromXib() {
//            let nib = UINib.init(nibName: "memoRoomViewController", bundle: nil)
//            let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
//            self.addSubview(view)// Storyboardから読み込んだレイアウトでビューを重ねて表示
//        }

    private func setupView() {
        memoTextView.layer.cornerRadius = 15
        memoTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        memoTextView.layer.borderWidth = 1.0
        
        memoInputButton.layer.cornerRadius = 15
        memoInputButton.imageView?.contentMode = .scaleAspectFit
        memoInputButton.contentHorizontalAlignment = .fill
        memoInputButton.contentVerticalAlignment = .fill
        memoInputButton.isEnabled = false
        
        memoTextView.text = ""
        memoTextView.frame = memoTextView.frame;
        memoTextView.delegate = self
       }

    func removeText(){
        memoTextView.text = ""
        memoInputButton.isEnabled = false
    }
    
    
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    
    private func nibInit() {
        let nib = UINib(nibName: "MemoInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
 //       self.setFromXib()
    }
    
}

extension MemoInputAccessoryView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            memoInputButton.isEnabled = false
        } else {
            memoInputButton.isEnabled = true
        }
    }
}
