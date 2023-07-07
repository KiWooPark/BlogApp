//
//  DetailAnnouncementTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/05/23.
//

import UIKit

class DetailAnnouncementTableViewCell: UITableViewCell {

    static var identifier: String { return String(describing: self)}
    
    var viewModel: StudyDetailViewModel?
    
    @IBOutlet weak var announcementTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        announcementTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        announcementTextView.textContainer.lineFragmentPadding = 0
    }
    
    // 셀사이 간격주기
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        contentView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configData() {
        announcementTextView.text = viewModel?.study.value?.announcement ?? "공지사항 및 소개를 작성해주세요."
    }
}

