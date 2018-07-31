//
//  ViewController.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 29..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: UIViewController {
    func showHttpErrorAlert(title: String?, message: String?, buttonText: String?) -> Observable<Void> {
        return Observable<Void>.create({ observer -> Disposable in
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.default, handler: { _ in
                observer.onNext(())
                observer.onCompleted()
            }))

            
            self.base.present(alert, animated: true, completion: {
                
            })
            
            return Disposables.create {
                
            }
        })
    }
}
