//
//  StudyMemberInfoView.swift
//  BlogApp
//
//  Created by PKW on 2023/07/25.
//

import UIKit
import SnapKit
import Then

class StudyMemberInfoView: UIView {

    let baseStackView = UIStackView().then {
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
        $0.text = "10,000원"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    }
    
    let underlineView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemGray5
    }
    
    let showBlogButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .buttonColor
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.setTitle("블로그 보러가기", for: .normal)
        $0.layer.cornerRadius = .cornerRadius
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
        
        self.addSubview(baseStackView)
        baseStackView.addArrangedSubview(nameLabel)
        
        fineStackView.addArrangedSubview(fineTitleLabel)
        fineStackView.addArrangedSubview(fineSubTitle)
        
        baseStackView.addArrangedSubview(fineStackView)
        baseStackView.addArrangedSubview(underlineView)
        
        baseStackView.addArrangedSubview(showBlogButton)

        baseStackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview().inset(20)
        }
        
        underlineView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        
    }
}
