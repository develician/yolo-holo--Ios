//
//  RegisterController.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 23..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON

class RegisterController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var profileViewModel: ProfileViewModel?
    
    let formView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "사용자 이메일"
        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "사용자 닉네임"
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "패스워드"
        tf.isSecureTextEntry = true
        return tf
    }()

    let registerButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("회원가입", for: UIControlState.normal)
        btn.layer.backgroundColor = UIColor.mainTextBlue.cgColor
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupNavBar()
        bind()
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        
        let components = [formView, emailTextField, usernameTextField, passwordTextField, registerButton]
        components.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        formView.anchor(top: topLayoutGuide.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 24, left: 16, bottom: 0, right: 16), size: CGSize(width: 0, height: view.frame.size.width * 0.45))
        
        emailTextField.anchor(top: formView.topAnchor, leading: formView.leadingAnchor, bottom: nil, trailing: formView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        usernameTextField.anchor(top: emailTextField.bottomAnchor, leading: formView.leadingAnchor, bottom: nil, trailing: formView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        passwordTextField.anchor(top: usernameTextField.bottomAnchor, leading: formView.leadingAnchor, bottom: nil, trailing: formView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        registerButton.anchor(top: passwordTextField.bottomAnchor, leading: formView.leadingAnchor, bottom: nil, trailing: formView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
    }
    
    fileprivate func setupNavBar() {
        navigationItem.title = NSLocalizedString("회원가입", comment: "")
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        navigationController?.navigationBar.backgroundColor = .yellow
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.rgb(r: 50, g: 199, b: 242)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        } else {
           navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    fileprivate func fetchRegister() {
        guard let email = emailTextField.text else {return}
        guard let username = usernameTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        let requestObservable = AuthService.shared.fetchRegister(email: email, username: username, password: password)
        
        requestObservable.subscribe(onNext: { [weak self] respJSON in
            
            guard let profile: Profile = Profile(json: respJSON) else {
                return
            }
            
            self?.profileViewModel = ProfileViewModel(profile: profile)
            
            UserDefaults.standard.set(true, forKey: "logged")
            UserDefaults.standard.set(self?.profileViewModel?.username, forKey: "username")
            UserDefaults.standard.set(self?.profileViewModel?.thumbnail, forKey: "thumbnail")

            
        }, onError: { error in
            let errored = error as NSError
            guard let message = errored.userInfo["message"] as? String else {return}
            
            let alert = UIAlertController(title: "오류", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }, onCompleted: {
            self.view.endEditing(true)
            guard let window = AppDelegateUtil.shared.window else {return}
            let sceneSwitcher = SceneSwitcher(window: window)
            sceneSwitcher.mainView = MainView(sceneSwitcher: sceneSwitcher)
            sceneSwitcher.presentMain()

            
        }) { 
//            NotificationCenter.default.post(name: NSNotification.Name.RegisterSuccess, object: nil, userInfo: ["isSuccess" : true])
        }.disposed(by: disposeBag)
    }
}

extension RegisterController {
    func bind() {
        registerButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.fetchRegister()
        }).disposed(by: disposeBag)
    }
    
    func showMainViews() {
        self.present(MainTabBarController(), animated: true, completion: nil)
    }
    

}

