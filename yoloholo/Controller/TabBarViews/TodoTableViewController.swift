//
//  TodoTableViewController.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 30..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON

class TodoTableViewController: UITableViewController {

    var disposeBag = DisposeBag()
    
    let cellId = "cellId"
    
    var todoViewModelList: [TodoViewModel]?
    var planId: String?

    let memoButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: nil)
        return btn
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchListTodo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.title = "Todo List"
        self.navigationItem.rightBarButtonItem = memoButton
        setupTableview()
        bind()
    }

    fileprivate func setupTableview() {
        tableView.register(TodoTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        tableView.separatorColor = .mainTextBlue
        tableView.backgroundColor = UIColor.rgb(r: 12, g: 47, b: 57)
        //        tableView.rowHeight = UITableViewAutomaticDimension
        //        tableView.estimatedRowHeight = 500
        tableView.tableFooterView = UIView()
        
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let todoViewModelList = self.todoViewModelList {
            return todoViewModelList.count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TodoTableViewCell
        
        if let todoList = self.todoViewModelList {
            let targetStrings = "\(todoList[indexPath.row].todo)"
            if (targetStrings.count ?? 0) > 50 {
                let toIndex = targetStrings.index(targetStrings.startIndex, offsetBy: 50)
                let subStr = targetStrings[..<toIndex]
                cell.textLabel?.text = "\(subStr)..."
            }
            cell.textLabel?.text = targetStrings
           
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let todoViewModelList = self.todoViewModelList else {
            return
        }
        
        guard let planId = self.planId else {
            print("todotableview planid parsing error")
            return
            
        }
        
        let todo = todoViewModelList[indexPath.row]
        
        let dest = TodoEditorController()
        dest.isEditable = false
        dest.todo = "\(todo.todo)"
        dest.planId = planId
        dest.todoIndex = indexPath.row
        self.navigationController?.pushViewController(dest, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
 


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todoIndex = indexPath.row
            guard let planId = self.planId else {return}
           
            TodoService.shared.fetchRemoveTodo(id: planId, index: todoIndex).subscribe(onNext: { [weak self] (respJSON) in
                let jsonTodoList = respJSON.enumerated()
                self?.todoViewModelList = jsonTodoList.map({ (index, element) in
                    let todo: Todo = Todo(json: element.1)
                    let todoViewModel: TodoViewModel = TodoViewModel(todo: todo)
                    return todoViewModel
                })
                
            }, onError: { (error) in
                print(error.localizedDescription)
            }, onCompleted: {
                tableView.setEditing(false, animated: true)
                tableView.reloadData()
            }) {
                
                }.disposed(by: self.disposeBag)
            
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TodoTableViewController {
    func bind() {
        memoButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.showMemoMenu()

        }).disposed(by: disposeBag)
    }
    
    func showMemoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Todo 작성", style: UIAlertActionStyle.default, handler: { [weak self] (alertAction) in
            
            let dest = TodoEditorController()
            dest.isEditable = true
            guard let planId = self?.planId else {
                print("todotableview planid parsing error")
                return

            }
            dest.planId = planId
            self?.navigationController?.pushViewController(dest, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "삭제모드", style: UIAlertActionStyle.destructive, handler: { [weak self] (alertAction) in
            guard let `self` = self else {return}
            self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "닫기", style: UIAlertActionStyle.default, handler: { (alertAction) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchListTodo() {
        guard let planId = self.planId else {
            fatalError("Todo Table View planId parsing error")
        }
        
        TodoService.shared.fetchListTodo(id: planId).subscribe(onNext: { [weak self] (respJSON) in

            let todoList = respJSON.enumerated()
//            todoList.map({ (index, element) in
//                let todo = Todo(json: element.1)
//            })
            self?.todoViewModelList = todoList.map({ (index, element) in
                let todo = Todo(json: element.1)
                return TodoViewModel(todo: todo)
            })
            

            
            self?.tableView.reloadData()
            
        }, onError: { (error) in
            print(error.localizedDescription)
        }, onCompleted: {
            
        }) {
            
        }.disposed(by: self.disposeBag)
    }
    
    func fetchRemoveTodo(id: String?, index: Int?) {
        
    }
}
