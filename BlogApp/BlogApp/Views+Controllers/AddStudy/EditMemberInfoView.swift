//
//  EditMemberInfoView.swift
//  BlogApp
//
//  Created by PKW on 2023/07/25.
//

import UIKit
import SnapKit
import Then

/// 수정 버튼이 포함된 멤버의 정보를 보여줄 뷰의 커스텀 클래스 입니다.
class EditMemberInfoView: UIView {

    // MARK: ===== [Property] =====
    
    // 멤버 정보를 표시할 수직 스택 뷰
    let infoStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    // 벌금 정보를 표시할 수직 스택 뷰
    let fineStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 5
    }
    
    // 블로그 정보를 표시할 수직 스택 뷰
    let blogStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 5
    }
    
    // 이름을 표시할 레이블
    let nameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "이름"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    }
    
    // 보증금을 표시할 레이블
    let fineTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        $0.text = "보증금"
        $0.textColor = .restColor
    }
    
    // 벌금을 표시할 레이블
    let fineSubTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "#,###원"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    }
    
    // 블로그 주소를 표시할 레이블
    let blogTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        $0.text = "블로그 주소"
        $0.textColor = .restColor
    }
    
    // 블로그 URL을 표시할 레이블
    let blogSubTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "###.####.###"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    }
    
    // 멤버 정보 수정 버튼
    let editButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = .buttonColor
        $0.setImage(UIImage(systemName: "highlighter"), for: .normal)
    }
    
    
    
    // MARK: ===== [Override] =====
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    
    
    // MARK:  ===== [Function] =====
    
    /// 멤버 정보를 표시할 뷰들을 설정하고 제약조건을 추가합니다.
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
