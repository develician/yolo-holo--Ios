//
//  PlanService.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 24..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire
import SwiftyJSON

class PlanService: NSObject {
    static let shared = PlanService()
    
    func fetchCreatePlan(username: String?, title: String?, departDate: String?, arriveDate: String?, numberOfDays: Int?, selectedDateArray: [String]?) -> Observable<JSON> {
        guard let url = URL(string: "http://192.168.0.23:4000/api/plan") else {return Observable.empty()}
        
        guard let username = username else {return Observable.empty()}
        guard let title = title else {return Observable.empty()}
        guard let departDate = departDate else {return Observable.empty()}
        guard let arriveDate = arriveDate else {return Observable.empty()}
        guard let numberOfDays = numberOfDays else {return Observable.empty()}
        guard let selectedDateArray = selectedDateArray else {return Observable.empty()}
        
        let body: [String: Any] = [
            "username": username,
            "title": title,
            "departDate": departDate,
            "arriveDate": arriveDate,
            "numberOfDays": numberOfDays,
            "selectedDateArray": selectedDateArray
        ]
        
        return Observable.create({ observer -> Disposable in
            let request = Alamofire.request(url, method: HTTPMethod.post, parameters: body, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { resp in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 201 {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "createPlan", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "createPlan", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
        
        
    }
    
    func fetchPlanList(username: String?) -> Observable<JSON> {
        guard let username = username else {return Observable.empty()}
        guard let url = URL(string: "http://192.168.0.23:4000/api/plan/\(username)") else {return Observable.empty()}
        
        return Observable.create({ observer -> Disposable in
            let request = Alamofire.request(url, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { resp in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 200 {
                        
                        let responseJSON = JSON(value)
                        
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "planList", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "createPlan", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func fetchRemovePlan(id: String?) -> Observable<JSON> {
        guard let id = id else {return Observable.empty()}
        guard let url = URL(string: "http://192.168.0.23:4000/api/plan/\(id)") else {return Observable.empty()}
        
        return Observable.create({ (observer) -> Disposable in
            let request = Alamofire.request(url, method: HTTPMethod.delete, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { (resp) in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 204 {
                        
                        let responseJSON = JSON(value)
                        
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "removePlan", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "removePlan", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func fetchUpdatePlan(id: String?, departDate: String?, arriveDate: String?, numberOfDays: Int?, selectedDateArray: [String]?) -> Observable<JSON> {
        guard let id = id else {return Observable.empty()}
        guard let url = URL(string: "http://192.168.0.23:4000/api/plan/\(id)") else {return Observable.empty()}
        guard let departDate = departDate else {return Observable.empty()}
        guard let arriveDate = arriveDate else {return Observable.empty()}
        guard let numberOfDays = numberOfDays else {return Observable.empty()}
        guard let selectedDateArray = selectedDateArray else {return Observable.empty()}

        let body: [String: Any] = [
            "departDate": departDate,
            "arriveDate": arriveDate,
            "numberOfDays": numberOfDays,
            "selectedDateArray": selectedDateArray
        ]
        
        return Observable.create({ (observer) -> Disposable in
            let request = Alamofire.request(url, method: HTTPMethod.patch, parameters: body, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { (resp) in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 200 {
                        
                        let responseJSON = JSON(value)
                        
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "updatePlan", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "updatePlan", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }

    
}
