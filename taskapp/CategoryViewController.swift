//
//  CategoryViewController.swift
//  taskapp
//
//  Created by Kazuhiro Sudo on 16/4/9.
//  Copyright © 2016年 k.sudo. All rights reserved.
//

import UIKit
import RealmSwift
import QuartzCore

class CategoryViewController:UIViewController {

    @IBOutlet var categoryText: UITextField!

    @IBOutlet var infoLabel: UILabel!
    
    @IBAction func addCategory(sender: AnyObject) {
        let realm = try! Realm()
        let category:Category! = Category()
        try! realm.write {
            if (categoryText.text == ""){
                infoLabel.text = "カテゴリが入力されていません。"
            }else{
                //カテゴリの存在チェック
                let tmp = realm.objects(Category).filter("name = %@", categoryText.text!)
                if(tmp.isEmpty){
                    category.id = NSUUID().UUIDString
                    category.name = categoryText.text!
                    realm.add(category, update: true)
                    infoLabel.text = "カテゴリ \(categoryText.text!) が追加されました。"
                    print("Category added")
                    categoryText.text = "" //入力エリアの初期化
                }else{
                    infoLabel.text = "カテゴリ \(categoryText.text!) は登録済みです。"
                }
            }
            
        }
    }

    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:"dismissKeyboard")
        self.view.addGestureRecognizer(tapGesture)

    }
    
}
