//
//  PlanListTableViewCell.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 24..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit

class PlanListTableViewCell: UITableViewCell {
    
    var planViewModel: PlanViewModel! {
        didSet {
            textLabel?.text = planViewModel.title
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let departDate: String = dateFormatter.string(from: planViewModel.departDate)
            let arriveDate: String = dateFormatter.string(from: planViewModel.arriveDate)
            detailTextLabel?.text = "\(departDate) ~ \(arriveDate)"
            accessoryType = .disclosureIndicator
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        contentView.backgroundColor = isHighlighted ? .highlightColor : .white
        textLabel?.textColor = isHighlighted ? UIColor.white : .mainTextBlue
        detailTextLabel?.textColor = isHighlighted ? .white : .black
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        textLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        textLabel?.numberOfLines = 0
        detailTextLabel?.textColor = .black
        detailTextLabel?.font = UIFont.systemFont(ofSize: 20, weight: .light)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
