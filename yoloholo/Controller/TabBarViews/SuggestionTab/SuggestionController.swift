//
//  SuggestionController.swift
//  yoloholo
//
//  Created by killi8n on 2018. 8. 1..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SuggestionController: UIViewController {
    
    let cellId: String = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupNavBar()
    }


    fileprivate func setupNavBar() {

        navigationItem.title = "추천 일정"
        
        navigationController?.navigationBar.backgroundColor = .yellow
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.rgb(r: 50, g: 199, b: 242)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
    }

}

typealias SuggestionSection = AnimatableSectionModel<String, Suggestion>
typealias SuggestionDataSource = RxTableViewSectionedAnimatedDataSource<SuggestionSection>

extension SuggestionController {
    
    func createDataSource() -> SuggestionDataSource {
        let dataSource = SuggestionDataSource(configureCell: { [weak self] (dataSource, tableView, indexPath, model) -> UITableViewCell in
            guard let `self` = self else {
                fatalError("self error")
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! SuggestionTableViewCell
            return cell
        })
        
        return dataSource
    }
    
    func bind() {
        
    }
}


