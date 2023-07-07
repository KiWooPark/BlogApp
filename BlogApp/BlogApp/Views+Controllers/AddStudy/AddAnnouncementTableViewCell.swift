//
//  AnnouncementTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/05/16.
//

import UIKit

protocol AddAnnouncementTableViewCellDelegate: AnyObject {
    func updateHeightOfRow(_ cell: AddAnnouncementTableViewCell,_ textView: UITextView)
}

class AddAnnouncementTableViewCell: UITableViewCell {
    
    static var identifier: String { return String(describing: self)}
    
    @IBOutlet weak var AnnouncementTextView: UITextView!
    
    var viewModel: StudyComposeViewModel?
    weak var delegate: AddAnnouncementTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        AnnouncementTextView.delegate = self
        AnnouncementTextView.layer.cornerRadius = 5
        AnnouncementTextView.layer.borderColor = UIColor.gray.cgColor
        AnnouncementTextView.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configData() {
        AnnouncementTextView.text = viewModel?.announcement.value == nil ? "공지사항 및 스터디 소개를 작성해주세요." : viewModel?.announcement.value ?? ""
    }
}

extension AddAnnouncementTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.updateHeightOfRow(self, textView)
        viewModel?.updateStudyProperty(.announcement, value: textView.text ?? "")
    }
}
