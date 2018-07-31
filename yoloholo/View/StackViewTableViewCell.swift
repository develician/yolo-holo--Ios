//
//  StackViewTableViewCell.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 29..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import SnapKit

class StackViewTableViewCell: UITableViewCell {
    
    var nextLatitude: Double?
    var nextLongitude: Double?
    
    let departButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("출발지", for: UIControlState.normal)
        btn.backgroundColor = UIColor.FlatColor.Gray.Gray4
        btn.titleLabel?.textColor = .white
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 12
        return btn
        
    }()
    
    let arriveButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("도착지", for: UIControlState.normal)
        btn.backgroundColor = UIColor.FlatColor.Gray.Gray4
        btn.titleLabel?.textColor = .white
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 12
        return btn
        
    }()
    
    let nextDestButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("다음 목적지", for: UIControlState.normal)
        btn.backgroundColor = UIColor.FlatColor.Gray.Gray4
        btn.titleLabel?.textColor = .white
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 12
        return btn
        
    }()
    
    lazy var buttonStackView: UIStackView = {
        let subViews = [departButton, arriveButton, nextDestButton]
        
        let sv = UIStackView(arrangedSubviews: subViews)
        sv.axis = .horizontal
        sv.spacing = 16
        sv.distribution = .fillEqually
        return sv
    }()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupContentViews()
  

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContentViews() {
        contentView.addSubview(buttonStackView)
        
        
        buttonStackView.snp.makeConstraints { (make) in
            let margins = contentView.layoutMargins
            make.top.equalTo(contentView.snp.top).offset(margins.top)
            make.left.equalTo(contentView.snp.left).offset(margins.left)
            make.right.equalTo(contentView.snp.right).offset(-margins.right)
            make.bottom.equalTo(contentView.snp.bottom).offset(-margins.bottom)
        }
    }
    
}
