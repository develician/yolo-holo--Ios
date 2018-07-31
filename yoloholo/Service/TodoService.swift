//
//  TodoService.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 30..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire
import SwiftyJSON
import GoogleMaps
import GooglePlacePicker


class TodoService: NSObject {
    static let shared = TodoService()
    
    func fetchListTodo(id: String?) -> Observable<JSON> {
        guard let id = id else {return Observable.empty()}
        guard let url = TodoAPI.listTodo(id: id).url else {return Observable.empty()}
        
        return Observable.create({ (observer) -> Disposable in
            let request = Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { (resp) in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 200 {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "listTodo", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "listTodo", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func fetchAddTodo(id: String?, todo: String?) -> Observable<JSON> {
        guard let id = id else {return Observable.empty()}
        guard let todo = todo else {return Observable.empty()}
        
        guard let url = TodoAPI.addTodo(id: id).url else {return Observable.empty()}
        
        let body: [String: Any] = [
            "todo": todo
        ]
        
        return Observable.create({ (observer) -> Disposable in
            let request = Alamofire.request(url, method: .patch, parameters: body, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { (resp) in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 200 {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "addTodo", code: 200, userInfo: nil))
                    }
                    break
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "addTodo", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
        
    }
    
    func fetchEditTodo(id: String?, index: Int?, todo: String?) -> Observable<JSON> {
        guard let id = id else {return Observable.empty()}
        guard let index = index else {return Observable.empty()}
        guard let todo = todo else {return Observable.empty()}
        
        guard let url = TodoAPI.editTodo(id: id, index: index).url else {return Observable.empty()}
        
        let body: [String: Any] = [
            "todo": todo
        ]
        
        return Observable.create({ (observer) -> Disposable in
            let request = Alamofire.request(url, method: .patch, parameters: body, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { (resp) in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 200 {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "editTodo", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "editTodo", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func fetchRemoveTodo(id: String?, index: Int?) -> Observable<JSON> {
        guard let id = id else {return Observable.empty()}
        guard let index = index else {return Observable.empty()}
        
        guard let url = TodoAPI.removeTodo(id: id, index: index).url else {return Observable.empty()}
        
        return Observable.create({ (observer) -> Disposable in
            let request = Alamofire.request(url, method: .delete, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { (resp) in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 200 {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "removeTodo", code: 200, userInfo: nil))
                    }
                    break
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "removeTodo", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
        
    }
}
