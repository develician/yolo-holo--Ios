//
//  TodoEditorController.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 30..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import RxKeyboard

class TodoEditorController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var isEditable = false
    var isPatching = false
    var todo: String?
    
    var planId: String?
    
    var todoIndex: Int?
    
    let doneButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: nil)
        return btn
    }()
    
    let updateButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: nil)
        return btn
    }()
    
    lazy var editor: UITextView = {
        let editor = UITextView()
        editor.backgroundColor = .lightGray
        if self.isEditable {
            editor.isEditable = true
        } else {
            editor.isEditable = false
        }
        if let todo = self.todo {
            editor.text = todo
        }
        editor.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        
        return editor
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.registerAutomaticKeyboardConstraints()
        if self.isEditable {
            self.navigationItem.rightBarButtonItem = doneButton
        } else {
            self.navigationItem.rightBarButtonItem = updateButton
        }
        
        self.view.addSubview(editor)
        editor.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom).offset(24)
            }
            make.left.equalTo(view.snp.left).offset(16)
            make.right.equalTo(view.snp.right).offset(-16)
            guard let tabBarHeight = self.tabBarController?.tabBar.frame.size.height else {return}
            make.bottom.equalTo(view.snp.bottom).offset(-(tabBarHeight + 16))
        }
        
        editor.snp.prepareConstraints {(make) in
            
            RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] (keyboardVisibleHeight) in
                guard let `self` = self else {return}
                make.bottom.equalTo(self.view.snp.bottom).offset(-(keyboardVisibleHeight + 16)).keyboard(true, in: self.view)
            }).disposed(by: disposeBag)
            
        }
        
        bind()
        
        print(self.planId)
        
    }
    
    
    
}

extension TodoEditorController {
    func bind() {
        updateButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.editor.isEditable = true
            self?.isPatching = true
            self?.editor.becomeFirstResponder()
            self?.navigationItem.rightBarButtonItem = self?.doneButton
        }).disposed(by: disposeBag)
        
        doneButton.rx.tap.asObservable().flatMap {
            [weak self] _ -> Observable<Bool> in
            guard let isPatching = self?.isPatching else { return Observable.empty() }
            return Observable.just(isPatching)
            }.subscribe(onNext: { [weak self] (isPatching) in
                if isPatching {
                    self?.fetchEditTodo()
                } else {
                   self?.fetchAddTodo()
                }
            }).disposed(by: disposeBag)
    }
    
    func fetchAddTodo() {
        guard let planId = self.planId else {
            print("planId parsing error")
            return
            
        }
        guard let todo = self.editor.text, todo.count > 0 else {
            print("todo parsing error")
            return
            
        }
        TodoService.shared.fetchAddTodo(id: planId, todo: todo).subscribe(onNext: { (respJSON) in
            print(respJSON)
            self.navigationController?.popViewController(animated: true)
        }, onError: { (error) in
            print(error.localizedDescription)
        }, onCompleted: {
            
        }) {
            
        }.disposed(by: disposeBag)
    }
    
    func fetchEditTodo() {
        guard let planId = self.planId else {
            fatalError("planId parsing error")
        }
        guard let todo = self.editor.text, todo.count > 0 else {
            fatalError("todo parsing error")
        }
        
        guard let index = self.todoIndex, index >= 0 else {
            fatalError("todo index parsing error")
        }
        
        TodoService.shared.fetchEditTodo(id: planId, index: index, todo: todo).subscribe(onNext: { (respJSON) in
            
        }, onError: { (error) in
            print(error.localizedDescription)
        }, onCompleted: {
            self.navigationController?.popViewController(animated: true)
        }) {
            
        }.disposed(by: disposeBag)
    }
}
