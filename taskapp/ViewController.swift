//
//  ViewController.swift
//  taskapp
//
//  Created by Kazuhiro Sudo on 16/4/6.
//  Copyright © 2016年 k.sudo. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var mySearch: UISearchBar!
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
    }

    var categorySections : [String] = [ ]
    var categorySectionsId : [String] = [ ]
    
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    let taskArray = try! Realm().objects(Task).sorted("date", ascending: false).sorted("categoryid")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Section（カテゴリ）毎に数を判別する
        var t = 0
        for (var i = 0; i < categorySectionsId.count; i++){
            if section == i {
                //print(categorySections[i] + " " + categorySectionsId[i])
                t = realm.objects(Task).filter("categoryid = %@", categorySectionsId[i]).count
            }
        }
        return t
        //return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        print("Section: " + (String)(indexPath.section) + " indexPath.row: " + (String)(indexPath.row))
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // 特定sectionのカテゴリに絞り込み検索することで、indexPath順に読み込めるようにする
        let t = realm.objects(Task).filter("categoryid = %@", categorySectionsId[indexPath.section])
        let task = t[indexPath.row]
        
        // Cellに値を設定する.
        cell.textLabel?.text = task.title
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("cellSegue",sender: nil)
    }
    
    // segue で画面遷移するに呼ばれる
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            
            // 特定sectionのカテゴリに絞り込み検索することで、indexPath順に読み込めるようにする
            let t = realm.objects(Task).filter("categoryid = %@", categorySectionsId[indexPath!.section])

            inputViewController.task = t[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            task.categoryid = "00000000-0000-0000-0000-000000000001"
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            inputViewController.task = task
        }
    }

    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(animated: Bool) {
        categorySections.removeAll()
        categorySectionsId.removeAll()
        let c = realm.objects(Category)
        for tmp in c{
            categorySections.append(tmp.name)
            categorySectionsId.append(tmp.id)
            //print((String)(categorySections.count) + " " +  tmp.id + " " + tmp.name )

        }
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // Section数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return categorySections.count
    }
    
    // Sectioのタイトル
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categorySections[section]
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // ローカル通知をキャンセルする
            
            // 特定sectionのカテゴリに絞り込み検索することで、indexPath順に読み込めるようにする
            let t = realm.objects(Task).filter("categoryid = %@", categorySectionsId[indexPath.section])
            //let task = taskArray[indexPath.row]
            let task = t[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            // データベースから削除する
            try! realm.write {
                //self.realm.delete(self.taskArray[indexPath.row])
                self.realm.delete(t[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    

}

