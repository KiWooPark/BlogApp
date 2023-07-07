//
//  DetailTitleTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/05/23.
//

import UIKit

class DetailTitleTableViewCell: UITableViewCell {

    static var identifier: String { return String(describing: self)}
    
    var viewModel: StudyDetailViewModel?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
    }
    
    // 셀사이 간격주기
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        contentView.layer.cornerRadius = 10
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configData() {
        titleLabel.text = viewModel?.study.value?.title ?? "스터디 이름을 설정해주세요."
    }
}
