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

class ReadDetailPlanController: UIViewController {
    
    let disposeBag: DisposeBag = DisposeBag()
    
    let cellId: String = "cellId"
    
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
    
    lazy var todoTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .white
        tv.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tv.delegate = self
        tv.dataSource = self
        tv.tableFooterView = UIView()
        return tv
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
        setupViews()
        setupNavBar()
        bind()
        
        

    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = updateButton
        
        let viewComponents = [scrollView]
        viewComponents.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        let scrollViewComponents = [placeImageView, todoLabel, todoTableView, googleMapLabel, buttonStackView]
        scrollViewComponents.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
        
        
        scrollView.anchor(top: topLayoutGuide.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        
        placeImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24).isActive = true
        placeImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        placeImageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        placeImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        todoLabel.anchor(top: placeImageView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 24, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: 32))
        
        todoTableView.anchor(top: todoLabel.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 0, bottom: 0, right: 0), size: .init(width: view.frame.size.width, height: 150))
        
        googleMapLabel.anchor(top: todoTableView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 24, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: 32))
        
        buttonStackView.anchor(top: googleMapLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: 32))
        
        
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
        guard let placeId = self.detailPlanViewModel?.placeId else {return}
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

extension ReadDetailPlanController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let detailPlan = self.detailPlanViewModel {
            return detailPlan.todoList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let detailPlan = self.detailPlanViewModel {
            cell.textLabel?.text = "\(detailPlan.todoList[indexPath.row])"
        }
//        cell.textLabel?.text = "Testing.."
        return cell
    }
    
    
}
