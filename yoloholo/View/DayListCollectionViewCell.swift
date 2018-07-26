//
//  DayListCollectionViewCell.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 24..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit

class DayListCollectionViewCell: UICollectionViewCell {
    
    var fullDate: Date?
    
    let fullImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let dayTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.semibold)
        label.textColor = .white
        return label
    }()
    
    let fullDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.thin)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupContentViews() {
        
        
        
        contentView.backgroundColor = UIColor.mainTextBlue
        
        let components = [fullImageView]
        components.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        let fullImageViewComponents = [dayTitleLabel, fullDateLabel]
        fullImageViewComponents.forEach { (component) in
            component.translatesAutoresizingMaskIntoConstraints = false
            fullImageView.addSubview(component)
        }
        
        let margins = contentView.layoutMargins
        
        fullImageView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        dayTitleLabel.anchor(top: fullImageView.topAnchor, leading: fullImageView.leadingAnchor, bottom: nil, trailing: fullImageView.trailingAnchor, padding: .init(top: margins.top + 16, left: margins.left + 16, bottom: 0, right: margins.right + 16))
        
        fullDateLabel.anchor(top: dayTitleLabel.bottomAnchor, leading: fullImageView.leadingAnchor, bottom: nil, trailing: fullImageView.trailingAnchor, padding: .init(top: 16, left: margins.left + 16, bottom: 0, right: margins.right + 16))
//        print(self.fullDate)
    }
}
