//
//  SettingViewController.swift
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

class SettingViewController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var profileImageData: String?
    
    let cellId: String = "cellId"
    
    var loading: Bool = true
    
    
    let profileView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.FlatColor.Gray.Gray1
        return view
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 75
        
        return iv
    }()
    
    lazy var settingTableView: UITableView = {
        let tv = UITableView()
        tv.register(SettingTableViewCell.self, forCellReuseIdentifier: cellId)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = UIColor.FlatColor.Gray.Gray4
        tv.tableFooterView = UIView()
        return tv
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.rxGetProfileImage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.backgroundColor = .white

        setupNavBar()
        setupViews()
        
    }
    
    fileprivate func setupNavBar() {
        navigationItem.title = "설정"
        
        navigationController?.navigationBar.backgroundColor = .yellow
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.rgb(r: 50, g: 199, b: 242)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    fileprivate func setupViews() {
        let components = [profileView, profileImageView, settingTableView]
        components.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        profileView.anchor(top: topLayoutGuide.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: CGSize.init(width: 0, height: view.frame.size.height * 0.25))
        
        profileImageView.centerXAnchor.constraint(equalTo: profileView.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: profileView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true

        
        settingTableView.anchor(top: profileView.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    fileprivate func fetchLogout() {
        AuthService.shared.fetchLogout().subscribe(onNext: { respJSON in
            
            let isSocial = UserDefaults.standard.bool(forKey: "isSocial")
            if isSocial {
                guard let socialPlatform = UserDefaults.standard.string(forKey: "platform") else {return}
                if socialPlatform == "facebook" {
                    let facebookLoginManager = FBSDKLoginManager()
                    facebookLoginManager.logOut()
                }
            }

            
            
            
        }, onError: { error in
            print(error.localizedDescription)
        }, onCompleted: {
            UserDefaults.standard.set(false, forKey: "logged")
            UserDefaults.standard.set(nil, forKey: "username")
            UserDefaults.standard.set(nil, forKey: "thumbnail")
            UserDefaults.standard.set(nil, forKey: "socialUsername")
            UserDefaults.standard.set(false, forKey: "isSocial")
            UserDefaults.standard.set(nil, forKey: "platform")
            UserDefaults.standard.set(nil, forKey: "accessToken")
            
            AppDelegateUtil.shared.showAuthView()
            
//            let desc = CustomNavigationController(rootViewController: LoginController())
//            self.present(desc, animated: true, completion: nil)
        }) {
            print("logout observable disposed")
        }.disposed(by: disposeBag)
    }



}

extension SettingViewController {
    func rxGetProfileImage() {
        guard let thumbnailPath = UserDefaults.standard.string(forKey: "thumbnail") else {
            return
        }
        if UserDefaults.standard.bool(forKey: "isSocial") {
            guard let socialProfileUrlStr = UserDefaults.standard.string(forKey: "thumbnail") else {return}
        
            guard let url = URL(string: socialProfileUrlStr) else {return}
//            guard let url = URL(string: "http://192.168.0.23:4000\(thumbnailPath)") else {return}
            
            Observable.just(url).subscribe(onNext: { [weak self] (imageUrl) in
                self?.view.isUserInteractionEnabled = false
                guard let disposeBag = self?.disposeBag else {return}
                ProfileService.shared.fetchGetProfileImage(url: url).subscribe(onNext: { [weak self] (data: String) in
                    self?.profileImageData = data
                    guard let image = UIImage(contentsOfFile: data) else {
                        return
                    }
                    self?.profileImageView.image = image
                    
                    }, onError: { (error) in
                        print(error.localizedDescription)
                }, onCompleted: {
                    
                }, onDisposed: {
                    self?.view.isUserInteractionEnabled = true
                }).disposed(by: disposeBag)
            }).disposed(by: disposeBag)
        } else {
//            guard let url = URL(string: "http://13.209.99.24\(thumbnailPath)") else {return}
            guard let url = ProfileAPI.getProfileImage(thumbnailPath: thumbnailPath).url else {return}
            Observable.just(url).subscribe(onNext: { [weak self] (imageUrl) in
                self?.view.isUserInteractionEnabled = false
                guard let disposeBag = self?.disposeBag else {return}
                ProfileService.shared.fetchGetProfileImage(url: url).subscribe(onNext: { [weak self] (data: String) in
                    self?.profileImageData = data
                    guard let image = UIImage(contentsOfFile: data) else {
                        return
                    }
                    self?.profileImageView.image = image
                    
                    }, onError: { (error) in
                        print(error.localizedDescription)
                }, onCompleted: {
                    
                }, onDisposed: {
                    self?.view.isUserInteractionEnabled = true
                }).disposed(by: disposeBag)
            }).disposed(by: disposeBag)
        }
        
        
        
     
        
        
    
    }


    
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isSocial = UserDefaults.standard.bool(forKey: "isSocial")
        if isSocial {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SettingTableViewCell
        
        let isSocial = UserDefaults.standard.bool(forKey: "isSocial")
        
        if isSocial {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = NSLocalizedString("logout", comment: "")
                break
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "계정 설정"
                break
            case 1:
                cell.textLabel?.text = NSLocalizedString("로그아웃", comment: "")
                break
            default:
                break
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isSocial = UserDefaults.standard.bool(forKey: "isSocial")
        
        if isSocial {
            switch indexPath.row {
            case 0:
                self.fetchLogout()
                break
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                let desc = ChangeProfileController()
                desc.profileImageData = self.profileImageData
                self.navigationController?.pushViewController(desc, animated: true)
                break
            case 1:
                self.fetchLogout()
                break
            default:
                break
            }
        }
    }
    
    
}
