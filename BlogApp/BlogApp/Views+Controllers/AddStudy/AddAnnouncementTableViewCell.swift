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
    
    var textViewPlaceHolder = "공지사항 및 스터디 소개를 작성해주세요."
    
    override func awakeFromNib() {
        super.awakeFromNib()

        AnnouncementTextView.delegate = self
        AnnouncementTextView.layer.cornerRadius = 5
        AnnouncementTextView.layer.borderColor = UIColor.gray.cgColor
        AnnouncementTextView.layer.borderWidth = 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.AnnouncementTextView.resignFirstResponder()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configData() {
        if viewModel?.announcement.value == nil {
            AnnouncementTextView.text = textViewPlaceHolder
            AnnouncementTextView.textColor = .lightGray
        }

        //AnnouncementTextView.text = viewModel?.announcement.value == nil ? "공지사항 및 스터디 소개를 작성해주세요." : viewModel?.announcement.value ?? ""
    }
}

extension AddAnnouncementTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.updateHeightOfRow(self, textView)
        
        let text = textView.text == "" ? nil : textView.text
        viewModel?.updateStudyProperty(.announcement, value: text)
    }

    // 포커스를 얻는 경우
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    // 포커스를 잃는 경우
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }
}
