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
        btn.setTitle("Google Map", for: UIControlState.normal)
        btn.backgroundColor = UIColor.FlatColor.Gray.Gray6
        btn.titleLabel?.textColor = .white
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
        
        let viewComponents = [scrollView]
        viewComponents.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        

        let scrollViewComponents = [contentView]
        scrollViewComponents.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
        
        let contentViewComponents = [destNameTextField, googleMapButton, todoTitleLable, todoAddField, todoAddButton, todoTableView]
        contentViewComponents.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        scrollView.anchor(top: topLayoutGuide.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        contentView.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: view.frame.size.width, height: 1500))
        
        destNameTextField.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor, padding: .init(top: 16, left: 24, bottom: 0, right: 24))
        
        googleMapButton.anchor(top: destNameTextField.bottomAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor, padding: .init(top: 24, left: 24, bottom: 0, right: 24), size: .init(width: 0, height: 32))
        
        todoTitleLable.anchor(top: googleMapButton.bottomAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor, padding: .init(top: 24, left: 24, bottom: 0, right: 24))
        todoAddField.anchor(top: todoTitleLable.bottomAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor, padding: .init(top: 16, left: 24, bottom: 0, right: 24))
        todoAddButton.anchor(top: todoAddField.bottomAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor, padding: .init(top: 16, left: 24, bottom: 0, right: 24), size: .init(width: 0, height: 32))
        
        todoTableView.anchor(top: todoAddButton.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: .init(top: 24, left: 24, bottom: 56, right: 24))
    }
    
    fileprivate func setupNavBar() {
        navigationItem.title = "상세 일정 추가"
        
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
            
            guard let latitude = self?.googleLatitude, let longitude = self?.googleLongitude, let placeId = self?.googlePlaceId else {return}
            guard let todoList = self?.todoList else {return}
            guard let googleMapEnabled = self?.googleMapEnabled else {return}
            guard let disposeBag = self?.disposeBag else {return}
            
            guard let isUpdate = self?.isUpdate else {return}
            
            
            if isUpdate {
                guard let id = self?._id else {return}
                DetailPlanService.shared.fetchUpdate(id: id, destName: destName, latitude: latitude, longitude: longitude, placeId: placeId, todoList: todoList).subscribe(onNext: { [weak self] (respJSON) in
//                    let detailPlan: DetailPlan = DetailPlan(json: respJSON)
//                    let detailPlanViewModel = DetailPlanViewModel(detailPlan: detailPlan)
//                    let dest = ReadDetailPlanController()
//                    dest.detailPlanViewModel = detailPlanViewModel
//                    self?.navigationController.pop
                }, onError: { (error) in
                    print(error.localizedDescription)
                }, onCompleted: {
//                    let dest = DetailPlanController()
                    guard let viewControllers = self?.navigationController?.viewControllers else {return}
//                    print()
                    self?.navigationController?.popToViewController(viewControllers[2], animated: true)
                }, onDisposed: {
                    
                }).disposed(by: disposeBag)
            } else {
                guard let planId = self?.planId else {return}
                guard let username = UserDefaults.standard.string(forKey: "username") else {return}
                
                guard let day = self?.day else {return}
                
                DetailPlanService.shared.fetchCreate(planId: planId, username: username, day: day, destName: destName, latitude: latitude, longitude: longitude, placeId: placeId, todoList: todoList, googleMapEnabled: googleMapEnabled).subscribe(onNext: { (respJSON) in
                    
                }, onError: { (error) in
                    print(error.localizedDescription)
                }, onCompleted: {
                    self?.navigationController?.popViewController(animated: true)
                }, onDisposed: {
                    
                }).disposed(by: disposeBag)
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
        self.googleMapEnabled = false
    }
    
    
}
