//
//  AddStudyTypeTableViewCell.swift
//  BlogApp
//
//  Created by PKW on 2023/06/24.
//

import UIKit

class AddStudyTypeTableViewCell: UITableViewCell {

    static var identifier: String { return String(describing: self) }
    
    @IBOutlet weak var baseStackView: UIStackView!
    @IBOutlet weak var newStudyButton: UIButton!
    @IBOutlet weak var oldStudyButton: UIButton!
    
    var viewModel: StudyComposeViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tapStudyTypeBUtton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
    
        viewModel?.updateStudyProperty(.newStudy, value: button.tag == 100 ? true : false)
        changeIsSelectedButton()
        
    }
    
    func configButton(isEdit: Bool) {
        baseStackView.isHidden = isEdit ? true : false
        changeIsSelectedButton()
    }
    
    
    func changeIsSelectedButton() {
        if viewModel.isNewStudy.value == true {
            newStudyButton.isSelected = true
            oldStudyButton.isSelected = false
        } else {
            newStudyButton.isSelected = false
            oldStudyButton.isSelected = true
        }
    }
}
