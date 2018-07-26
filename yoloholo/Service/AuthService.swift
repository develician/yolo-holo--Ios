//
//  AuthService.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 23..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire
import SwiftyJSON

class AuthService: NSObject {
    static let shared = AuthService()
    
    func fetchRegister(email: String?, username: String?, password: String?) -> (Observable<JSON>) {
        guard let email = email else {return Observable.empty()}
        guard let username = username else {return Observable.empty()}
        guard let password = password else {return Observable.empty()}
        
        return Observable.create({ observer -> Disposable in
            let body: [String: Any] = [
                "username": username,
                "password": password,
                "email": email
            ]
            
            let urlString = "http://192.168.0.23:4000/api/auth/register"
            
            let url = URL(string: urlString)
            
            
            let request = Alamofire.request(url!, method: HTTPMethod.post, parameters: body, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { (resp) in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 200 {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "register", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "register", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
            
        })
        
    }
    
    func fetchLogin(email: String?, password: String?) -> (Observable<JSON>) {
        guard let email = email else {return Observable.empty()}
        guard let password = password else {return Observable.empty()}
        
        
        guard let url = URL(string: "http://192.168.0.23:4000/api/auth/login") else {
            return Observable.empty()
        }
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        return Observable.create({ observer -> Disposable in
            
            let request = Alamofire.request(url, method: HTTPMethod.post, parameters: body, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { resp in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 200 {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "login", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "login", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func fetchLogout() -> Observable<JSON>{
        guard let url = URL(string: "http://192.168.0.23:4000/api/auth/logout") else {return Observable.empty()}
        return Observable.create({ observer -> Disposable in
            let request = Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { resp in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 204 {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "login", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "logout", code: 100, userInfo: nil))
                    break
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func fetchProfile(username: String?) -> Observable<JSON> {
        guard let username = username else {return Observable.empty()}
        guard let url = URL(string: "http://192.168.0.23:4000/api/auth/profile/\(username)") else {return Observable.empty()}
        
        return Observable.create({ observer -> Disposable in
            let request = Alamofire.request(url, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { resp in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 200 {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "login", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "profile", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func fetchChangePassword(password: String?, username: String?) -> Observable<JSON> {
        guard let password = password else {return Observable.empty()}
        guard let username = username else {return Observable.empty()}
        guard let url = URL(string: "http://192.168.0.23:4000/api/auth") else {return Observable.empty()}
        let body: [String: Any] = [
            "password": password,
            "username": username
        ]
        return Observable.create({ observer -> Disposable in
            let request = Alamofire.request(url, method: HTTPMethod.patch, parameters: body, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { resp in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, statusCode == 200 {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "changePassword", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "changePassword", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func fetchFacebook(fbToken: String?, pictureUrl: String?, fbEmail: String?, fbId: String?, fbName: String?, socialKey: String?) -> Observable<JSON> {
        guard let fbToken = fbToken else {return Observable.empty()}
        guard let pictureUrl = pictureUrl else {return Observable.empty()}
        guard let fbEmail = fbEmail else {return Observable.empty()}
        guard let fbId = fbId else {return Observable.empty()}
        guard let fbName = fbName else {return Observable.empty()}
        guard let socialKey = socialKey else {return Observable.empty()}
        
        let body: [String : Any] = [
            "fbToken": fbToken,
            "pictureUrl": pictureUrl,
            "fbEmail": fbEmail,
            "fbId": fbId,
            "fbName": fbName,
            "socialKey": socialKey
        ]

        guard let url = URL(string: "http://192.168.0.23:4000/api/auth/facebook") else {return Observable.empty()}
        
        return Observable.create({ (observer) -> Disposable in
            let request = Alamofire.request(url, method: HTTPMethod.post, parameters: body, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { (resp) in
                switch resp.result {
                case .success(let value):
                    if let statusCode = resp.response?.statusCode, (statusCode == 208 || statusCode == 200) {
                        let responseJSON = JSON(value)
                        observer.onNext(responseJSON)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "facebookLogin", code: 200, userInfo: nil))
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(NSError(domain: "facebookLogin", code: 100, userInfo: nil))
                    break
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })

    }
  
}


