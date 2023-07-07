//
//  DetailMemberTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/05/23.
//

import UIKit

class DetailMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var memberListTableView: UITableView!
    
    static var identifier: String { return String(describing: self)}
    
    var studyViewModel: StudyDetailViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 5
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    // 셀사이 간격주기
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
}
