//
//  DetailPlanService.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 25..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire
import SwiftyJSON
import GoogleMaps
import GooglePlacePicker

class DetailPlanService: NSObject {
    static let shared = DetailPlanService()
    
    func fetchRead(planId: String?, day: Int?) -> Observable<JSON> {
        guard let planId = planId else {return Observable.empty()}
        guard let day = day else {return Observable.empty()}
        
        
        guard let url = DetailPlanAPI.read(planId: planId, day: day).url else {return Observable.empty()}
        return Observable.create({ (observer) -> Disposable in
            let request = Alamofire.request(url, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { (resp) in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 200 {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "readDetailPlan", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "readDetailPlan", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func fetchCreate(planId: String?, username: String?, day: Int?, destName: String?, latitude: CLLocationDegrees?, longitude: CLLocationDegrees?, placeId:String?, todoList: [String]?, googleMapEnabled: Bool?) -> Observable<JSON> {
        guard let planId = planId else {return Observable.empty()}
        guard let username = username else {return Observable.empty()}
        guard let destName = destName else {return Observable.empty()}
        guard let day = day else {return Observable.empty()}
        guard let todoList = todoList else {return Observable.empty()}
        
        guard let googleMapEnabled = googleMapEnabled else {return Observable.empty()}
        
        var body: [String : Any]?
        if googleMapEnabled {
            guard let latitude = latitude else {return Observable.empty()}
            guard let longitude = longitude else {return Observable.empty()}
            guard let placeId = placeId else {return Observable.empty()}
            
            body = [
                "planId": planId,
                "username": username,
                "day": day,
                "destName": destName,
                "latitude": latitude,
                "longitude": longitude,
                "placeId": placeId,
                "todoList": todoList,
                "googleMapEnabled": googleMapEnabled
            ]
        } else {
            body = [
            "planId": planId,
            "username": username,
            "day": day,
            "destName": destName,
            "todoList": todoList,
            "googleMapEnabled": googleMapEnabled
            ]
        }
        
        
        

        

        
        
        guard let url = DetailPlanAPI.create.url else {return Observable.empty()}
        guard let postBody = body else {return Observable.empty()}
        return Observable.create({ (observer) -> Disposable in
            
            let request = Alamofire.request(url, method: HTTPMethod.post, parameters: postBody, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { (resp) in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 201 {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "createDetailPlan", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "createDetailPlan", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func fetchRemove(id: String?) -> Observable<JSON> {
        guard let id = id else {return Observable.empty()}
        guard let url = DetailPlanAPI.remove(id: id).url else {return Observable.empty()}
        
        return Observable.create({ (observer) -> Disposable in
            let request = Alamofire.request(url, method: HTTPMethod.delete, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { (resp) in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 204 {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "removeDetailPlan", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "removeDetailPlan", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func fetchUpdate(id: String?, destName: String?, latitude: CLLocationDegrees?, longitude: CLLocationDegrees?, placeId: String?, todoList: [String]?) -> Observable<JSON> {
        guard let id = id, let destName = destName, let latitude = latitude, let longitude = longitude, let placeId = placeId, let todoList = todoList else {return Observable.empty()}
        
        let body: [String : Any] = [
            "id": id,
            "destName": destName,
            "latitude": latitude,
            "longitude": longitude,
            "placeId": placeId,
            "todoList": todoList
        ]
        
        guard let url = DetailPlanAPI.update(id: id).url else {return Observable.empty()}
        return Observable.create({ (observer) -> Disposable in
            let request = Alamofire.request(url, method: HTTPMethod.patch, parameters: body, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { (resp) in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 200 {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "updateDetailPlan", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "updateDetailPlan", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
}
