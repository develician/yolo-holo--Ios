//
//  DayListCollectionViewCell.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 24..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import SnapKit

class DayListCollectionViewCell: UICollectionViewCell {
    
    var fullDate: Date?
    
    let fullImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let blackOpaqueView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
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
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        
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
        
        
        
        
        
        contentView.backgroundColor = UIColor.white
        
        
        self.contentView.layer.cornerRadius = 10.0
//        self.contentView.layer.borderWidth = 1.0
//        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        let components = [fullImageView]
        components.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        fullImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView.snp.centerX).offset(0)
            make.centerY.equalTo(contentView.snp.centerY).offset(0)
            make.width.equalTo(contentView.frame.size.width)
            make.height.equalTo(contentView.frame.size.height)
        }
        
        let fullImageViewComponents = [blackOpaqueView]
        fullImageViewComponents.forEach { (component) in
            fullImageView.addSubview(component)
        }
        
//        fullImageView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
//
        
        blackOpaqueView.snp.makeConstraints { (make) in
            make.centerX.equalTo(fullImageView.snp.centerX).offset(0)
            make.centerY.equalTo(fullImageView.snp.centerY).offset(0)
            make.width.equalTo(150)
            make.height.equalTo(100)
        }
        
        let blackOpaqueViewComponents = [dayTitleLabel, fullDateLabel]
        blackOpaqueViewComponents.forEach {
            blackOpaqueView.addSubview($0)
        }
        
        dayTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(blackOpaqueView.snp.top).offset(16)
            make.left.equalTo(blackOpaqueView.snp.left).offset(16)
            make.right.equalTo(blackOpaqueView.snp.right).offset(-16)
        }
        
        fullDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dayTitleLabel.snp.bottom).offset(16)
            make.left.equalTo(blackOpaqueView.snp.left).offset(16)
            make.right.equalTo(blackOpaqueView.snp.right).offset(-16)
        }
        

    }
}
