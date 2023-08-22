//
//  EditMemberInfoView.swift
//  BlogApp
//
//  Created by PKW on 2023/07/25.
//

import UIKit
import SnapKit
import Then

class EditMemberInfoView: UIView {

    let infoStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    let fineStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 5
    }
    
    let blogStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 5
    }
    
    let nameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "이름"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    }
    
    let fineTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        $0.text = "보증금"
        $0.textColor = .restColor
    }
    
    let fineSubTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "#,###원"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    }
    
    let blogTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        $0.text = "블로그 주소"
        $0.textColor = .restColor
    }
    
    let blogSubTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "###.####.###"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    }
    
    let editButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = .buttonColor
        $0.setImage(UIImage(systemName: "highlighter"), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.cellColor
        self.layer.cornerRadius = .cornerRadius
                
        self.addSubview(infoStackView)
        self.addSubview(editButton)
        
        infoStackView.addArrangedSubview(nameLabel)
        
        fineStackView.addArrangedSubview(fineTitleLabel)
        fineStackView.addArrangedSubview(fineSubTitle)
        
        infoStackView.addArrangedSubview(fineStackView)
        
        blogStackView.addArrangedSubview(blogTitleLabel)
        blogStackView.addArrangedSubview(blogSubTitle)
        
        infoStackView.addArrangedSubview(blogStackView)
        
        infoStackView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview().inset(20)
        }
        
        editButton.setContentHuggingPriority(.init(rawValue: 252), for: .horizontal)
        editButton.setContentHuggingPriority(.init(rawValue: 252), for: .vertical)
        
        editButton.snp.makeConstraints { make in
            make.leading.equalTo(infoStackView.snp.trailing)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(infoStackView.snp.centerY)
            make.width.height.equalTo(25)
        }
    }
}
