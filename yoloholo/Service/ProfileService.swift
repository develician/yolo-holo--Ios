//
//  ProfileService.swift
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

class ProfileService: NSObject {
    static let shared = ProfileService()
    
    func fetchGetProfileImage(url: URL) -> Observable<String> {
        return Observable<String>.create({ observer -> Disposable in
            
            let destination = DownloadRequest.suggestedDownloadDestination()
            
            let download = Alamofire.download(url, to: destination).response(completionHandler: { (response: DefaultDownloadResponse) in
                if let data = response.destinationURL {
                    observer.onNext(data.path)
                    observer.onCompleted()
                } else {
                    observer.onError(RxError.unknown)
                }
            })

            return Disposables.create {
                download.cancel()
            }
        })
    }
}

