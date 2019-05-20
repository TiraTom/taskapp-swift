//
//  InputViewController.swift
//  taskapp
//
//  Created by masao on 2019/05/11.
//  Copyright © 2019 TiraTom. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var registerButton: UIButton!
    
    var task: Task!
    var realm: Realm!
    

    @IBAction func registerButton(_ sender: Any) {
        registerTask()
        setNotification(task: task)
        
        // メイン画面に戻る
        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "viewController") as! ViewController
        let navController = UINavigationController(rootViewController: VC1)
        self.present(navController, animated:true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        
        self.view.addGestureRecognizer(tapGesture)
        
        categoryTextField.text = task.category
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        // Do any additional setup after loading the view.
        
        realm = try! Realm()

        // タイトルが空の場合はボタンを押せないようにする
        if self.titleTextField.text == "" {
            self.registerButton.isEnabled = false
        } else {
            self.registerButton.isEnabled = true
        }
        
        // タイトルの入力を監視する
        titleTextField.delegate = self
        
        // コンテンツ入力欄の枠の色
        contentsTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        // コンテンツ入力欄の枠の幅
        contentsTextView.layer.borderWidth = 0.3
        
        // コンテンツ入力欄の枠を角丸にする
        contentsTextView.layer.cornerRadius = 10.0
        contentsTextView.layer.masksToBounds = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // キーボードを閉じる
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func registerTask() {
        try! realm.write {
            
            if self.categoryTextField.text == "" {
                self.task.category = "(カテゴリなし)"
            }else {
                self.task.category = self.categoryTextField.text!
            }
            
            if self.titleTextField.text == "" {
                self.task.title = "(タイトルなし)"
            }else {
                self.task.title = self.titleTextField.text!
            }
            
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: true)
        }
    }
    
    
    // タイトル（必須項目）が入力されたら登録ボタンを押せるようにする
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            self.registerButton.isEnabled = false
        } else {
            self.registerButton.isEnabled = true
        }
        
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        
        if task.title == "" {
            content.title = "(タイトルなし)"
        }else {
            content.title = "[\(task.category)]\(task.title)]"
        }
        
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するトリガー（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        // ローカル通知を作成
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) {
            (error) in print(error ?? "ローカル通知登録 OK")
        }
        
        center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in
            for request in requests {
                print("----")
                print(request)
                print("----")
            }
        }
    }

}
