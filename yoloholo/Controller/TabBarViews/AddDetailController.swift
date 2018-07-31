//
//  AddDetailController.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 25..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleMaps
import GooglePlacePicker
import SnapKit

class AddDetailController: UIViewController {

    var detailPlan: DetailPlanViewModel?
    var isUpdate: Bool = false
   
    
    let cellId: String = "cellId"
    
    let disposeBag: DisposeBag = DisposeBag()
    
    var todoList: [String] = [String]()
    
    var googlePlaceId: String?
    var googleLatitude: CLLocationDegrees?
    var googleLongitude: CLLocationDegrees?
    
    var _id: String?
    
    var planId: String?
    var day: Int?
    
    var googleMapEnabled = false
    
    let doneButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: nil)
        return btn
    }()
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        view.isScrollEnabled = true
        view.backgroundColor = .white
       
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    let destNameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "목적지 이름"
        return tf
    }()
    
    let todoTitleLable: UILabel = {
        let label = UILabel()
        label.text = "할일 목록 추가"
        
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.semibold)
        return label
    }()
    
    let todoAddField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "할일을 입력하세요"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    let todoAddButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("할일 추가하기", for: UIControlState.normal)
        btn.backgroundColor = UIColor.FlatColor.Blue.Blue6
        btn.titleLabel?.textColor = UIColor.white
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        return btn
    }()
    
    let googleMapButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("위치 설정(구글맵)", for: UIControlState.normal)
        btn.backgroundColor = UIColor.mainTextBlue
        btn.titleLabel?.textColor = .white
        btn.layer.cornerRadius = 12
        btn.clipsToBounds = true
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
        return btn
    }()
    
    lazy var todoTableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .white
        tv.tableFooterView = UIView()
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //        destName, latitude?, longitude?, placeId?, todoList

        
        
        setupViews()
        setupNavBar()
        bind()
        
        if let detailPlan = self.detailPlan {
            self.destNameTextField.text = detailPlan.destName
            self.todoList = detailPlan.todoList.enumerated().map {
                element in
                return "\(element.element)"
            }
            
            self.todoTableView.reloadData()
            self.isUpdate = true
        }
    }

    fileprivate func setupViews() {
        view.backgroundColor = .white

        
        navigationItem.rightBarButtonItem = doneButton
        
        let viewComponents = [destNameTextField, googleMapButton]
        viewComponents.forEach {
            view.addSubview($0)
        }
        
        destNameTextField.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(28)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom).offset(28)
            }
            make.left.equalTo(view.snp.left).offset(28)
            make.right.equalTo(view.snp.right).offset(-28)
        }
        
        googleMapButton.snp.makeConstraints { (make) in
            make.top.equalTo(destNameTextField.snp.bottom).offset(28)
            make.left.equalTo(view.snp.left).offset(28)
            make.right.equalTo(view.snp.right).offset(-28)
            make.height.equalTo(32)
        }
        

    }
    
    fileprivate func setupNavBar() {
        navigationItem.title = "목적지 추가"
        
        navigationController?.navigationBar.backgroundColor = .yellow
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.rgb(r: 50, g: 199, b: 242)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
    }


}

extension AddDetailController {
    func bind() {
        
        
        todoAddButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            if let todo = self?.todoAddField.text, todo.trimmingCharacters(in: .whitespacesAndNewlines).count > 0{
                self?.todoList.append(todo)
            } else {
                let alert = UIAlertController(title: "오류", message: "할일을 채워주세요.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                return
            }
            self?.todoAddField.text = ""
            self?.todoTableView.reloadData()
        }).disposed(by: disposeBag)
        
        googleMapButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            let config = GMSPlacePickerConfig(viewport: nil)
            let placePicker = GMSPlacePickerViewController(config: config)
            placePicker.delegate = self
            self?.present(placePicker, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        doneButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            print("done button rx")
            
            
            guard let destName = self?.destNameTextField.text, destName.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else {return}
            
            
            
            guard let todoList = self?.todoList else {return}
            guard let googleMapEnabled = self?.googleMapEnabled else {return}
            
            print("googleMapEnabled: \(googleMapEnabled)")
            
            guard let disposeBag = self?.disposeBag else {return}
            
            guard let isUpdate = self?.isUpdate else {return}
            
            
            if isUpdate {
                guard let id = self?._id else {return}
                if googleMapEnabled {
                    guard let latitude = self?.googleLatitude, let longitude = self?.googleLongitude, let placeId = self?.googlePlaceId else {return}
                    DetailPlanService.shared.fetchUpdate(id: id, destName: destName, latitude: latitude, longitude: longitude, placeId: placeId, todoList: todoList).subscribe(onNext: { (respJSON) in
                        print(respJSON)
                    }, onError: { (error) in
                        print(error.localizedDescription)
                    }, onCompleted: {
                        guard let viewControllers = self?.navigationController?.viewControllers else {return}
                        self?.navigationController?.popToViewController(viewControllers[2], animated: true)
                    }, onDisposed: {
                        
                    }).disposed(by: disposeBag)
                } else {
                    DetailPlanService.shared.fetchUpdate(id: id, destName: destName, latitude: nil, longitude: nil, placeId: nil, todoList: todoList).subscribe(onNext: { (respJSON) in
                        print(respJSON)
                    }, onError: { (error) in
                        print(error.localizedDescription)
                    }, onCompleted: {
                        guard let viewControllers = self?.navigationController?.viewControllers else {return}
                        self?.navigationController?.popToViewController(viewControllers[2], animated: true)
                    }, onDisposed: {
                        
                    }).disposed(by: disposeBag)
                }
            } else {
                guard let planId = self?.planId else {return}
                guard let username = UserDefaults.standard.string(forKey: "username") else {return}
                
                guard let day = self?.day else {return}
                
                if googleMapEnabled {
                    guard let latitude = self?.googleLatitude, let longitude = self?.googleLongitude, let placeId = self?.googlePlaceId else {return}
                    
                    DetailPlanService.shared.fetchCreate(planId: planId, username: username, day: day, destName: destName, latitude: latitude, longitude: longitude, placeId: placeId, todoList: todoList, googleMapEnabled: googleMapEnabled).subscribe(onNext: { (respJSON) in
                        print(respJSON)
                    }, onError: { (error) in
                        print(error.localizedDescription)
                    }, onCompleted: {
                        self?.navigationController?.popViewController(animated: true)
                    }, onDisposed: {
                        
                    }).disposed(by: disposeBag)
                } else {
                    DetailPlanService.shared.fetchCreate(planId: planId, username: username, day: day, destName: destName, latitude: nil, longitude: nil, placeId: nil, todoList: todoList, googleMapEnabled: googleMapEnabled).subscribe(onNext: { (respJSON) in
                        print(respJSON)
                    }, onError: { (error) in
                        print(error.localizedDescription)
                    }, onCompleted: {
                        self?.navigationController?.popViewController(animated: true)
                    }, onDisposed: {
                        
                    }).disposed(by: disposeBag)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    
}

extension AddDetailController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UITableViewCell
        cell.textLabel?.text = self.todoList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.todoList.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    
}

extension AddDetailController: GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        viewController.dismiss(animated: true, completion: nil)
        
        print("Place name \(place.name)")
        print("Place address \(place.formattedAddress)")
        print("Place attributions \(place.attributions)")
        print("Place latitude \(place.coordinate.latitude)")
        print("Place longitude \(place.coordinate.longitude)")
        print("Place placeId \(place.placeID)")

        self.googleLatitude = place.coordinate.latitude
        self.googleLongitude = place.coordinate.longitude
        self.googlePlaceId = place.placeID
        
        self.googleMapEnabled = true
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
//        self.googleMapEnabled = false
    }
    
    
}
