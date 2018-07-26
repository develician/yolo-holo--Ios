//
//  LoginController.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 23..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FBSDKCoreKit
import FBSDKLoginKit


class LoginController: UIViewController {
    
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var profileViewModel: ProfileViewModel?
    
    let loginView: UIView = {
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
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "비밀번호"
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let loginButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("로그인", for: UIControlState.normal)
        btn.layer.backgroundColor = UIColor.mainTextBlue.cgColor
        btn.layer.cornerRadius = 10
        return btn
    }()

    let registerButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("회원가입", for: UIControlState.normal)
        btn.layer.backgroundColor = UIColor.rgb(r: 50, g: 199, b: 242).cgColor
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    lazy var facebookLoginButton: UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
//        btn.readPermissions = ["public_profile", "email", "user_friends"]
//        btn.delegate = self
        btn.layer.cornerRadius = 10
        btn.layer.backgroundColor = UIColor.FlatColor.Blue.Blue6.cgColor
        btn.setTitle("페이스북 로그인", for: UIControlState.normal)
        
        return btn
    }()
    
//    lazy var facebookLoginButton: FBSDKLoginButton = {
//        let btn = FBSDKLoginButton(type: UIButtonType.custom)
//        btn.readPermissions = ["public_profile", "email", "user_friends"]
//        btn.delegate = self
//        btn.layer.cornerRadius = 10
//        btn.layer.backgroundColor = UIColor.FlatColor.Blue.Blue6.cgColor
//
//        return btn
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupNavBar()
        bind()
        
//        if let token = FBSDKAccessToken.current() {
//            print("token: \(token.tokenString)")
//            fetchProfile()
//        }
        
    }
    
    fileprivate func tapFbLogin() {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            guard let result = result else {return}
            if result.grantedPermissions.contains("email") {
                self.fetchProfile()
            }
        }
    }
    
    fileprivate func fetchProfile() {
        print("fetch profile")
        let parameters = ["fields": "email, picture.type(large), name"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { [weak self] (connection, result, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            guard let result = result as? [String: Any] else {return}
            print("result: \(result)")
            guard let pictureDict = result["picture"] as? NSDictionary, let pictureData = pictureDict["data"] as? NSDictionary, let pictureUrl = pictureData["url"] as? String else {return}

            
            guard let fbName = result["name"], let fbId = result["id"], let fbEmail = result["email"], let fbToken = FBSDKAccessToken.current().tokenString else {return}

//            print(fbEmail)
            
            let socialKey = "facebook\(fbId)"
            print("-----------------------------")
            print(fbToken)
            print(pictureUrl)
            print("\(fbEmail)")
            print("\(fbId)")
            print("\(fbName)")
            print(socialKey)

            
            
            guard let disposeBag = self?.disposeBag else {return}
            
            
            //              backend models:account -> profile{username: fbId+fbToken (socialKey), thumbnail: pictureUrl}, email: fbEmail, social: {facebook: {id: fbId, accessToken: fbToken, displayName: fbName}}, password: facebook user,
            
            AuthService.shared.fetchFacebook(fbToken: fbToken, pictureUrl: pictureUrl, fbEmail: "\(fbEmail)", fbId: "\(fbId)", fbName: "\(fbName)", socialKey: socialKey).subscribe(onNext: { (respJSON) in
//                print(respJSON)
            }, onError: { (error) in
                print(error.localizedDescription)
            }, onCompleted: {
                UserDefaults.standard.set(fbName, forKey: "socialUsername")
                UserDefaults.standard.set(socialKey, forKey: "username")
                UserDefaults.standard.set(true, forKey: "logged")
                UserDefaults.standard.set(pictureUrl, forKey: "thumbnail")
                UserDefaults.standard.set(true, forKey: "isSocial")
                UserDefaults.standard.set("facebook", forKey: "platform")
                UserDefaults.standard.set(fbToken, forKey: "accessToken")

                self?.showMainViews()
            }, onDisposed: {
                
            }).disposed(by: disposeBag)
            
//
        }
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        
        let components = [loginView, emailTextField, passwordTextField, loginButton, registerButton, facebookLoginButton]
        components.forEach { component in
            component.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(component)
        }
        
        loginView.anchor(top: topLayoutGuide.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 24, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: view.frame.size.height * 0.45))
        
        emailTextField.anchor(top: loginView.topAnchor, leading: loginView.leadingAnchor, bottom: nil, trailing: loginView.trailingAnchor, padding: UIEdgeInsets.init(top: 16, left: 16, bottom: 0, right: 16))
        
        passwordTextField.anchor(top: emailTextField.bottomAnchor, leading: loginView.leadingAnchor, bottom: nil, trailing: loginView.trailingAnchor, padding: UIEdgeInsets.init(top: 16, left: 16, bottom: 0, right: 16))
        loginButton.anchor(top: passwordTextField.bottomAnchor, leading: loginView.leadingAnchor, bottom: nil, trailing: loginView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        registerButton.anchor(top: loginButton.bottomAnchor, leading: loginView.leadingAnchor, bottom: nil, trailing: loginView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        facebookLoginButton.anchor(top: registerButton.bottomAnchor, leading: loginView.leadingAnchor, bottom: nil, trailing: loginView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
    }
    
    fileprivate func setupNavBar() {
        navigationItem.title = "로그인"
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
    
    fileprivate func fetchLogin() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        AuthService.shared.fetchLogin(email: email, password: password).subscribe(onNext: { [weak self] respJSON in
            guard let profile: Profile = Profile(json: respJSON) else {
                return
            }
            
            self?.profileViewModel = ProfileViewModel(profile: profile)
            
            UserDefaults.standard.set(true, forKey: "logged")
            UserDefaults.standard.set(self?.profileViewModel?.username, forKey: "username")
            UserDefaults.standard.set(self?.profileViewModel?.thumbnail, forKey: "thumbnail")
        }, onError: { error in
            print(error.localizedDescription)
        }, onCompleted: {
            self.showMainViews()
        }) {
            
        }.disposed(by: disposeBag)
    }

}

extension LoginController {
    
    func bind() {
        registerButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.navigationController?.pushViewController(RegisterController(), animated: true)
            
        }).disposed(by: disposeBag)
        
        loginButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.fetchLogin()
        }).disposed(by: disposeBag)
        
        facebookLoginButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.tapFbLogin()
        }).disposed(by: disposeBag)
        
    }
    
    func showMainViews() {
        self.present(MainTabBarController(), animated: true, completion: nil)
    }
    
   
   
}

extension LoginController: FBSDKLoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("login completed")
        self.fetchProfile()
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
}

extension UIView {
    func fillSuperview() {
        anchor(top: superview?.topAnchor, leading: superview?.leadingAnchor, bottom: superview?.bottomAnchor, trailing: superview?.trailingAnchor)
    }
    
    func anchorSize(to view: UIView) {
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}




extension UIColor {
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
    }
    
    static let mainTextBlue = UIColor.rgb(r: 7, g: 71, b: 89)
    static let highlightColor = UIColor.rgb(r: 50, g: 199, b: 242)
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex: Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    struct FlatColor {
        struct Gray {
            static let Gray1 = UIColor(netHex: 0xF1F3F5)
            static let Gray4 = UIColor(netHex: 0xCEd4DA)
            static let Gray6 = UIColor(netHex: 0x868E96)
        }
        
        struct Red {
            static let Red4 = UIColor(netHex: 0xFF8787)
        }
        
        struct Blue {
            static let Blue6 = UIColor(netHex: 0x228be6)
        }
    }
}
