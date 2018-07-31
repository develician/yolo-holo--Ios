//
//  DayListController.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 24..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import SwiftyJSON
import RxSwift
import RxCocoa
import CalendarDateRangePickerViewController

class DayListController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var plan: PlanViewModel?
    
    let cellId: String = "cellId"
    
    let fullImageList: [String] = ["trip_cell1", "trip_cell2", "trip_cell3", "trip_cell4", "trip_cell5", "trip_cell6", "trip_cell7"]
    
    let trashBarButtonItem: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: nil)
        btn.tintColor = .white
        return btn
    }()
    
    lazy var dayCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.alwaysBounceVertical = true
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = UIColor.FlatColor.Gray.Gray1
        cv.register(DayListCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        return cv
    }()
    
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
        
        guard let plan = self.plan else {
            return
        }
        
        
       
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = trashBarButtonItem
        
        let components = [dayCollectionView]
        components.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        dayCollectionView.anchor(top: topLayoutGuide.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    fileprivate func setupNavBar() {
        guard let plan = self.plan else {
            return
        }
        
        navigationItem.title = plan.title
        
        navigationController?.navigationBar.backgroundColor = .yellow
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.rgb(r: 50, g: 199, b: 242)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
    }
}

extension DayListController {
    func jsonToString(json: AnyObject) -> String? {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            return convertedString // <-- here is ur string
            
        } catch let myJSONError {
            print(myJSONError)
        }
        
        return nil
        
    }
    
    func bind() {
        trashBarButtonItem.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: "일정 수정", style: UIAlertActionStyle.default, handler: { [weak self] (alertAction) in
                guard let startDate = self?.plan?.departDate, let endDate = self?.plan?.arriveDate else {return}
                self?.presentCalendar(startDate: startDate, endDate: endDate)

            }))
            
            alert.addAction(UIAlertAction(title: "삭제", style: UIAlertActionStyle.destructive, handler: { [weak self] (alertAction) in
                
                if let id = self?.plan?._id, let disposeBag = self?.disposeBag {
                    PlanService.shared.fetchRemovePlan(id: id).subscribe(onNext: { [weak self] (respJSON) in
                        print(respJSON)
                    }, onError: { (error) in
                        print(error.localizedDescription)
                    }, onCompleted: {
                        NotificationCenter.default.post(name: NSNotification.Name.removePlanSuccess, object: nil, userInfo: ["id" : self?.plan?._id])
                        self?.navigationController?.popViewController(animated: true)
                    }, onDisposed: {

                    }).disposed(by: disposeBag)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "닫기", style: UIAlertActionStyle.cancel, handler: { (alertAction) in
                
            }))
            self?.present(alert, animated: true, completion: {
                
            })
        }).disposed(by: disposeBag)
    }
    
    func presentCalendar(startDate: Date?, endDate: Date?) {
        let dateRangePickerViewController = CalendarDateRangePickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
        dateRangePickerViewController.delegate = self
        dateRangePickerViewController.minimumDate = Date()
        dateRangePickerViewController.maximumDate = Calendar.current.date(byAdding: .year, value: 2, to: Date())
        guard let startDate = startDate else {return}
        dateRangePickerViewController.selectedStartDate = startDate
        guard let endDate = endDate else {return}
        
        dateRangePickerViewController.selectedEndDate = endDate
        let navigationController = UINavigationController(rootViewController: dateRangePickerViewController)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
}



extension DayListController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let plan = self.plan {
            return plan.numberOfDays
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DayListCollectionViewCell
        cell.dayTitleLabel.text = "\(indexPath.row + 1)일차"
        
        if let plan = self.plan {
            let fullDate = plan.selectedDateArray[indexPath.row]
            
            let fullDateStr = "\(fullDate)"
            let str = "\(fullDateStr.split(separator: "T")[0])"
            
            cell.fullDateLabel.text = str
            
            
        }
        let randomIndex = Int(arc4random_uniform(UInt32(self.fullImageList.count)))
        let targetImage = self.fullImageList[randomIndex]
        cell.fullImageView.image = UIImage(named: targetImage)
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - 32, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.item)")
        let dest = DetailPlanController()
        dest.day = indexPath.item + 1
        guard let id = self.plan?._id else {return}
        dest.planId = id
        self.navigationController?.pushViewController(dest, animated: true)
    }
    
    
}

extension DayListController: CalendarDateRangePickerViewControllerDelegate {
    func didTapCancel() {
         self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func didTapDoneWithDateRange(startDate: Date!, endDate: Date!) {
//        selectedDateArray, departDate, arriveDate, numberOfDays
        guard let departDate = startDate else {return}
        guard let arriveDate = endDate else {return}



        guard let existingPlanArriveDate = self.plan?.arriveDate else {return}
        guard let existingPlanDepartDate = self.plan?.departDate else {return}


        if existingPlanDepartDate == departDate && existingPlanArriveDate == arriveDate {
            self.navigationController?.dismiss(animated: true, completion: {
                let alert = UIAlertController(title: "오류", message: "같은 일정은 수정이 불가능합니다.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { (alertActoin) in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            })
            
            return
        }
        
        self.navigationController?.dismiss(animated: true, completion: {
           
            
            var dateArray: [String] = [String]()
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            var newStartDate = departDate
            
            while newStartDate <= arriveDate {
                
                let date = dateFormatter.string(from: newStartDate)
                dateArray.append(date)
                guard let unwrappedStartDate = Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: newStartDate) else {return}
                newStartDate = unwrappedStartDate
                
            }
            
            if let id = self.plan?._id {
                guard let departDate = Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: startDate) else {return}
                let formattedDepartDate = dateFormatter.string(from: startDate)
                guard let arriveDate = Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: endDate) else {return}
                let formattedArriveDate = dateFormatter.string(from: endDate)
                guard let numberOfDays = Calendar.current.dateComponents([.day], from: departDate, to: arriveDate).day else {
                    return
                }
                
                PlanService.shared.fetchUpdatePlan(id: id, departDate: formattedDepartDate, arriveDate: formattedArriveDate, numberOfDays: numberOfDays + 1, selectedDateArray: dateArray).subscribe(onNext: { [weak self] (respJSON) in
                    let plan: Plan = Plan(json: respJSON)
                    let planViewModel: PlanViewModel = PlanViewModel(plan: plan)
                    self?.plan = planViewModel
                }, onError: { (error) in
                    print(error.localizedDescription)
                }, onCompleted: {
                    self.dayCollectionView.reloadData()
                }, onDisposed: {

                }).disposed(by: self.disposeBag)
            }
        })
        
    }
    
    
}
