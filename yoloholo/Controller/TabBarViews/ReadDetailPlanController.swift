//
//  ReadDetailPlanController.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 25..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import RxSwift
import RxCocoa
import SnapKit

class ReadDetailPlanController: UITableViewController {
    
    let disposeBag: DisposeBag = DisposeBag()
    
    let placeImageCellId: String = "placeImageCellId"
    let stackViewCellId: String = "stackViewCellId"
    let todoButtonCellId: String = "todoButtonCellId"

    var detailPlanViewModel: DetailPlanViewModel?
    
    var nextLatitude: Double?
    var nextLongitude: Double?
    
    var updateButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: nil)
        return btn
    }()
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.isScrollEnabled = true
        sv.autoresizingMask = UIViewAutoresizing.flexibleHeight
        sv.backgroundColor = .white
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    let placeImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 150
        iv.backgroundColor = UIColor.FlatColor.Gray.Gray4
        return iv
    }()
    
    let todoLabel: UILabel = {
        let label = UILabel()
        label.text = "할일 목록"
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.semibold)
        return label
    }()
    
    let todoLabel2: UILabel = {
        let label = UILabel()
        label.text = "할일 목록"
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.semibold)
        return label
    }()

    
    let googleMapLabel: UILabel = {
        let label = UILabel()
        label.text = "구글맵"
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.semibold)
        return label
    }()
    
    let departButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("출발지", for: UIControlState.normal)
        btn.backgroundColor = UIColor.FlatColor.Gray.Gray4
        btn.titleLabel?.textColor = .white
        return btn
        
    }()
    
    let arriveButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("도착지", for: UIControlState.normal)
        btn.backgroundColor = UIColor.FlatColor.Gray.Gray4
        btn.titleLabel?.textColor = .white
        return btn
        
    }()
    
    let nextDestButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("다음 목적지", for: UIControlState.normal)
        btn.backgroundColor = UIColor.FlatColor.Gray.Gray4
        btn.titleLabel?.textColor = .white
        return btn
        
    }()
    
    lazy var buttonStackView: UIStackView = {
        var subViews = [departButton, arriveButton]
        if self.nextLatitude != nil {
            subViews.append(nextDestButton)
        }
        let sv = UIStackView(arrangedSubviews: subViews)
        sv.axis = .horizontal
        sv.spacing = 16
        sv.distribution = .fillEqually
        return sv
    }()
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 1500)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPlaceImage()
        self.navigationItem.rightBarButtonItem = updateButton
        setupTableview()
        setupNavBar()
        bind()
        
        

    }
    
    fileprivate func setupTableview() {
        tableView.register(PlaceImageCell.self, forCellReuseIdentifier: placeImageCellId)
        tableView.register(StackViewTableViewCell.self, forCellReuseIdentifier: stackViewCellId)
        tableView.register(TodoButtonTableViewCell.self, forCellReuseIdentifier: todoButtonCellId)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        tableView.separatorColor = .mainTextBlue
        tableView.backgroundColor = UIColor.rgb(r: 12, g: 47, b: 57)
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 500
        tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: placeImageCellId, for: indexPath) as! PlaceImageCell
            if let detailPlan = self.detailPlanViewModel, let placeId = detailPlan.placeId  {
                GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeId) { (photos, error) -> Void in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else {
                        if let firstPhoto = photos?.results.first {
                            GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: {
                                (photo, error) -> Void in
                                if let error = error {

                                    print("Error: \(error.localizedDescription)")
                                }
                                else {
                                    DispatchQueue.main.async {
                                        cell.placeImageView.image = photo
                                    }
                                }
                            })
                        }
                    }
                }
            }
            return cell
        }
        
        if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: stackViewCellId, for: indexPath) as! StackViewTableViewCell
            
                
            
                cell.arriveButton.addTarget(self, action: #selector(openGoogleMapArrive), for: UIControlEvents.touchUpInside)
                cell.departButton.addTarget(self, action: #selector(openGoogleMapDepart), for: UIControlEvents.touchUpInside)
            
                if let nextLatitude = self.nextLatitude, let nextLongitude = self.nextLongitude {
                    cell.nextLatitude = nextLatitude
                    cell.nextLongitude = nextLongitude
                    cell.nextDestButton.addTarget(self, action: #selector(openGoogleMapNext), for: UIControlEvents.touchUpInside)
                } else {
                    cell.nextDestButton.isHidden = true
            }
            return cell
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: todoButtonCellId, for: indexPath) as! TodoButtonTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId")!
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            
            let dest = TodoTableViewController()
            if let todoList = self.detailPlanViewModel?.todoList, let planId = self.detailPlanViewModel?._id {
//                dest.todoList = todoList
                dest.planId = planId
            }
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 250
        case 1:
            return 80
        case 2:
            return 80
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "장소 이미지"
        }
        if section == 1 {
            return "구글맵 연동"
        }
        if section == 2 {
            return "Todo List"
        }
        
        return nil
    }
    


    fileprivate func setupNavBar() {
        guard let detailPlan = self.detailPlanViewModel else {return}
        
        navigationItem.title = detailPlan.destName
        
        navigationController?.navigationBar.backgroundColor = .yellow
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.rgb(r: 50, g: 199, b: 242)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    fileprivate func fetchRemove() {
        guard let id = self.detailPlanViewModel?._id else {
            return
        }
        DetailPlanService.shared.fetchRemove(id: id).subscribe(onNext: { (respJSON) in
            
        }, onError: { (error) in
            print(error.localizedDescription)
        }, onCompleted: {
            self.navigationController?.popViewController(animated: true)
        }) {
            
        }.disposed(by: disposeBag)
    }
    
}

extension ReadDetailPlanController {
    func getPlaceImage() {
        guard let placeId = self.detailPlanViewModel?.placeId else {
            DispatchQueue.main.async {
                self.placeImageView.removeFromSuperview()
            }
            return

        }
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeId) { (photos, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: {
                        (photo, error) -> Void in
                        if let error = error {
                            
                            print("Error: \(error.localizedDescription)")
                        }
                        else {
                            DispatchQueue.main.async {
                                self.placeImageView.image = photo
                            }
                        }
                    })
                }
            }
        }
    }
    
    func bind() {
        updateButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: "수정하기", style: UIAlertActionStyle.default, handler: { [weak self] (alertAction) in
                let dest = AddDetailController()
                guard let detailPlan = self?.detailPlanViewModel else {return}
                guard let _id = self?.detailPlanViewModel?._id else {return}
                guard let latitude = self?.detailPlanViewModel?.latitude else {return}
                guard let longitude = self?.detailPlanViewModel?.longitude else {return}
                guard let placeId = self?.detailPlanViewModel?.placeId else {return}
                
                dest.detailPlan = detailPlan
                dest.googlePlaceId = placeId
                dest.googleLatitude = latitude
                dest.googleLongitude = longitude
                dest._id = _id
                
                self?.navigationController?.pushViewController(dest, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "목적지 삭제", style: .destructive, handler: { [weak self] (alertAction) in
                let alert = UIAlertController(title: "삭제", message: "정말로 삭제하시겠습니까?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { [weak self] (alertAction) in
                    self?.fetchRemove()
                }))
                alert.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.destructive, handler: { (alertAction) in
                    
                }))
                
                self?.present(alert, animated: true, completion: {
                    
                })
                
            }))
            
            alert.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.default, handler: { (alertAction) in
                
            }))
            
            self?.present(alert, animated: true, completion: {
                
            })
        }).disposed(by: disposeBag)
        
        departButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.openGoogleMap(category: "depart")
        }).disposed(by: disposeBag)
        
        arriveButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.openGoogleMap(category: "arrive")
        }).disposed(by: disposeBag)
        
        nextDestButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.openGoogleMap(category: "next")
        }).disposed(by: disposeBag)
    }

    
    @objc func openGoogleMapArrive() {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {

            guard let latitude = self.detailPlanViewModel?.latitude else {
                fatalError("parsingError")
            }
            guard let longitude = self.detailPlanViewModel?.longitude else {
                 fatalError("parsingError")
            }
            
            guard let url = URL(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=transit") else {
                return
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            

            
        } else {
            let alert = UIAlertController(title: "앗!", message: "구글맵을 설치해주세요!", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "설치하러가기", style: UIAlertActionStyle.default, handler: { (alertActions) in
                guard let appStoreUrl = URL(string: "itms-apps://itunes.apple.com/app/id585027354") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(appStoreUrl, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(appStoreUrl)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.default, handler: { (alertActions) in
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @objc func openGoogleMapDepart() {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            
            guard let latitude = self.detailPlanViewModel?.latitude else {
                return
            }
            guard let longitude = self.detailPlanViewModel?.longitude else {
                return
            }
            
            guard let url = URL(string: "comgooglemaps://?saddr=\(latitude),\(longitude)&daddr=&directionsmode=transit") else {
                return
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
            
            
        } else {
            let alert = UIAlertController(title: "앗!", message: "구글맵을 설치해주세요!", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "설치하러가기", style: UIAlertActionStyle.default, handler: { (alertActions) in
                guard let appStoreUrl = URL(string: "itms-apps://itunes.apple.com/app/id585027354") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(appStoreUrl, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(appStoreUrl)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.default, handler: { (alertActions) in
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @objc func openGoogleMapNext() {
        print("next tapped")
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            
            guard let latitude = self.detailPlanViewModel?.latitude else {
                return
            }
            guard let longitude = self.detailPlanViewModel?.longitude else {
                return
            }
            
            guard let nextLatitude = self.nextLatitude else {
                let alert = UIAlertController(title: "마지막 목적지", message: "마지막 목적지 입니다.", preferredStyle: UIAlertControllerStyle.alert)
                
                
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { (alertActions) in
                    
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                return
            }
            guard let nextLongitude = self.nextLongitude else {
                let alert = UIAlertController(title: "마지막 목적지", message: "마지막 목적지 입니다.", preferredStyle: UIAlertControllerStyle.alert)
                
                
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { (alertActions) in
                    
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let url = URL(string: "comgooglemaps://?saddr=\(latitude),\(longitude)&daddr=\(nextLatitude),\(nextLongitude)&directionsmode=transit") else {
                return
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
            
            
        } else {
            let alert = UIAlertController(title: "앗!", message: "구글맵을 설치해주세요!", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "설치하러가기", style: UIAlertActionStyle.default, handler: { (alertActions) in
                guard let appStoreUrl = URL(string: "itms-apps://itunes.apple.com/app/id585027354") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(appStoreUrl, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(appStoreUrl)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.default, handler: { (alertActions) in
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @objc func openGoogleMap(category: String?) {
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            
            
            
            guard let category = category else {return}
            
            guard let latitude = self.detailPlanViewModel?.latitude else {
                return
            }
            guard let longitude = self.detailPlanViewModel?.longitude else {
                return
            }
            
            if category == "arrive" {

                guard let url = URL(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=transit") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else if category == "depart" {
                
                
                guard let url = URL(string: "comgooglemaps://?saddr=\(latitude),\(longitude)&daddr=&directionsmode=transit") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                guard let nextLatitude = self.nextLatitude else {
                    return
                }
                guard let nextLongitude = self.nextLongitude else {
                    return
                }
                
                guard let url = URL(string: "comgooglemaps://?saddr=\(latitude),\(longitude)&daddr=\(nextLatitude),\(nextLongitude)&directionsmode=transit") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
            
            
            
            
        } else {
            let alert = UIAlertController(title: "앗!", message: "구글맵을 설치해주세요!", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "설치하러가기", style: UIAlertActionStyle.default, handler: { (alertActions) in
                guard let appStoreUrl = URL(string: "itms-apps://itunes.apple.com/app/id585027354") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(appStoreUrl, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(appStoreUrl)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.default, handler: { (alertActions) in
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
    }
    
    
}
//
//extension ReadDetailPlanController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ReadDetailTableViewCell
//
//        switch indexPath.section {
//        case 0:
//            if let detailPlan = self.detailPlanViewModel, let placeId = detailPlan.placeId  {
//                GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeId) { (photos, error) -> Void in
//                    if let error = error {
//                        print("Error: \(error.localizedDescription)")
//                    } else {
//                        if let firstPhoto = photos?.results.first {
//                            GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: {
//                                (photo, error) -> Void in
//                                if let error = error {
//
//                                    print("Error: \(error.localizedDescription)")
//                                }
//                                else {
//                                    DispatchQueue.main.async {
//                                        cell.placeImageView.image = photo
//                                    }
//                                }
//                            })
//                        }
//                    }
//                }
//            }
//            break
//        case 1:
//
//            break
//        case 2:
//
//            break
//        default:
//            break
//        }
//
//        return cell
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 3
//    }
//
//
//
//
//
//}

