//
//  DetailPlanController.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 24..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class DetailPlanController: UIViewController {
    
    let cellId: String = "cellId"
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var planId: String?
    var day: Int?
    
    var detailPlanList: [DetailPlanViewModel] = [DetailPlanViewModel]()
    
    
    
    let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.FlatColor.Gray.Gray4
        return view
    }()
    
    let descLabel: UILabel = {
        let label = UILabel()
        label.text = "위 상단의 추가 버튼을 사용하여 상세 일정을 추가해 주세요"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.light)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let addBarButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: nil)
        btn.tintColor = .white
        return btn
    }()
    
    lazy var circleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.alwaysBounceVertical = true
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.register(CircleCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        return cv
        
    }()
    
    //    override func viewWillDisappear(_ animated: Bool) {
    //        super.viewWillDisappear(animated)
    //
    //        self.navigationController?.setNavigationBarHidden(false, animated: false)
    //    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //         self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        guard let id = planId else {return}
        guard let day = day else {return}
        
        DetailPlanService.shared.fetchRead(planId: id, day: day).subscribe(onNext: { [weak self] (respJSON) in
            //            print(respJSON)
            
            self?.detailPlanList = respJSON.enumerated().map {
                json in
                let detailPlan: DetailPlan = DetailPlan(json: json.element.1)
                let detailPlanViewModel: DetailPlanViewModel = DetailPlanViewModel(detailPlan: detailPlan)
                return detailPlanViewModel
            }
            
            //            print(self?.detailPlanList)
            
            if let detailPlanList = self?.detailPlanList {
                if detailPlanList.count == 0 {
                    self?.setupViewsWhenEmpty()
                } else {
                    self?.setupNotEmpty()
                    self?.emptyView.isHidden = true
                    self?.descLabel.isHidden = true
                }
            }
            }, onError: { (error) in
                
        }, onCompleted: {
            self.circleCollectionView.reloadData()
        }) {
            
            }.disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollHeight = scrollView.frame.size.height
        guard let navBarHeight = self.navigationController?.navigationBar.frame.size.height else {
            return
        }
        if offsetY > navBarHeight && contentHeight > scrollHeight && velocity.y > 0 {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupViews()
        setupNavBar()
        bind()
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = addBarButton
        
        
    }
    
    fileprivate func setupViewsWhenEmpty() {
        let components = [emptyView]
        components.forEach { (component) in
            component.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(component)
        }
        
        let emptyViewComponents = [descLabel]
        emptyViewComponents.forEach { (component) in
            component.translatesAutoresizingMaskIntoConstraints = false
            emptyView.addSubview(component)
        }
        
        emptyView.anchor(top: topLayoutGuide.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        descLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        descLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        descLabel.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
    }
    
    fileprivate func setupNotEmpty() {
        let components = [circleCollectionView]
        components.forEach { (component) in
            component.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(component)
        }
        guard let tabBarHeight = self.tabBarController?.tabBar.frame.size.height else {return}
        circleCollectionView.anchor(top: topLayoutGuide.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 24, bottom: tabBarHeight, right: 24))
    }
    
    fileprivate func setupNavBar() {
        guard let day = self.day else {return}
        navigationItem.title = "\(day)일차 상세"
        
        navigationController?.navigationBar.backgroundColor = .yellow
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.rgb(r: 50, g: 199, b: 242)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
}

extension DetailPlanController {
    func bind() {
        addBarButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            let dest = AddDetailController()
            guard let planId = self?.planId else {return}
            guard let day = self?.day else {return}
            dest.planId = planId
            dest.day = day
            self?.navigationController?.pushViewController(dest, animated: true)
        }).disposed(by: disposeBag)
    }
    
    
    
    
}

extension DetailPlanController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.detailPlanList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CircleCollectionViewCell
        
        
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: self.detailPlanList[indexPath.row].placeId) { (photos, error) -> Void in
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
        
        cell.destNameLabel.text = self.detailPlanList[indexPath.row].destName
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dest = ReadDetailPlanController()
        dest.detailPlanViewModel = self.detailPlanList[indexPath.item]
        if indexPath.item + 1 < self.detailPlanList.count {
            let nextLatitude = self.detailPlanList[indexPath.item + 1].latitude
            let nextLongitude = self.detailPlanList[indexPath.item + 1].longitude
            dest.nextLatitude = nextLatitude
            dest.nextLongitude = nextLongitude
        }
        
        self.navigationController?.pushViewController(dest, animated: true)
        
        
    }
    
    
}

