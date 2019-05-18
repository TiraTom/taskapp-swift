//
//  ViewController.swift
//  taskapp
//
//  Created by masao on 2019/05/10.
//  Copyright © 2019 TiraTom. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var realm: Realm!
    var taskArray: Results<Task>!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        realm = try! Realm()
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending:  false)
        
        // デリゲート先を自分に設定
        searchBar.delegate = self
        
        //何も入力されていなくてもReturnキーを押せるようにする。
        searchBar.enablesReturnKeyAutomatically = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド　データ数（セル数を返す）
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return taskArray.count
    }
    
    // 各セルの内容を返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = "[\(task.category)]\(task.title)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    
    // MARK: UITableViewDelegeteプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }

    // セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        // 削除するタスクを取得
        let task = self.taskArray[indexPath.row]
        
        // ローカル通知のキャンセル
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
        
        // DBから削除
        try! realm.write {
            self.realm.delete(self.taskArray[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/----")
                print(request)
                print("-------/")
            }
        }
    }
    
    
    //テキスト変更時の呼び出しメソッド
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchBar.text == "") {
            //検索文字列が空の場合はすべてを表示する。
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending:  false)
        } else {
            taskArray = try! Realm().objects(Task.self).filter("category CONTAINS '\(searchText)'").sorted(byKeyPath: "date", ascending: false)
        }
        //テーブルを再読み込みする。
        tableView.reloadData()
    }
    
    
    
    override func prepare( for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = Date()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
            
        }
    }

}

