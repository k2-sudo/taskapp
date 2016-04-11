//
//  InputViewController.swift
//  taskapp
//
//  Created by Kazuhiro Sudo on 16/4/6.
//  Copyright © 2016年 k.sudo. All rights reserved.

import UIKit
import RealmSwift
import QuartzCore

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentsTextView: UITextView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var categoryTextField: UITextField!
    
    let realm = try! Realm()
    var task:Task!
    
    var categoryValue : [String] = [ ]
    var myToolBar: UIToolbar!
    var myPickerView: UIPickerView!
    
    var wkCategoryid = ""
    
    //カテゴリプルダウン表示列
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //カテゴリプルダウン表示数
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryValue.count
    }
    
    //カテゴリプルダウン表示内容
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryValue[row]
    }
    
    //カテゴリプルダウン選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(categoryValue[row])
        categoryTextField.text = categoryValue[row]

        //Categoryのnameからidを逆算してtaskに設定
        let c3 = realm.objects(Category).filter("name = %@", categoryValue[row])
        wkCategoryid = c3[0].id
    }
    
    //カテゴリプルダウン閉じる
    func onClick(sender: UIBarButtonItem) {
        categoryTextField.resignFirstResponder()
    }
    
    
    //タスクを追加して1画面戻る
    @IBAction func addTask(sender: AnyObject) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.categoryid = wkCategoryid
            self.realm.add(self.task, update: true)
        }
        setNotification(task)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //categoryValue = ["未分類","AAA","BBB","CCC"]
        
        //PickerView作成（カテゴリプルダウン）
        myPickerView = UIPickerView()
        myPickerView.showsSelectionIndicator = true
        myPickerView.delegate = self
        
        //ToolBar作成。プルダウンポップアップ用
        myToolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        myToolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        myToolBar.backgroundColor = UIColor.blackColor()
        myToolBar.barStyle = UIBarStyle.Black
        myToolBar.tintColor = UIColor.whiteColor()
        
        //ToolBarを閉じるボタンの追加
        let myToolBarButton = UIBarButtonItem(title: "Close", style:UIBarButtonItemStyle.Plain, target: self, action: "onClick:")
        myToolBarButton.tag = 1
        myToolBar.items = [myToolBarButton]
        
        //TextFieldをpickerViewとToolVerに関連づけ
        categoryTextField.inputView = myPickerView
        categoryTextField.inputAccessoryView = myToolBar
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:"dismissKeyboard")
        self.view.addGestureRecognizer(tapGesture)
        
        //TextViewの枠線設定
        addBoader(contentsTextView)

        
        //カテゴリテーブルのイニシャルレコードを設定
        //TODO：毎回読み込むのは非効率。初期データとしてバンドルするように変更すべき。
        let realm = try! Realm()
        let category:Category! = Category()
        try! realm.write {
            category.id = "00000000-0000-0000-0000-000000000001"
            category.name = "未分類"
            realm.add(category, update: true)
        }
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        let c1 = realm.objects(Category).filter("id = %@", task.categoryid)
        categoryTextField.text = c1[0].name
        wkCategoryid = task.categoryid
    }
    
    //画面表示時はカテゴリをいつも更新（カテゴリ新規作成から戻った時に反映するため）
    override func viewWillAppear(animated: Bool) {
        categoryValue.removeAll()
        let c2 = realm.objects(Category)
        for tmp in c2{
            categoryValue.append(tmp.name)
        }
        super.viewWillAppear(animated)
    }
    
    //TextViewに枠線を設定
    func addBoader(textview: UITextView){
        textview.layer.masksToBounds = true
        textview.layer.cornerRadius = 7.5
        textview.layer.borderColor = UIColor.lightGrayColor().CGColor
        textview.layer.borderWidth = 1
    }
    
    
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    /*
    override func viewWillDisappear(animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: true)
        }
        setNotification(task)
        
        super.viewWillDisappear(animated)
    }
    */
    
    // タスクのローカル通知を設定する
    func setNotification(task: Task) {
        
        // すでに同じタスクが登録されていたらキャンセルする
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
            if notification.userInfo!["id"] as! Int == task.id {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
                break
            }
        }
        
        let notification = UILocalNotification()
        
        notification.fireDate = task.date
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = "\(task.title)"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["id":task.id]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
