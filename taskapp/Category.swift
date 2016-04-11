//
//  Category.swift
//  taskapp
//
//  Created by Kazuhiro Sudo on 16/4/8.
//  Copyright © 2016年 k.sudo. All rights reserved.
//

import RealmSwift

class Category: Object {

    // 管理用 ID。プライマリーキー
    dynamic var id: String = ""
    
    // タイトル
    dynamic var name = ""
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
