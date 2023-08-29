//
//  StudyListEmptyTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/08/15.
//

import UIKit

/// 스터디 정보가 없을 경우 표시하는 UITableViewCell 클래스 입니다.
class StudyListEmptyTableViewCell: UITableViewCell {

    // MARK:  ===== [@IBOutlet] =====
    
    // Empty 정보를 보여줄 뷰
    @IBOutlet weak var emptyView: UIView!

    static var identifier: String { return String(describing: self)}

    
    
    // MARK: ===== [Override] =====

    override func awakeFromNib() {
        super.awakeFromNib()
        
        emptyView.layer.cornerRadius = .cornerRadius
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
