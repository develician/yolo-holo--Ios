//
//  ChangeProfileController.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 23..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class ChangeProfileController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var profileImageData: String?
    
    var profileViewModel: ProfileViewModel?
    
    var keyboardShowed: Bool = false
    
    var topViewTopConstraint: NSLayoutConstraint?
    
    lazy var imagePicker: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()

    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isScrollEnabled = true
        sv.bounces = true
        sv.alwaysBounceVertical = true
        sv.backgroundColor = .white
        return sv
    }()
    
    let topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.FlatColor.Gray.Gray1
        
        return view
    }()
    
    lazy var profileImageTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(pickProfileImage))
        
        return gesture
    }()
    
    lazy var userInfoViewTagGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(keyboardDown))
        return gesture
    }()
    
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .clear
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 75
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(profileImageTapGesture)
        return iv
    }()

    lazy var userInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addGestureRecognizer(userInfoViewTagGesture)
        return view
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.bold)
        label.textAlignment = .center
        return label
    }()
    
    let usernameDescLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        return label
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.FlatColor.Gray.Gray1
        return tf
    }()
    
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "패스워드"
        return label
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.FlatColor.Gray.Gray1
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let passwordCheckLabel: UILabel = {
        let label = UILabel()
        label.text = "패스워드 확인"
        return label
    }()
    
    let passwordCheckTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.FlatColor.Gray.Gray1
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let changePasswordButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("비밀번호 변경", for: UIControlState.normal)
        btn.backgroundColor = UIColor.mainTextBlue
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topViewTopConstraint = NSLayoutConstraint(item: self.topView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.scrollView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)
        view.backgroundColor = .white
        print(userInfoView.frame.origin.y)
        setupNavBar()
        setupViews()
        bind()
        guard let imageData = self.profileImageData else {
            return
        }
        guard let image = UIImage(contentsOfFile: imageData) else {
            return
        }
        profileImageView.image = image
        rxKeyboardHeight().observeOn(MainScheduler.instance)
            .subscribe { [weak self] (height) in
                guard let height = height.element else {
                    return
                }
                guard let keyboardShowed = self?.keyboardShowed else {return}
                if keyboardShowed {
                    return
                }
                
                if height == 0 {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self?.topViewTopConstraint?.constant = 0

                        self?.view.layoutIfNeeded()
                    })
                } else {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self?.topViewTopConstraint?.constant = -200
                        self?.view.layoutIfNeeded()
                        self?.keyboardShowed = true
                        
                    })
                    
                }
                
        }.disposed(by: disposeBag)
    }
    
    fileprivate func setupViews() {
        let components = [scrollView, topView, userInfoView]
        components.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        scrollView.anchor(top: topLayoutGuide.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        self.topViewTopConstraint?.isActive = true
        topView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 0).isActive = true
        topView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 0).isActive = true
        topView.heightAnchor.constraint(equalToConstant: view.frame.size.height * 0.25).isActive = true

        topView.addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        profileImageView.centerXAnchor.constraint(equalTo: topView.centerXAnchor, constant: 0).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor, constant: 0).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        userInfoView.anchor(top: topView.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        let userInfoViewComponents = [usernameLabel, passwordLabel, passwordTextField, passwordCheckLabel, passwordCheckTextField, changePasswordButton]
        userInfoViewComponents.forEach { component in
            component.translatesAutoresizingMaskIntoConstraints = false
            userInfoView.addSubview(component)
        }
        
        usernameLabel.anchor(top: userInfoView.topAnchor, leading: userInfoView.leadingAnchor, bottom: nil, trailing: userInfoView.trailingAnchor, padding: .init(top: 24, left: 24, bottom: 0, right: 24), size: .init(width: 0, height: 24))

       
        
        passwordLabel.anchor(top: usernameLabel.bottomAnchor, leading: userInfoView.leadingAnchor, bottom: nil, trailing: userInfoView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        passwordTextField.anchor(top: passwordLabel.bottomAnchor, leading: userInfoView.leadingAnchor, bottom: nil, trailing: userInfoView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        passwordCheckLabel.anchor(top: passwordTextField.bottomAnchor, leading: userInfoView.leadingAnchor, bottom: nil, trailing: userInfoView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        passwordCheckTextField.anchor(top: passwordCheckLabel.bottomAnchor, leading: userInfoView.leadingAnchor, bottom: nil, trailing: userInfoView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        changePasswordButton.anchor(top: passwordCheckTextField.bottomAnchor, leading: userInfoView.leadingAnchor, bottom: nil, trailing: userInfoView.trailingAnchor, padding: .init(top: 32, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: 32))
    }

    fileprivate func setupNavBar() {
        navigationItem.title = "계정 설정"
        
        navigationController?.navigationBar.backgroundColor = .yellow
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.rgb(r: 50, g: 199, b: 242)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
    }

    fileprivate func fetchChangePassword() {
        guard let password = passwordTextField.text else {return}
        guard let passwordCheck = passwordCheckTextField.text else {return}
        if password != passwordCheck {
            let alert = UIAlertController(title: "오류", message: "두 비밀번호가 일치하지 않습니다.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        AuthService.shared.fetchChangePassword(password: password, username: username).subscribe(onNext: { respJSON in
            
        }, onError: { error in
            print(error.localizedDescription)
        }, onCompleted: {
            let alert = UIAlertController(title: "결과", message: "비밀번호가 변경되었습니다.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: {
                self.popViewController()
            })
        }) {
            print("change password observable disposed")
        }.disposed(by: disposeBag)
    }
}

extension ChangeProfileController {
    func bind() {
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        guard let socialUsername = UserDefaults.standard.string(forKey: "socialUsername") else {return}
        let isSocial = UserDefaults.standard.bool(forKey: "isSocial")
        
        AuthService.shared.fetchProfile(username: username).subscribe(onNext: { [weak self] respJSON in
            guard let profile = Profile(json: respJSON) else {return}
            
            self?.profileViewModel = ProfileViewModel(profile: profile)
        
            if isSocial {
                self?.usernameLabel.text = socialUsername
            } else {
                self?.usernameLabel.text = self?.profileViewModel?.username
            }
            
        }, onError: { error in
            print(error.localizedDescription)
        }, onCompleted: {
            print("completed profile observable")
        }) {
            print("disposed profile observable")
        }.disposed(by: disposeBag)
        
        changePasswordButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.fetchChangePassword()
        }).disposed(by: disposeBag)
        
    }
    
    func rxKeyboardHeight() -> Observable<CGFloat> {
        return Observable.from([NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillShow).map {
            notification -> CGFloat in
            (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
            }, NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillHide).map {
                _ -> CGFloat in
                0
            }]).merge()
    }
    
    @objc func pickProfileImage() -> (Void) {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardDown() {
        guard let topViewConstraint = self.topViewTopConstraint else {
            return
        }
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5, animations: {
            
            topViewConstraint.constant = 0
            self.view.layoutIfNeeded()
            self.keyboardShowed = false
        })
    }
}

extension ChangeProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        guard let url = URL(string: "http://13.209.99.24/api/user/profile/\(username)") else {
            return
        }
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let data = UIImageJPEGRepresentation(pickedImage, 1) {
                print("picked image data: \(data)")
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    multipartFormData.append(data, withName: "profileImage", fileName: "profile.jpg", mimeType: "image/jpg")
                }, to: url, encodingCompletion: { (result) in
                    switch result {
                    case .success(let upload, _, _):
                        print("success")
                        upload.responseJSON(completionHandler: { [weak self] (respJSON) in
                            
                            guard let jsonValue = respJSON.result.value else {
                                return
                            }
                            
                            let responseJSON = JSON(jsonValue)
                            
                            
                            guard let filename = responseJSON["filename"].string else {
                                return
                            }
                            
                            UserDefaults.standard.set("/static/images/\(filename)", forKey: "thumbnail")
                            
//                            guard let url = URL(string: "\(ProfileAPI)/static/images/\(filename)") else {
//                                return
//                            }
                            
                            guard let url = ProfileAPI.pickedImage(filename: filename).url else {return}
                            
                            
                            
                            guard let disposeBag = self?.disposeBag else {
                                return
                            }
                            guard let profileImageView = self?.profileImageView else {
                                return
                            }
                            ProfileService.shared.fetchGetProfileImage(url: url).map {
                                 (data: String) -> UIImage in
                                guard let image = UIImage(contentsOfFile: data) else {
                                    throw RxError.noElements
                                }
                                return image
                            }.observeOn(MainScheduler.instance).bind(to: profileImageView.rx.image).disposed(by: disposeBag)
                        })
                        break
                    case .failure(let error):
                        print("failure")
                        print(error.localizedDescription)
                    }
                })
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
