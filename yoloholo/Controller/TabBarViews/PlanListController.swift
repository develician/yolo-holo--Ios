//
//  PlanListController.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 23..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import Floaty
import CalendarDateRangePickerViewController
import RxSwift
import RxCocoa
import SwiftyJSON

class PlanListController: UIViewController {
    
    let disposeBag: DisposeBag = DisposeBag()
    
    let cellId: String = "cellId"
    
    var planViewModel: PlanViewModel?
    
    var planList: [PlanViewModel] = [PlanViewModel]()
    
    lazy var floaty: Floaty = {
        let floaty = Floaty()
        
        if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
            floaty.paddingY = tabBarHeight + 16
        }
        
        
        floaty.addItem(icon: UIImage(named: "calendar"), handler: { _ in
            self.presentCalendar()
        })
        return floaty
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(PlanListTableViewCell.self, forCellReuseIdentifier: cellId)
        tv.estimatedRowHeight = 200
        tv.rowHeight = self.view.frame.size.height * 0.2
        tv.tableFooterView = UIView()
        return tv
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fetchPlanList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupNavBar()
        setupViews()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.removePlanSuccess, object: nil, queue: OperationQueue.main) { (noti) in
            if let userInfo = noti.userInfo {
                print(userInfo["id"])
            }
            
        }
    }
    
    fileprivate func setupNavBar() {
        navigationItem.title = "일정 리스트"

        navigationController?.navigationBar.backgroundColor = .yellow
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.rgb(r: 50, g: 199, b: 242)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    fileprivate func setupViews() {
        let components = [tableView]
        components.forEach { component in
            component.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(component)
        }
        
        
        
        floaty.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floaty)
        
        tableView.anchor(top: topLayoutGuide.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    

    fileprivate func fetchPlanList() {
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        
        PlanService.shared.fetchPlanList(username: username).subscribe(onNext: { [weak self] (respJSON) in
            let jsonList = respJSON.enumerated()
            self?.planList = jsonList.map({ (index, element) in
                let plan = Plan(json: element.1)
                return PlanViewModel(plan: plan)
            })
            
        }, onError: { error in
            print(error.localizedDescription)
        }, onCompleted: {
            self.tableView.reloadData()
        }) {
            
        }.disposed(by: disposeBag)
    }



}

extension PlanListController {
    func bind() {
        
    }
    func presentCalendar() {
        let dateRangePickerViewController = CalendarDateRangePickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
        dateRangePickerViewController.delegate = self
        dateRangePickerViewController.minimumDate = Date()
        dateRangePickerViewController.maximumDate = Calendar.current.date(byAdding: .year, value: 2, to: Date())
        //        dateRangePickerViewController.selectedStartDate = Date()
        //        dateRangePickerViewController.selectedEndDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())
        let navigationController = UINavigationController(rootViewController: dateRangePickerViewController)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
}

extension PlanListController: CalendarDateRangePickerViewControllerDelegate {
    func didTapCancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func didTapDoneWithDateRange(startDate: Date!, endDate: Date!) {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let formattedStartDate = dateFormatter.string(from: startDate)
        let formattedEndDate = dateFormatter.string(from: endDate)
        
//        guard let startDate = Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: startDate) else {
//            return
//        }
//
//        guard let endDate = Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: endDate) else {
//            return
//        }
        
        guard let numberOfDays = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day else {
            return
        }

        
        
       

        let planTitleAlert = UIAlertController(title: "제목", message: "일정의 제목을 입력해주세요.", preferredStyle: UIAlertControllerStyle.alert)
        
        planTitleAlert.addTextField { textField in
            textField.placeholder = "일정 제목"
        }
        
        planTitleAlert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { [weak self] _ in
            guard let textFields = planTitleAlert.textFields else {
                return
            }
            
            guard let planTitle = textFields[0].text else {
                return
            }
            guard let username = UserDefaults.standard.string(forKey: "username") else {
                return
            }
            
            guard var departDate = startDate else {return}
            
            var dateArray: [String] = [String]()
            
            while departDate <= endDate {
                let date = dateFormatter.string(from: departDate)
                dateArray.append(date)
                guard let unwrappedDepartDate = Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: departDate) else {return}
                departDate = unwrappedDepartDate
                
            }
            
//            print(username)
//            print(planTitle)
//            print(numberOfDays + 1)
//            print(formattedStartDate)
//            print(formattedEndDate)
//            print(dateArray)
            
            guard let disposeBag: DisposeBag = self?.disposeBag else {
                return
            }
            
            PlanService.shared.fetchCreatePlan(username: username, title: planTitle, departDate: formattedStartDate, arriveDate: formattedEndDate, numberOfDays: numberOfDays + 1, selectedDateArray: dateArray).subscribe(onNext: { [weak self] respJSON in
                let plan: Plan = Plan(json: respJSON)
                
                let planViewModel: PlanViewModel = PlanViewModel(plan: plan)
                self?.planList.insert(planViewModel, at: 0)
                self?.tableView.reloadData()
                
            }, onError: { error in
                print(error.localizedDescription)
            }, onCompleted: {
                print("create plan Observable completed")
            }, onDisposed: {
                print("create plan Observable disposed")
            }).disposed(by: disposeBag)
            
        }))
        
        planTitleAlert.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler: { _ in
            
        }))
        
        self.navigationController?.dismiss(animated: true, completion: {
            self.present(planTitleAlert, animated: true, completion: {
                
            })
        })
    }
    
    
}

extension PlanListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.planList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PlanListTableViewCell
        let plan = self.planList[indexPath.row]
        cell.planViewModel = plan
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let plan = self.planList[indexPath.row]
        let desc = DayListController()
        desc.plan = plan
        self.navigationController?.pushViewController(desc, animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "경고", message: "삭제하면 모든 세부 일정이 없어집니다.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.destructive, handler: { (alertAction) in
                let id = self.planList[indexPath.row]._id
                PlanService.shared.fetchRemovePlan(id: id).subscribe(onNext: { (respJSON) in
                    print(respJSON)
                }, onError: { (error) in
                    print(error.localizedDescription)
                }, onCompleted: {
                    self.planList.remove(at: indexPath.row)
                    tableView.reloadData()
                }, onDisposed: {
                    
                }).disposed(by: self.disposeBag)
                
            }))
            alert.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler: { (alertAction) in
                
            }))
            self.present(alert, animated: true, completion: {
                
            })
            
        }
    }
}


