//
//  MemoRoom.swift
//  MemoAppWithFirebase
//
//  Created by Naoyuki Umeda on 2021/06/22.
//


////6/22に追加（使用する？）
import Foundation
import Firebase

class MemoRoom {

    var latestMemoId: String
    var memoTitle: [String]
    var CreatedAt: Timestamp
    var documentId: String

    init(dic: [String: Any]) {
        self.latestMemoId = dic["latestMemoId"] as? String ?? ""
        self.memoTitle = dic["memoTitle"] as? [String] ?? [String]()
        self.CreatedAt = dic["CreatedAt"] as? Timestamp ?? Timestamp()
        self.documentId = dic[""] as? String ?? ""
    }

}
