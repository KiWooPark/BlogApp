//
//  StudyTitleTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/05/18.
//

import UIKit

class AddTitleTableViewCell: UITableViewCell {
    
    static var identifier: String { return String(describing: self)}
    
    @IBOutlet weak var titleTextField: UITextField!
    
    var viewModel: StudyComposeViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func textFieldDidChange(_ sender: Any?) {
        // 텍스트가 변경될때마다 뷰모델의 title 프로퍼티 업데이트
        let text = titleTextField.text == "" ? nil : titleTextField.text
        viewModel?.updateStudyProperty(.title, value: text)
    }
    
    func configData() {
        if viewModel.title.value == nil {
            titleTextField.placeholder = "스터디 이름을 입력해주세요."
        } else {
            titleTextField.text = viewModel.title.value ?? ""
        }
    }
}
