//
//  TodoButtonTableViewCell.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 30..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import SnapKit

class TodoButtonTableViewCell: UITableViewCell {
    
    let buttonLayer: UILabel = {
        let label = UILabel()
        label.text = "Todo 관리"
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
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
        contentView.backgroundColor = UIColor.mainTextBlue
        contentView.addSubview(buttonLayer)
        buttonLayer.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView.snp.centerX)
            make.centerY.equalTo(contentView.snp.centerY)
            make.width.equalTo(contentView.frame.size.width)
            make.height.equalTo(32)
        }
    }
    
}
